# Stellar Wave — issue backlog

These are the genuine, Wave-sized issues for the current cycle. Each is written
following `docs/issue-guide.md`. Copy the body into GitHub using the **Wave
task** template, apply the labels, and assign one contributor per issue.

Points: **Trivial = 100**, **Medium = 150**, **High = 200**.

Legend: `⭐ = good first issue`

---

## W-01 — Document the bridge message schema with examples

**Labels:** `Stellar Wave`, `documentation`, `area: docs`, `complexity: trivial` ⭐
**Points:** 100

### Description
Write `docs/messages.md` describing the ROS 2 message schema the bridge will
publish and consume: `Capability`, `Task`, `TaskRequest`, and `Proof`. This
gives contributors and robot authors a single reference before the types are
frozen in code.

### Requirements and context
- Cover each message: purpose, fields, types, units, and an example JSON payload.
- Cross-reference the draft types in `docs/architecture.md#domain-model-draft`.
- State which messages are robot→bridge vs bridge→robot.
- Definition of done: a new contributor can read the doc and understand the
  contract without reading Rust code.

### Suggested execution
- Branch: `docs/message-schema`
- Add `docs/messages.md`; link it from `README.md` and `docs/architecture.md`.

### Implement changes
- `docs/messages.md` with one section per message and a worked end-to-end example.
- Update the docs table in `README.md`.

### Test and commit
- No code tests; verify all internal doc links resolve.
- PR description includes the rendered doc outline.

### Example commit message
`docs: add ROS 2 message schema reference`

### Guidelines
- Assignment required before starting.
- PR description must include: `Closes #<issue_id>`.

---

## W-02 — Add SECURITY.md and .env.example

**Labels:** `Stellar Wave`, `documentation`, `complexity: trivial` ⭐
**Points:** 100

### Description
Contributors touching signing or settlement need clear guidance on reporting
vulnerabilities and on handling keys. Add a `SECURITY.md` (private disclosure
process) and a committed `.env.example` documenting required environment
variables.

### Requirements and context
- `SECURITY.md`: how to report privately, what is in scope, response expectations.
- `.env.example`: list `STELLAR_SECRET`, `STELLAR_RPC_URL`, `STELLAR_NETWORK`,
  `ROS_DOMAIN_ID` with safe placeholder values and comments.
- Must not contain any real keys.

### Suggested execution
- Branch: `docs/security-and-env`
- Add both files at repo root; reference them from `README.md`.

### Implement changes
- `SECURITY.md`
- `.env.example`

### Test and commit
- Confirm `.env` (not `.env.example`) is gitignored in `.gitignore`.
- Confirm no secret-like strings are present.

### Example commit message
`docs: add security policy and env example`

### Guidelines
- Assignment required before starting.
- PR description must include: `Closes #<issue_id>`.

---

## W-03 — Configure `cargo-deny` for licenses and advisories

**Labels:** `Stellar Wave`, `area: docs`, `complexity: trivial`
**Points:** 100

### Description
Add a `deny.toml` and a CI step so the workspace fails on disallowed licenses,
known advisories, and duplicate/banned crates.

### Requirements and context
- Allow `Apache-2.0`, `MIT`, and common permissive licenses; deny copyleft.
- Wire it into `.github/workflows/ci.yml` as a separate job.
- Definition of done: `cargo deny check` passes locally and in CI.

### Suggested execution
- Branch: `chore/cargo-deny`
- Add `deny.toml`; add a `deny` job to CI.

### Implement changes
- `deny.toml`
- CI job running `EmbarkStudios/cargo-deny-action`.

### Test and commit
- Paste local `cargo deny check` output in the PR.

### Example commit message
`chore: add cargo-deny license and advisory checks`

### Guidelines
- Assignment required before starting.
- PR description must include: `Closes #<issue_id>`.

---

## W-04 — Implement `Capability` and `Task` domain types

**Labels:** `Stellar Wave`, `area: core`, `complexity: medium`
**Points:** 150

### Description
Implement the core domain types in `bridge-core` based on the draft in
`docs/architecture.md`: `Capability`, `Task`, `TaskId`, `Reward`, `AccountId`,
`Timestamp`, plus the error model. These are the foundation every other crate
depends on.

### Requirements and context
- Types must derive `Serialize`/`Deserialize` and `Debug`/`Clone`/`PartialEq`.
- Enforce invariants in constructors (e.g. non-empty capability id, reward > 0).
- No dependency on ROS or Stellar in this crate.
- Definition of done: round-trip and invariant tests pass.

### Suggested execution
- Branch: `feat/core-domain-types`
- Touch `crates/bridge-core/src/{lib.rs,types.rs,error.rs}`.

### Implement changes
- Types + constructors + `thiserror`-based error enum.
- Unit tests for serde round trip and each invariant violation.

### Test and commit
- `cargo test -p bridge-core`
- Paste test output in the PR.

### Example commit message
`feat(core): add Capability, Task, and error domain types`

### Guidelines
- Assignment required before starting.
- PR description must include: `Closes #<issue_id>`.

---

## W-05 — Stellar testnet bootstrap script

**Labels:** `Stellar Wave`, `area: stellar`, `complexity: medium`
**Points:** 150

### Description
Add a script (`scripts/bootstrap-testnet.sh` or a small Rust bin) that creates a
testnet keypair, funds it via friendbot, and prints the public key plus a
redacted secret reference. It removes friction from every Stellar-related task.

### Requirements and context
- Must never print or write the raw secret to disk by default; use an env var.
- Idempotent: re-running does not error.
- Configurable RPC/horizon URL via env with sane defaults.

### Suggested execution
- Branch: `feat/testnet-bootstrap`
- Add script under `scripts/`; document usage in `docs/architecture.md`.

### Implement changes
- Bootstrap script + usage docs.

### Test and commit
- Run against testnet; include the public key and command output in the PR.

### Example commit message
`feat(tools): add Stellar testnet bootstrap script`

### Guidelines
- Assignment required before starting.
- PR description must include: `Closes #<issue_id>`.

---

## W-06 — `stellar-bridge` escrow client with mocked RPC tests

**Labels:** `Stellar Wave`, `area: stellar`, `complexity: medium`
**Points:** 150

### Description
Implement the `Settlement` trait for `stellar-bridge`: `create_task`,
`accept_task`, `submit_proof`, `release`, `refund`. Back it with a trait-based
RPC layer so tests use a mock instead of a live network.

### Requirements and context
- No live network calls in unit tests; abstract the RPC behind a trait.
- Map RPC/contract errors into `bridge-core` errors.
- Definition of done: happy path and error path covered by mock tests.

### Suggested execution
- Branch: `feat/stellar-settlement-client`
- Touch `crates/stellar-bridge/src/{lib.rs,client.rs,rpc.rs}`.

### Implement changes
- `Settlement` implementation + mockable RPC trait + tests.

### Test and commit
- `cargo test -p stellar-bridge`
- Paste output; list covered error cases.

### Example commit message
`feat(stellar): add escrow settlement client with mockable RPC`

### Guidelines
- Assignment required before starting.
- PR description must include: `Closes #<issue_id>`.

---

## W-07 — Mock transport and node integration harness

**Labels:** `Stellar Wave`, `area: node`, `complexity: medium`
**Points:** 150

### Description
Provide an in-memory `Transport` mock and a test harness that drives the
`bridge-node` lifecycle with scripted capability/task/proof events, so the state
machine can be tested without ROS or Stellar.

### Requirements and context
- Depends on the `Transport` trait (W-04/W-08 direction) and the state machine.
- Harness should let a test assert the exact sequence of state transitions.
- Definition of done: at least one end-to-end happy-path test and one expiry test.

### Suggested execution
- Branch: `test/node-harness`
- Touch `crates/bridge-core/src/transport.rs` and `crates/bridge-node/tests/`.

### Implement changes
- `MockTransport`, a small `Harness` helper, and integration tests.

### Test and commit
- `cargo test -p bridge-node`
- Paste output.

### Example commit message
`test(node): add mock transport and lifecycle harness`

### Guidelines
- Assignment required before starting.
- PR description must include: `Closes #<issue_id>`.

---

## W-08 — Implement the `bridge-node` task lifecycle state machine

**Labels:** `Stellar Wave`, `area: node`, `area: core`, `complexity: high`
**Points:** 200

### Description
Implement the runtime state machine in `bridge-node` that consumes a
`Transport` and a `Settlement`: `Announced → Requested → Accepted → InProgress
→ ProofSubmitted → Settled`, with `Expired`/`Disputed` branches.

### Requirements and context
- Pure state transitions live in a testable unit, separate from the async driver.
- Invalid transitions return an error, never panic.
- Timeouts are driven by Stellar ledger time, not wall clock.
- Definition of done: every state and invalid transition has a test; the async
  driver is covered by the W-07 harness.

### Suggested execution
- Branch: `feat/task-state-machine`
- Touch `crates/bridge-core/src/state.rs` and `crates/bridge-node/src/lib.rs`.

### Implement changes
- State machine + transition table + tests. Wire the async driver behind a
  `Transport`/`Settlement` pair.

### Test and commit
- `cargo test --workspace`
- Paste output; include a transition-table diagram in the PR.

### Example commit message
`feat(node): implement task lifecycle state machine`

### Guidelines
- Assignment required before starting.
- PR description must include: `Closes #<issue_id>`.

---

## W-09 — Soroban `TaskEscrow` contract with safety invariants and tests

**Labels:** `Stellar Wave`, `area: stellar`, `complexity: high`
**Points:** 200

### Description
Implement the `TaskEscrow` Soroban contract (Rust, `soroban-sdk`) with
`create_task`, `accept_task`, `submit_proof`, `release`, and `refund`, and tests
for the four safety invariants in `docs/architecture.md`.

### Requirements and context
- Enforce: funds leave escrow exactly once (release XOR refund); release
  requires the assigned executor's proof; refund only after deadline;
  no half-updated state is observable.
- Use `soroban-sdk` testutils for unit tests; include at least one
  authorization-failure test.
- Definition of done: all invariants have a failing-without-fix test.

### Suggested execution
- Branch: `feat/task-escrow-contract`
- Add `contracts/task-escrow/` with `Cargo.toml`, `src/lib.rs`, `src/test.rs`.

### Implement changes
- Contract + tests. Document entry points in `docs/architecture.md`.

### Test and commit
- `cargo test -p task-escrow`
- Paste output; explicitly map each test to an invariant.

### Example commit message
`feat(contract): implement TaskEscrow with invariant tests`

### Guidelines
- Assignment required before starting.
- PR description must include: `Closes #<issue_id>`.

---

## W-10 — ROS 2 `rclrs` transport for capability/task/proof topics

**Labels:** `Stellar Wave`, `area: ros`, `complexity: high`
**Points:** 200

### Description
Implement the ROS 2 side of the `Transport` trait using `rclrs`: subscribe to
`/robot/capabilities`, receive tasks, and publish proofs. Provide an example
node and a launch file so a robot can be simulated end to end.

### Requirements and context
- Gate behind a `ros` feature so the workspace still builds without ROS.
- Message types must match `docs/messages.md` (W-01).
- Requires a sourced ROS 2 Jazzy environment to build.
- Definition of done: `cargo build -p ros-bridge` succeeds with ROS sourced, and
  an example publishes a capability that the node logs.

### Suggested execution
- Branch: `feat/ros2-rclrs-transport`
- Touch `crates/ros-bridge/src/lib.rs`; add `examples/` and a launch file.

### Implement changes
- `rclrs` transport, example node, launch file, and build docs.

### Test and commit
- Build under ROS 2 Jazzy; paste `cargo build -p ros-bridge` output and a short
  terminal capture of the example running.

### Example commit message
`feat(ros): add rclrs transport for capability/task/proof`

### Guidelines
- Assignment required before starting.
- PR description must include: `Closes #<issue_id>`.
