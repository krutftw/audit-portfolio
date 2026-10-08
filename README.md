# Tradi3 — smart contract & blockchain security

Kurt Landman, Perth, Australia. I review DeFi contracts and blockchain systems,
focusing on accounting, AMMs, oracle integrations, transaction security, and access control.

[Website](https://tradi3.com/) · [Competition reports](https://tradi3.com/reports/) ·
[Contact](mailto:hello@tradi3.com) ·
[Cantina](https://cantina.xyz/u/Tradi3) ·
[Sherlock](https://audits.sherlock.xyz/watson/Tradi3) ·
[Immunefi](https://immunefi.com/profile/Tradi3/)

## Competition results

| Competition | Result | Placement | Public record |
| --- | --- | --- | --- |
| Firelight | 2 High | **2nd** | [Immunefi leaderboard](https://immunefi.com/audit-competition/audit-comp-firelight-1/leaderboard/) |
| Quantus | 1 Critical · 1 High | **8th** | [Immunefi leaderboard](https://immunefi.com/audit-competition/audit-comp-quantus/leaderboard/) |
| Revert Finance · StableSwap Hooks | 1 High · 1 Medium | — | [Cantina leaderboard](https://cantina.xyz/competitions/e55ee7b9-6c99-42f8-8338-39f3dd134ef3/leaderboard) |
| Metric | 3 Medium | — | [Sherlock](https://audits.sherlock.xyz/watson/Tradi3) |
| Base Azul | 1 Medium | 53rd | [Immunefi leaderboard](https://immunefi.com/audit-competition/audit-comp-base-azul/leaderboard/) |
| Morpho Midnight | 1 Low | — | [Cantina finding](https://cantina.xyz/code/4679e0fa-85f7-4ea5-8827-ee6c70bdee6b/findings/652) |

[Immunefi](https://immunefi.com/profile/Tradi3/) records **5 accepted competition
reports: 1 Critical, 3 High, and 1 Medium**, with **$4,537** in total earnings as
displayed on 8 October 2026. Counts include accepted duplicate reports.

## Published Immunefi reports

These are the platform's published reports, attributed to Tradi3.

| Competition | Severity | Report |
| --- | --- | --- |
| Quantus | Critical | [#89347 — High-security account policy bypass through transaction tips](https://reports.immunefi.com/quantus-or-audit-competition/89347-bc-critical-high-security-accounts-can-be-drained-immediately-via-an-unbounded-tip-on-a-whitel) |
| Quantus | High | [#90460 — POS accepts a replaceable pool transaction as payment before execution](https://reports.immunefi.com/quantus-or-audit-competition/90460-w-a-high-quantus-pos-accepts-a-replaceable-pool-transaction-as-payment-before-execution) |
| Firelight | High | [#88281 — Collateral backing previous-period claims is reused for new cover](https://reports.immunefi.com/firelight-sep.2026-or-audit-competition/88281-sc-high-coverorderallocator-reuses-collateral-still-backing-previous-period-claims-leaving-new) |
| Firelight | High | [#88618 — Assessment approval can execute an unreviewed replacement loss schedule](https://reports.immunefi.com/firelight-sep.2026-or-audit-competition/88618-sc-high-assessment-approval-can-execute-a-replacement-loss-schedule-the-risk-consortium-never) |
| Base Azul | Medium | [#75354 — ZK witness interval mismatch makes challenge proofs unverifiable](https://reports.immunefi.com/base/75354-bc-medium-hardcoded-10-block-zk-witness-interval-makes-30-block-challenge-proofs-unverifiable) |

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
