# Tradi3 · smart contract & blockchain security

Kurt Landman, Perth, Australia. I review DeFi contracts, blockchain runtimes, and wallet/signing systems, focusing on accounting invariants, AMMs, oracle normalization, transaction security, and access control.

[Website](https://tradi3.com/) · [Competition reports](https://tradi3.com/reports/) · [Findings JSON](https://tradi3.com/findings.json) · [Contact](mailto:hello@tradi3.com) · [Immunefi](https://immunefi.com/profile/Tradi3/) · [Cantina](https://cantina.xyz/u/Tradi3) · [Sherlock](https://audits.sherlock.xyz/watson/Tradi3)

## Competition results

| Competition | Result | Placement | Public record |
| --- | --- | --- | --- |
| ENS | 17 Critical · 1 High · 4 Medium · 1 Low | **15th of 186 listed researchers** | [Immunefi leaderboard](https://immunefi.com/audit-competition/audit-competition-ens/leaderboard/) |
| Firelight | 2 High | **2nd of 133** | [Immunefi leaderboard](https://immunefi.com/audit-competition/audit-comp-firelight-1/leaderboard/) |
| Quantus | 1 Critical · 1 High | **8th of 65** | [Immunefi leaderboard](https://immunefi.com/audit-competition/audit-comp-quantus/leaderboard/) |
| Revert Finance · StableSwap Hooks | 1 High · 1 Medium | 58th of 269 | [Cantina leaderboard](https://cantina.xyz/competitions/e55ee7b9-6c99-42f8-8338-39f3dd134ef3/leaderboard) |
| Metric | 3 Medium | 24th | [Sherlock](https://audits.sherlock.xyz/watson/Tradi3) |
| Base Azul | 1 Medium | 53rd | [Immunefi leaderboard](https://immunefi.com/audit-competition/audit-comp-base-azul/leaderboard/) |
| Morpho Midnight | 1 Low | — | [Cantina finding](https://cantina.xyz/code/4679e0fa-85f7-4ea5-8827-ee6c70bdee6b/findings/652) |

ENS credits **23 valid submissions: 1 Chief and 22 duplicates**, plus 1 separate Insight. The **17 Critical-rated submissions** are the highest Critical count among the leaderboard's 186 listed researchers. These counts include duplicates and do not represent unique vulnerabilities.

Verified on 23 November 2026, the [Immunefi profile](https://immunefi.com/profile/Tradi3/) lists **Top Ranked (#82 all time, #61 in 2026)**, with **29 published paid audit competition reports (18 Critical, 4 High, 5 Medium, 1 Low, 1 Insight)** across the published competitions above and **$5,946** in paid earnings. Only publicly published competitions are listed here; totals include accepted duplicate reports.

## Published findings & write-ups

### Immunefi published reports

| Competition | Severity | Official report | Full write-up |
| --- | --- | --- | --- |
| ENS | Critical | [#89456: Renewal route prices and displays the normalized name but signs the raw label (Chief)](https://reports.immunefi.com/ens-or-audit-competition/89456-w-a-critical-renewal-route-prices-and-displays-the-normalized-name-but-signs-the-raw-label-so) | [T3-011](https://tradi3.com/findings/t3-011-ens-renewal-normalization/) |
| Quantus | Critical | [#89347: High-security account policy bypass through transaction tips](https://reports.immunefi.com/quantus-or-audit-competition/89347-bc-critical-high-security-accounts-can-be-drained-immediately-via-an-unbounded-tip-on-a-whitel) | [T3-007](https://tradi3.com/findings/t3-007-quantus-high-security-policy/) |
| Quantus | High | [#90460: POS accepts a replaceable pool transaction as payment before execution](https://reports.immunefi.com/quantus-or-audit-competition/90460-w-a-high-quantus-pos-accepts-a-replaceable-pool-transaction-as-payment-before-execution) | [T3-008](https://tradi3.com/findings/t3-008-quantus-pos-payment-status/) |
| Firelight | High | [#88281: Collateral backing previous-period claims is reused for new cover](https://reports.immunefi.com/firelight-sep.2026-or-audit-competition/88281-sc-high-coverorderallocator-reuses-collateral-still-backing-previous-period-claims-leaving-new) | [T3-009](https://tradi3.com/findings/t3-009-firelight-collateral-accounting/) |
| Firelight | High | [#88618: Assessment approval can execute an unreviewed replacement loss schedule](https://reports.immunefi.com/firelight-sep.2026-or-audit-competition/88618-sc-high-assessment-approval-can-execute-a-replacement-loss-schedule-the-risk-consortium-never) | [T3-010](https://tradi3.com/findings/t3-010-firelight-assessment-approval/) |
| Base Azul | Medium | [#75354: ZK witness interval mismatch makes challenge proofs unverifiable](https://reports.immunefi.com/base/75354-bc-medium-hardcoded-10-block-zk-witness-interval-makes-30-block-challenge-proofs-unverifiable) | [T3-005](https://tradi3.com/findings/t3-005-base-azul/) |

### Cantina & Sherlock public write-ups

| Competition | Platform | Severity | Finding |
| --- | --- | --- | --- |
| Revert Finance · StableSwap Hooks | Cantina | High | [Native ETH `removeLiquidity` reentrancy lets an LP swap against withdrawn stale reserves](findings/2026-04-revert-finance-stableswap-hooks.md) ([Foundry PoC](findings/RemoveLiquidityReentrancyPoC.t.sol)) |
| Metric | Sherlock | Medium | [T3-002: Price velocity guard can be bypassed by splitting a same-block price move](https://tradi3.com/findings/t3-002-metric-velocity-guard/) |
| Metric | Sherlock | Medium | [T3-003: Fixed-E8 synthetic-ratio truncation lets traders take 47.83% of one-sided RSR/cbBTC LP principal](https://tradi3.com/findings/t3-003-metric-e8-truncation/) |
| Metric | Sherlock | Medium | [T3-004: Fixed-E8 Pyth normalization underprices standard Base MOG/USDC and transfers 5.28% of LP principal](https://tradi3.com/findings/t3-004-metric-pyth-normalization/) |
| Morpho Midnight | Cantina | Low | [T3-001: MidnightBundles `minUnits` check can pass before callback-created loss slashes received credit](https://tradi3.com/findings/t3-001-morpho-midnight-minunits/) |

## Research tooling

**[Bounty Operator](https://bountyoperator.com/)**: evidence-checked pre-submission review for bug bounty reports and smart contract findings, with file-and-line citations, counterarguments, SHA-256 review packets, and MCP agent tools. [Source](https://github.com/bountyoperator/bounty-operator).

## Background

Certificate IV in Cyber Security (22603VIC), East Perth TAFE, Western Australia.
