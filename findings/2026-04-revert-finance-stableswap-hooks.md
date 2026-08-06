# Native ETH `removeLiquidity` reentrancy lets an LP swap against withdrawn stale reserves

- **Program:** Revert Finance, StableSwap Hooks
- **Platform:** Cantina public competition, 30 April to 8 May 2026
- **Result:** Confirmed High. 58th of 269 researchers, 1,412 findings submitted
- **Target:** [revert-finance/stableswap-hooks](https://github.com/revert-finance/stableswap-hooks) @ `cf0c30e576f144809df9819f4d3ad49e0b7fe2d7`
- **Competition:** https://cantina.xyz/code/e55ee7b9-6c99-42f8-8338-39f3dd134ef3/overview
- **PoC:** [`RemoveLiquidityReentrancyPoC.t.sol`](RemoveLiquidityReentrancyPoC.t.sol)

This is my submission as filed. The competition is closed and its findings are public.

---

## Summary

`removeLiquidity()` sends native ETH to the LP before the hook updates `reserves[]` and before the LP shares are burned. For native ETH pools, `poolManager.take()` forwards all gas to `sender.receive()`. While that callback is running, the Uniswap v4 `PoolManager` is already unlocked, so the receiver can call `poolManager.swap()` directly without calling `hooks.addLiquidity()`/`hooks.removeLiquidity()` and without hitting the nested `unlock()` guard.

The reentrant swap is priced from the hook's stale `reserves[]`, which still include the attacker's withdrawn liquidity. This lets the attacker use temporary liquidity as phantom depth, remove it, and in the ETH receive callback buy almost all of the remaining honest ETH reserve at the stale deep-liquidity price.

## Affected code

In `src/Liquidity.sol`, `_handleRemoveLiquidityCallback()` transfers funds before effects:

- `src/Liquidity.sol:207` burns the hook's PoolManager claim for the withdrawn currency.
- `src/Liquidity.sol:208` calls `poolManager.take(currency, sender, amounts[i])`.
- `src/Liquidity.sol:210` decrements `reserves[i]` only after the external transfer.
- `src/Liquidity.sol:213` burns the LP shares only after all transfers finish.

For native ETH, the external transfer is a full-gas call:

- `lib/uniswap-hooks/lib/v4-core/src/types/Currency.sol:45-48`

During the hook's unlock callback, PoolManager is unlocked:

- `lib/uniswap-hooks/lib/v4-core/src/PoolManager.sol:104-113`
- `PoolManager.swap()` only requires `onlyWhenUnlocked` at `PoolManager.sol:187-190`.

The swap hook prices from `reserves[]`:

- `src/Swap.sol:100-106`

So the reentrant `poolManager.swap()` sees the pre-withdrawal reserves even though the attacker is already receiving the withdrawn ETH.

## Proof of concept

The attached Foundry test is `RemoveLiquidityReentrancyPoC.t.sol`.

Reproduction:

```bash
git clone https://github.com/revert-finance/stableswap-hooks.git
cd stableswap-hooks
git checkout cf0c30e576f144809df9819f4d3ad49e0b7fe2d7
mkdir -p test/poc
cp RemoveLiquidityReentrancyPoC.t.sol test/poc/
forge test --match-path test/poc/RemoveLiquidityReentrancyPoC.t.sol -vv
```

Observed output:

```text
[PASS] test_controlSameSwapAfterNormalRemovalCostsMuchMore()
Logs:
  control ETH taken 9999000000000000000000
  control token paid 100473376809521143097312

[PASS] test_removeLiquidityReentersSwapBeforeReservesAndSharesAreUpdated()
Logs:
  reentrant observed ETH reserve before swap 1000000000000000000000000
  reentrant ETH taken 9999000000000000000000
  reentrant token paid 10002990093097160574767
  final ETH reserve 1000000000000000000
  final token reserve 20002990093097160574767
```

The control path removes the attacker's liquidity first, then performs the same exact-output token-to-ETH swap against the real `10,000 ETH / 10,000 TOKEN` honest pool. It costs `100,473.3768 TOKEN` to receive `9,999 ETH`.

The exploit path performs the same swap from `receive()` during `removeLiquidity()`. The hook still observes `1,000,000 ETH / 1,000,000 TOKEN` reserves, so the attacker pays only `10,002.9900 TOKEN` for the same `9,999 ETH`. The final honest pool is left with only `1 ETH` and about `20,002.99 TOKEN`.

## Impact

An LP can temporarily add large balanced liquidity, start removing it, and use the native ETH transfer callback to swap against reserves that still include the removed liquidity. This bypasses the StableSwap curve that should make draining the scarce side expensive.

In the PoC, the same `9,999 ETH` exact-output swap costs about 10x less input in the reentrant path than it costs after the withdrawal is accounted for. The attacker drains almost all of the honest ETH side while only paying the stale deep-liquidity price.

Existing reentrancy tests only cover reentering through hook functions that call `poolManager.unlock()` again. That path correctly reverts with `AlreadyUnlocked`. This issue uses direct `poolManager.swap()` while the manager is already unlocked and manually settles/takes the swap deltas before the outer unlock returns.

## Recommended fix

Apply checks-effects-interactions in `_handleRemoveLiquidityCallback()`:

- Burn LP shares and decrement all internal `reserves[]` before any `poolManager.take()` transfer to `sender`.
- Alternatively add an in-hook reentrancy/state guard that blocks `_beforeSwap()` while a liquidity callback is in progress.

The safest fix is to update all hook accounting first, then do the external transfers.

## Duplicate checks

I checked public web and GitHub search for the specific pattern:

- `"stableswap-hooks" "removeLiquidity" "reentrancy"`
- `"Revert Finance" "StableSwap" "removeLiquidity" "poolManager.take"`
- `"poolManager.take" "reserves" "removeLiquidity" "StableSwapHooks"`
- `"poolManager.take" "reserves[i] -= amounts[i]"`

I did not find a matching public report or discussion.
