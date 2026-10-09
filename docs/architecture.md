# Architecture

Stellar ROS Bridge sits between a ROS 2 robot graph and the Stellar network.
It is split into small crates so that the domain logic stays pure and testable,
and so that the heavy external dependencies (ROS 2 and Stellar RPC) live only
where they are needed.

## Crates

| Crate | Responsibility | External deps |
| --- | --- | --- |
| `bridge-core` | Domain types (`Capability`, `Task`, `TaskId`, `Proof`, `Reward`), traits (`Transport`, `Settlement`), error model. No I/O. | none |
| `ros-bridge` | Implements the ROS 2 side of `Transport` using `rclrs`. Publishes/subscribes to the capability, task, and proof topics. | ROS 2 (Jazzy+) |
| `stellar-bridge` | Implements the `Settlement` trait against Soroban contracts and the Stellar RPC/Horizon. Signing, submission, confirmation. | Stellar RPC |
| `bridge-node` | The runtime binary. Wires a `Transport` to a `Settlement`, runs the task lifecycle state machine. | all of the above |

The key design rule: **`bridge-core` never depends on ROS or Stellar.** Both
integrations are behind traits, which makes the lifecycle logic unit-testable
with mocks and keeps Wave issues cleanly scoped to one crate.

## Data flow

```
 robot                 ros-bridge              bridge-node              stellar-bridge        Stellar
   |  capability msg  ------>|                      |                          |                 |
   |                         |  Capability          |                          |                 |
   |                         |--------------------->|                          |                 |
   |                         |                      |  register/find task      |                 |
   |                         |                      |------------------------->|  read contract  |
   |  task request  <--------------------------------|                          |                 |
   |  (execute)  ----------->|  Task                |                          |                 |
   |                         |--------------------->|  escrow funded?          |                 |
   |                         |                      |------------------------->|                 |
   |  proof (signed) ------->|  Proof               |                          |                 |
   |                         |--------------------->|  verify + settle         |                 |
   |                         |                      |------------------------->|  release()      |
```

## Domain model (draft)

```rust
// bridge-core

pub struct Capability {
    pub id: String,          // e.g. "navigate", "pick", "inspect"
    pub version: u32,
    pub units: String,       // e.g. "per_meter", "per_pick"
    pub metadata: Metadata,  // free-form, JSON-compatible
}

pub struct Task {
    pub id: TaskId,
    pub capability: String,
    pub params: Metadata,
    pub reward: Reward,      // asset + amount
    pub deadline: Timestamp,
    pub requester: AccountId,
}

pub struct Proof {
    pub task_id: TaskId,
    pub digest: [u8; 32],    // hash of telemetry / deliverable
    pub signer: PublicKey,
    pub signature: Signature,
}

pub enum TaskState {
    Announced,
    Requested,
    Accepted,
    InProgress,
    ProofSubmitted,
    Settled,
    Disputed,
    Expired,
}
```

> The exact types are defined by the `Define the bridge-core domain model`
> issue and will move from draft to frozen once merged.

## Settlement contract (draft interface)

A single Soroban `TaskEscrow` contract is planned. Indicative entry points:

```rust
fn create_task(env, requester, capability, reward, deadline) -> TaskId;
fn accept_task(env, task_id, executor) -> Result<(), Error>;
fn submit_proof(env, task_id, proof) -> Result<(), Error>;
fn release(env, task_id) -> Result<(), Error>;
fn refund(env, task_id) -> Result<(), Error>;   // deadline passed, no valid proof
fn dispute(env, task_id) -> Result<(), Error>;  // raises for maintainer review
```

Safety invariants the contract must uphold (these become test cases):

1. Funds can leave escrow exactly once, via `release` **or** `refund` — never both.
2. `release` requires a proof whose signer is the assigned executor.
3. `refund` only succeeds after `deadline`.
4. Reentrancy is impossible (Soroban execution model) but state writes must be
   ordered so no path observes a half-updated task.

## Identity & keys

- Each robot maps to a Stellar account. The robot's signing key lives in the
  operator's environment (never in the repo).
- ROS 2 node identity is separate from the Stellar account; the bridge holds the
  mapping. Linking the two is out of scope for the first milestones.

## Local development

1. Install Rust via rustup (toolchain pinned in `rust-toolchain.toml`).
2. For ROS work: install ROS 2 Jazzy and `source /opt/ros/jazzy/setup.bash`.
3. For Stellar work: create a testnet account and fund it via friendbot; put
   the secret in an environment variable, e.g. `STELLAR_SECRET` (see `.env.example`).
4. `cargo build` builds the non-ROS crates; `cargo build -p ros-bridge`
   additionally requires a sourced ROS 2 environment.

## Cross-cutting concerns

- **Observability:** structured `tracing` spans keyed by `TaskId`.
- **Time:** all deadlines are Stellar ledger time, not wall clock, to avoid skew.
- **Failure:** a failed settlement never blocks the robot loop; tasks are
  retried or refunded per the state machine.
