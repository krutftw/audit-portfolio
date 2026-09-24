# Tradi3 — smart contract security

Kurt Landman, Perth, Australia. I review DeFi contracts, mainly accounting, AMMs,
oracle integrations, and access control.

[Website](https://tradi3.com/) · [Contact](mailto:hello@tradi3.com) ·
[Cantina](https://cantina.xyz/u/Tradi3) ·
[Sherlock](https://audits.sherlock.xyz/watson/Tradi3) ·
[Immunefi](https://immunefi.com/profile/Tradi3/)

## Selected results

| Review | Result | Public record |
| --- | --- | --- |
| Revert Finance · StableSwap Hooks | 1 High · 1 Medium | [Cantina leaderboard](https://cantina.xyz/competitions/e55ee7b9-6c99-42f8-8338-39f3dd134ef3/leaderboard) |
| Metric | 3 Mediums | [Sherlock](https://audits.sherlock.xyz/watson/Tradi3) |
| Base Azul | 1 Medium | [Immunefi leaderboard](https://immunefi.com/audit-competition/audit-comp-base-azul/leaderboard/) |

## Revert Finance — confirmed High

**Native ETH `removeLiquidity` reentrancy lets an LP swap against withdrawn stale reserves**

A reserve-accounting issue in the native ETH withdrawal path. The report includes
the affected code, impact, test output, and remediation.

[Read the full report](findings/2026-04-revert-finance-stableswap-hooks.md) ·
[Foundry proof of concept](findings/RemoveLiquidityReentrancyPoC.t.sol)

## Research tooling

[Bounty Operator Kit](https://github.com/krutftw/bounty-operator-kit) — my public
workflow for scope tracking, review notes, prior-art checks, and report preparation.

## Background

Certificate IV in Cyber Security (22603VIC), East Perth TAFE, Western Australia.
