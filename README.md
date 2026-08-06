# Tradi3 security research

Kurt Landman, Perth, Australia. Smart contract security research full time since March 2026.

Most of my work is DeFi: accounting, AMMs, oracle integrations, access boundaries, contract
lifecycle, and the failures that only appear once several components are composed together.

This repo is an index. Every claim below links to a page I do not control, so you can check it
without taking my word for anything.

## Public profiles

| Platform | Profile | What it shows |
| --- | --- | --- |
| Cantina | [cantina.xyz/u/Tradi3](https://cantina.xyz/u/Tradi3) | 4 public findings |
| Immunefi | [immunefi.com/profile/Tradi3](https://immunefi.com/profile/Tradi3/) | 1 Medium, $367, member since 5 March 2026 |
| Sherlock | [audits.sherlock.xyz/watson/Tradi3](https://audits.sherlock.xyz/watson/Tradi3) | 1 Medium, 370 USDC |
| HackenProof | [hackenproof.com/hackers/tradi3](https://hackenproof.com/hackers/tradi3) | reputation 137, 2 influenced programs |

One caveat so nobody counts a result twice: the Immunefi row and the Sherlock row are the same
Base Azul finding displayed on two platforms. It is one Medium, not two.

## Public results

| Review | Platform | Result | Placement | Evidence |
| --- | --- | --- | --- | --- |
| Revert Finance, StableSwap Hooks | Cantina | Confirmed High | 58th of 269 | [Competition](https://cantina.xyz/code/e55ee7b9-6c99-42f8-8338-39f3dd134ef3/overview) · [Profile](https://cantina.xyz/u/Tradi3) |
| Base Azul | Immunefi | 1 Medium, $367 | 53rd | [Leaderboard](https://immunefi.com/audit-competition/audit-comp-base-azul/leaderboard/) |

The Revert Finance competition ran 30 April to 8 May 2026 against commit
`cf0c30e576f144809df9819f4d3ad49e0b7fe2d7`, drew 1,412 submissions, and paid only Highs and
Mediums against a $50,000 pool. A coded proof of concept was mandatory for every High and Medium.

## The confirmed High, published in full

**Native ETH `removeLiquidity` reentrancy lets an LP swap against withdrawn stale reserves**

Full writeup and the Foundry proof of concept:
[findings/2026-04-revert-finance-stableswap-hooks.md](findings/2026-04-revert-finance-stableswap-hooks.md)

Short version. `removeLiquidity()` sends native ETH to the LP before the hook decrements
`reserves[]` and before LP shares are burned. `poolManager.take()` forwards all gas to the
receiver, and the Uniswap v4 `PoolManager` is already unlocked at that moment, so the receiver can
call `poolManager.swap()` directly and skip the hook's nested `unlock()` guard entirely. The
reentrant swap is priced from reserves that still include the attacker's withdrawn liquidity.

In the PoC the same 9,999 ETH exact-output swap costs about 10x less input through the reentrant
path than it costs once the withdrawal is accounted for, and the honest side is left holding 1 ETH.
The existing test suite covered reentrancy through hook functions that call `unlock()` again, which
correctly reverts. It did not cover a direct swap while the manager was already unlocked.

## Work in review

Named without technical detail, because these are live and the disclosure terms are not mine to
waive. Listed so the record is complete rather than flattering.

- **Sherlock, Metric contest 1279.** Oracle-anchored DEX, 150,000 USDC pool. 10 submissions live in
  judging. Judging opened 27 July 2026.
- **Immunefi, 1inch Aqua.** Submissions in review.
- **Cantina, Morpho Midnight.** Multiple submissions, each with a Foundry PoC.
- **Cantina, Ondo Perps.** Black box web and API review of an SGX enclave backed perpetuals
  platform.

I will move anything here into the results table when it resolves, including the ones that resolve
as duplicates or invalid.

## How I decide something is worth filing

Every candidate has to clear nine gates before I write a report. Target identity, scope,
reachability, exploit proof, quantified impact, intended design, known issues, duplicates, report
quality. Nothing goes out until each one is evidenced in writing.

Most of my candidates die at the known issues gate or the duplicates gate. That is the point of
having them. A finding that dies cheaply on my machine costs a triager nothing.

## Research setup

A dedicated Kali Linux box, 8 cores, 30 GB RAM, running continuously. It carries both toolchains
because a lot of real programs need both.

- **Web3:** Foundry, Slither, Aderyn, Mythril, Echidna, Medusa, Heimdall, crytic-compile, Clarinet.
- **Web2:** Burp Suite, ZAP, nmap, sqlmap, nuclei, ffuf, gobuster, httpx, subfinder, amass, wpscan,
  hydra, Metasploit, John, hashcat.
- **Local inference** through Ollama so scoped client code never leaves the host: Foundation-Sec-8B,
  a pentest-tuned Qwen2.5-Coder, and two Modelfiles I built for triage passes.
- Deterministic helpers for the boring parts: bounty program catalogue extraction, a scope freshness
  sweep across every listed program, verified-source pulls from Blockscout, and a scope watcher that
  polls a live contest every 60 seconds and writes a diff when the target moves under me.

## Open source

- [bounty-operator-kit](https://github.com/krutftw/bounty-operator-kit) - MIT, v0.3.0. Python CLI
  that turns the gate list above into commands: scope pinning, review ledgers, Slither triage
  queues, prior art checks, and secret sanitisation before anything leaves the machine.
- [openclaw-vps-hardening](https://github.com/krutftw/openclaw-vps-hardening) - tested fail closed
  hardening for headless Ubuntu hosts.
- [vaytric-scan-demo](https://github.com/krutftw/vaytric-scan-demo) - intentionally vulnerable
  Solidity fixture used as an end to end acceptance test for scanner work.
- [fetchmux](https://github.com/krutftw/fetchmux) - self hosted retrieval router for agents with
  budgets, provider routing and signed receipts.
- [hedera-agentpay-guard](https://github.com/krutftw/hedera-agentpay-guard) - signed policy receipts
  for Hedera x402 agent payments.
- [elizaOS/eliza#17814](https://github.com/elizaOS/eliza/pull/17814) - merged CI fix restoring the
  develop branch verify gate.

## Languages and ecosystems

Solidity and EVM, Rust and Anchor on Solana, Cairo on Starknet, Clarity on Stacks, Move on Aptos,
CosmWasm.

Recent review coverage: Granite, Starknet Staking and StarkGate, Layer3, Arcadia, TruYields,
Treehouse, Twyne, Zest, TermMax, Vesu, USDN and SmarDex, Enzyme, Folks Finance, Hermetica,
Arbitrum, Balancer, Chainlink CCIP, Ethena, Spark, Optimism.

## Credentials

Certificate IV in Cyber Security (22603VIC), East Perth TAFE, Western Australia.

## Disclosure

Only finished work that is already public appears in the results table. Live submissions are named
in the review section with no technical detail. Private reports and unreleased proofs of concept
stay off this repo until they can be disclosed safely.

Contact: krutftw@gmail.com · [x.com/Tradi3_](https://x.com/Tradi3_)
