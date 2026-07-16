# Tradi3's security research

I review smart contracts and build software around prediction markets and on-chain trading.

Most of my security work is in DeFi: accounting, AMMs, oracle integrations, access boundaries, contract lifecycle bugs, and attack paths that only show up when several components are composed together.

## Public profiles

- [Sherlock](https://audits.sherlock.xyz/watson/Tradi3)
- [Cantina](https://cantina.xyz/u/Tradi3)
- [X](https://x.com/Tradi3_)

## Public results

| Review | Platform | Result | Placement | Evidence |
| --- | --- | --- | --- | --- |
| Base Azul | Immunefi | 1 valid Med/Low, $367 | 53rd | [Leaderboard](https://immunefi.com/audit-competition/audit-comp-base-azul/leaderboard/) |
| Revert Finance - StableSwap Hooks | Cantina | 1 confirmed High | 58th of 269 | [Profile](https://cantina.xyz/u/Tradi3) · [Competition](https://cantina.xyz/competitions/e55ee7b9-6c99-42f8-8338-39f3dd134ef3) |

### Confirmed public finding

**Native ETH `removeLiquidity` reentrancy lets an LP swap against withdrawn stale reserves**  
Confirmed High in the Revert Finance StableSwap Hooks review. The finding is visible on my [Cantina profile](https://cantina.xyz/u/Tradi3).

## Security tooling

- [Bounty Operator Kit](https://github.com/krutftw/bounty-operator-kit) - a local workflow for scope tracking, PoC gates, duplicate checks, and report preparation.

## Disclosure

Only finalized work that is already public is listed here. Live contests, private reports, and unreleased PoCs stay private until they can be disclosed safely.

