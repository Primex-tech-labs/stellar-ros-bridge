# Soroban contracts

On-chain contracts for Stellar ROS Bridge, written in Rust against
[`soroban-sdk`](https://docs.rs/soroban-sdk).

Planned layout:

```
contracts/
  task-escrow/        # TaskEscrow contract: create/accept/proof/release/refund
    Cargo.toml
    src/lib.rs
    src/test.rs
```

The `TaskEscrow` contract and its tests are tracked by the "Soroban TaskEscrow
contract" Wave issue (see `.wave/issues.md`), and its safety invariants are
listed in `docs/architecture.md`.
