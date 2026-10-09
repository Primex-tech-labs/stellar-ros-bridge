# Creates labels and the Stellar Wave backlog on GitHub.
#
# Usage (PowerShell):
#   $env:GH_TOKEN = "<token>"
#   ./scripts/github-backlog.ps1
#
# The token is read from the environment and never written to disk or committed.
# Re-running is safe: labels that exist are skipped, and issues are matched by title.

param(
    [string]$Owner = 'Primex-tech-labs',
    [string]$Repo = 'stellar-ros-bridge',
    [switch]$LabelsOnly,
    [switch]$IssuesOnly
)

$ErrorActionPreference = 'Stop'
$Token = $env:GH_TOKEN
if (-not $Token) { throw "Set GH_TOKEN in the environment first." }

$Headers = @{
    Authorization          = "Bearer $Token"
    'User-Agent'           = 'stellar-ros-bridge-backlog'
    Accept                 = 'application/vnd.github+json'
    'X-GitHub-Api-Version' = '2022-11-28'
}
$Api = "https://api.github.com/repos/$Owner/$Repo"

$labels = @(
    @{ name = 'Stellar Wave';      color = '7c3aed'; description = 'In scope for the current Stellar Wave program.' },
    @{ name = 'good first issue';  color = '7057ff'; description = 'Good for newcomers.' },
    @{ name = 'task';              color = '0e8a16'; description = 'Scoped work item.' },
    @{ name = 'enhancement';       color = 'a2eeef'; description = 'New feature or request.' },
    @{ name = 'documentation';     color = '0075ca'; description = 'Docs improvements.' },
    @{ name = 'complexity: trivial'; color = 'c2e0c6'; description = 'Trivial - 100 Wave points.' },
    @{ name = 'complexity: medium';  color = 'bfd4f2'; description = 'Medium - 150 Wave points.' },
    @{ name = 'complexity: high';    color = 'f9d0c4'; description = 'High - 200 Wave points.' },
    @{ name = 'area: core';        color = '5319e7'; description = 'bridge-core domain model.' },
    @{ name = 'area: ros';         color = '1d76db'; description = 'ROS 2 integration.' },
    @{ name = 'area: stellar';     color = '0052cc'; description = 'Stellar / Soroban integration.' },
    @{ name = 'area: contracts';   color = 'b60205'; description = 'Soroban smart contracts.' },
    @{ name = 'area: node';        color = '006b75'; description = 'bridge-node runtime.' },
    @{ name = 'area: ci';          color = 'ededed'; description = 'Build, CI, and developer tooling.' },
    @{ name = 'area: docs';        color = '0075ca'; description = 'Documentation and guides.' },
    @{ name = 'area: security';    color = '111111'; description = 'Security, threat modeling, hardening.' }
)

$P = @'
**Description**
{0}

**Requirements & context**
{1}

**Deliverables**
{2}

**Verification**
{3}

**Points:** {4}. Assignment required before starting; PR must include `Closes #<issue_id>`.
'@

function New-Issue($title, $labels, $points, $desc, $req, $deliv, $verify) {
    @{
        title  = $title
        labels = @('Stellar Wave', 'task') + $labels
        body   = ($P -f $desc, $req, $deliv, $verify, $points).Trim()
    }
}

$issues = @(
    # ---------------- CI / tooling ----------------
    (New-Issue 'Add .editorconfig for consistent whitespace' @('area: ci','complexity: trivial','good first issue') '100 (trivial)' @'
Standardize indentation, line endings, and final-newline behavior across editors.
'@ @'
- Rust = 4 spaces; Markdown/YAML = 2 spaces; LF line endings.
- Editors with an EditorConfig plugin should pick this up automatically.
'@ @'
- `.editorconfig` at repo root.
'@ @'
- Open a few files in two different editors and confirm consistent formatting.
'@),

    (New-Issue 'Add Dependabot config for crates and GitHub Actions' @('area: ci','complexity: trivial') '100 (trivial)' @'
Keep dependencies patched automatically.
'@ @'
- Weekly updates for the `cargo` and `github-actions` ecosystems.
- Group minor/patch updates to reduce PR noise.
'@ @'
- `.github/dependabot.yml`.
'@ @'
- Validate the YAML and confirm Dependabot recognizes it in the repo settings.
'@),

    (New-Issue 'Add CODEOWNERS for area-based review' @('area: ci','complexity: trivial','good first issue') '100 (trivial)' @'
Route reviews to the right people as the team grows.
'@ @'
- Map `crates/ros-bridge`, `crates/stellar-bridge`, `contracts/`, and `docs/` to owners.
- Default owner is the org maintainers.
'@ @'
- `.github/CODEOWNERS`.
'@ @'
- Open a test PR touching a mapped path and confirm the reviewer is auto-requested.
'@),

    (New-Issue 'Add MSRV CI job pinned to Rust 1.83' @('area: ci','complexity: trivial') '100 (trivial)' @'
Guarantee the crate keeps building on the minimum supported Rust version.
'@ @'
- MSRV is 1.83 (see `rust-toolchain.toml` and `Cargo.toml`).
- Job runs `cargo build --workspace` with the pinned toolchain.
'@ @'
- New `msrv` job in `.github/workflows/ci.yml`.
'@ @'
- CI passes on the MSRV job; intentionally breaking MSRV fails it.
'@),

    (New-Issue 'Add coverage reporting with cargo-llvm-cov' @('area: ci','complexity: medium') '150 (medium)' @'
Make test coverage visible and track regressions.
'@ @'
- Use `cargo-llvm-cov`; upload to Codecov or as a CI artifact.
- Restrict to the non-ROS crates for now.
'@ @'
- CI step + badge in `README.md` + a short note in `CONTRIBUTING.md`.
'@ @'
- Coverage report appears on a PR; badge renders.
'@),

    (New-Issue 'Add a justfile of common developer commands' @('area: ci','complexity: medium','good first issue') '150 (medium)' @'
Give contributors one entry point for build/test/lint/docs.
'@ @'
- Recipes: `build`, `test`, `lint`, `fmt`, `docs`, `deny`, `clean`.
- Document usage in `CONTRIBUTING.md`.
'@ @'
- `justfile` plus a `CONTRIBUTING.md` section.
'@ @'
- `just test` and `just lint` reproduce the CI commands locally.
'@),

    (New-Issue 'Add scheduled cargo-audit security scan' @('area: ci','area: security','complexity: medium') '150 (medium)' @'
Continuously detect known-vulnerable dependencies.
'@ @'
- Run weekly and on `Cargo.lock` changes.
- Fail the job on findings; open an issue automatically if desired.
'@ @'
- Workflow + documented response process in `SECURITY.md`.
'@ @'
- Trigger the workflow manually and confirm it reports clearly.
'@),

    (New-Issue 'Add a release workflow that tags and builds artifacts' @('area: ci','complexity: medium') '150 (medium)' @'
Produce reproducible releases for `bridge-node`.
'@ @'
- Trigger on `v*` tags; build release binaries and attach them.
- Keeps the pipeline ready for signed releases later.
'@ @'
- `.github/workflows/release.yml` + a short `docs/releasing.md`.
'@ @'
- Dry-run on a pre-release tag in a fork; artifacts attached.
'@),

    # ---------------- bridge-core ----------------
    (New-Issue 'Add TaskId newtype with validation' @('area: core','complexity: trivial','good first issue') '100 (trivial)' @'
Give tasks a typed identity instead of raw strings.
'@ @'
- Non-empty, bounded length; `Serialize`/`Deserialize`; `Display`.
- Constructors return an error on invalid input.
'@ @'
- `TaskId` in `crates/bridge-core` with unit tests for valid/invalid cases.
'@ @'
- `cargo test -p bridge-core` passes; invalid inputs rejected.
'@),

    (New-Issue 'Add AccountId with Stellar StrKey validation' @('area: core','area: stellar','complexity: medium') '150 (medium)' @'
Represent Stellar accounts safely in the domain layer.
'@ @'
- Validate `G...` public keys with the correct checksum.
- Keep it dependency-light; no network calls.
'@ @'
- `AccountId` type + test vectors (including bad checksums).
'@ @'
- Round-trip and rejection tests pass.
'@),

    (New-Issue 'Add Reward type with checked arithmetic' @('area: core','area: stellar','complexity: medium') '150 (medium)' @'
Model a payable amount plus asset without overflow or precision bugs.
'@ @'
- Asset id + integer amount (stroops); checked add/sub; reject zero/negative.
- No floating point.
'@ @'
- `Reward` type + arithmetic error cases.
'@ @'
- Tests cover overflow, underflow, and zero.
'@),

    (New-Issue 'Add Proof type and ProofVerifier trait' @('area: core','area: security','complexity: medium') '150 (medium)' @'
Define how task completion is proven, independent of transport.
'@ @'
- `Proof` holds task id, digest, signer, signature.
- `ProofVerifier` trait so implementations (testnet, mocks) are swappable.
'@ @'
- Types + trait + a mock verifier used in tests.
'@ @'
- Unit tests for verify accept/reject.
'@),

    (New-Issue 'Define the Transport trait' @('area: core','complexity: medium') '150 (medium)' @'
Abstract the robot-facing side so the node can be tested without ROS.
'@ @'
- Methods to receive capabilities/tasks and publish proofs.
- Async-friendly but runtime-agnostic.
'@ @'
- `Transport` trait + doc examples.
'@ @'
- A mock implements it in tests (see the node harness issue).
'@),

    (New-Issue 'Define the Settlement trait' @('area: core','area: stellar','complexity: medium') '150 (medium)' @'
Abstract the chain-facing side behind a trait.
'@ @'
- Methods: create/accept/submit_proof/release/refund.
- Return domain errors, never transport errors.
'@ @'
- `Settlement` trait + doc examples.
'@ @'
- A mock implements it in tests.
'@),

    (New-Issue 'Add central Error enum and error-code mapping' @('area: core','complexity: medium') '150 (medium)' @'
One error taxonomy for the whole workspace.
'@ @'
- `thiserror`-based enum covering domain, transport, and settlement failures.
- Map to stable codes for logging and (later) contract errors.
'@ @'
- `error.rs` + conversions from common error types.
'@ @'
- Tests assert codes for representative failures.
'@),

    (New-Issue 'Add a Timestamp abstraction over ledger time' @('area: core','area: stellar','complexity: medium') '150 (medium)' @'
Avoid wall-clock skew by drawing deadlines from ledger time.
'@ @'
- `Timestamp` newtype + a `Clock` trait with a mock.
- Deadlines compare against ledger close time.
'@ @'
- Types + `Clock` trait + mock clock.
'@ @'
- Tests for before/at/after deadline.
'@),

    (New-Issue 'Add a bounded Metadata JSON map type' @('area: core','complexity: trivial','good first issue') '100 (trivial)' @'
Carry free-form task/capability parameters safely.
'@ @'
- JSON-compatible map with a max serialized size.
- Reject oversized payloads with a clear error.
'@ @'
- `Metadata` type + size-limit test.
'@ @'
- Tests cover boundary sizes.
'@),

    (New-Issue 'Add schema_version to wire types' @('area: core','complexity: medium') '150 (medium)' @'
Enable forward/backward-compatible message evolution.
'@ @'
- Add a `schema_version` field and document the compatibility policy.
- Decide and document how unknown fields are handled.
'@ @'
- Field added to wire types + `docs/messages.md` section.
'@ @'
- Tests: old payload without the field still deserializes.
'@),

    (New-Issue 'Add proptest suite for domain invariants' @('area: core','complexity: medium') '150 (medium)' @'
Catch edge cases that example-based tests miss.
'@ @'
- Round-trip serde for all core types.
- Constructor invariants never panic on arbitrary input.
'@ @'
- `proptest` dev-dependency + property tests.
'@ @'
- `cargo test -p bridge-core` runs the property tests.
'@),

    (New-Issue 'Extract shared validation usable by contracts' @('area: core','area: contracts','complexity: medium') '150 (medium)' @'
Keep off-chain and on-chain validation rules in sync.
'@ @'
- Pure functions for the checks the escrow contract must enforce.
- No `std`-only dependencies so the logic can be reused in Soroban.
'@ @'
- `validation` module + tests.
'@ @'
- Contract tests (later) reuse the same rules.
'@),

    (New-Issue 'Add the TaskState transition table in core' @('area: core','area: node','complexity: high') '200 (high)' @'
Encode the legal task lifecycle transitions as data, not scattered matches.
'@ @'
- States: Announced, Requested, Accepted, InProgress, ProofSubmitted, Settled, Disputed, Expired.
- Invalid transitions return an error, never panic.
'@ @'
- `TaskState` + `transition()` + exhaustive tests.
'@ @'
- Every state and invalid transition is covered.
'@),

    # ---------------- Soroban contracts ----------------
    (New-Issue 'Scaffold the contracts/task-escrow crate' @('area: contracts','complexity: medium') '150 (medium)' @'
Stand up the Soroban contract crate so entry points can be added.
'@ @'
- `soroban-sdk`, `contractttype`, and `testutils` wired up.
- Compiles to `wasm32-unknown-unknown`.
'@ @'
- `contracts/task-escrow/{Cargo.toml,src/lib.rs,src/test.rs}` + workspace note.
'@ @'
- `cargo build -p task-escrow --target wasm32-unknown-unknown` succeeds.
'@),

    (New-Issue 'Implement TaskEscrow create_task' @('area: contracts','area: stellar','complexity: high') '200 (high)' @'
Allow a requester to open an escrowed task.
'@ @'
- Validate reward > 0, deadline in the future (ledger time).
- Transfer/authorize the reward into contract custody.
'@ @'
- `create_task` with tests for success and each rejection.
'@ @'
- Auth failure, zero reward, and past deadline all covered.
'@),

    (New-Issue 'Implement TaskEscrow accept_task with authorization' @('area: contracts','complexity: high') '200 (high)' @'
Let exactly one executor claim a task.
'@ @'
- Only the executor can accept; the requester cannot accept their own task.
- A task can be accepted only once.
'@ @'
- `accept_task` + tests for double-accept and wrong-caller.
'@ @'
- Both abuse cases fail as expected.
'@),

    (New-Issue 'Implement TaskEscrow submit_proof with signature verification' @('area: contracts','area: security','complexity: high') '200 (high)' @'
Record verifiable evidence that the work is done.
'@ @'
- Verify the proof signer equals the assigned executor.
- Store the digest for later release checks.
'@ @'
- `submit_proof` + tests for valid/invalid signatures.
'@ @'
- Forged proofs are rejected.
'@),

    (New-Issue 'Implement TaskEscrow release with once-only invariant' @('area: contracts','area: security','complexity: high') '200 (high)' @'
Pay the executor exactly once on success.
'@ @'
- Requires a valid submitted proof; transfers custody to the executor.
- Cannot run after refund; cannot run twice.
'@ @'
- `release` + tests for double-release and release-after-refund.
'@ @'
- Invariant "funds leave escrow once" holds under tests.
'@),

    (New-Issue 'Implement TaskEscrow refund after deadline' @('area: contracts','complexity: high') '200 (high)' @'
Return funds to the requester when a task expires.
'@ @'
- Only after deadline and only if not already settled.
- Cannot run after release.
'@ @'
- `refund` + tests for early refund and refund-after-release.
'@ @'
- Both rejections tested.
'@),

    (New-Issue 'Implement the TaskEscrow dispute path' @('area: contracts','complexity: high') '200 (high)' @'
Provide an escape hatch when requester and executor disagree.
'@ @'
- `dispute` freezes the task in a non-settling state for review.
- Document who can resolve and how (admin function).
'@ @'
- `dispute` + resolve entry point + tests.
'@ @'
- Disputed tasks cannot be released or refunded until resolved.
'@),

    (New-Issue 'Emit contract events for task lifecycle' @('area: contracts','complexity: medium') '150 (medium)' @'
Let indexers and the bridge observe state changes.
'@ @'
- Emit events on create/accept/proof/release/refund/dispute.
- Stable topic + payload schema documented.
'@ @'
- Event emission + `docs/architecture.md` event table.
'@ @'
- Tests assert events are emitted with expected topics.
'@),

    (New-Issue 'Add storage TTL extension for active tasks' @('area: contracts','complexity: medium') '150 (medium)' @'
Prevent active task state from expiring mid-flight.
'@ @'
- Extend instance/persistent storage TTL on writes.
- Document the TTL strategy.
'@ @'
- TTL bump logic + test.
'@ @'
- Long-lived task stays readable across ledger advances.
'@),

    (New-Issue 'Add contract integration tests with testutils' @('area: contracts','complexity: medium') '150 (medium)' @'
Exercise full lifecycles, not just single calls.
'@ @'
- Happy path, expiry, and dispute scenarios end-to-end.
- Assert balances before/after.
'@ @'
- Integration tests in `contracts/task-escrow/src/test.rs`.
'@ @'
- All scenarios pass in `cargo test -p task-escrow`.
'@),

    (New-Issue 'Add negative and fuzz tests for escrow math' @('area: contracts','area: security','complexity: high') '200 (high)' @'
Prove the escrow cannot be drained or duplicated.
'@ @'
- Fuzz amounts, orderings, and repeated calls.
- Assert total conserved across all paths.
'@ @'
- Fuzz targets + conservation property.
'@ @'
- No sequence of calls violates conservation.
'@),

    (New-Issue 'Add replay protection for submitted proofs' @('area: contracts','area: security','complexity: high') '200 (high)' @'
Stop a valid proof from being reused across tasks.
'@ @'
- Bind a proof to a single task id (and optionally a nonce).
- Reject reuse.
'@ @'
- Binding check + tests for cross-task replay.
'@ @'
- Replayed proofs are rejected.
'@),

    (New-Issue 'Add fee-bump support for sponsored tasks' @('area: stellar','complexity: high') '200 (high)' @'
Let a funder cover fees so robots need no XLM to start.
'@ @'
- Build and submit fee-bump transactions.
- Document the sponsorship model and limits.
'@ @'
- Fee-bump helper + `docs/architecture.md` section.
'@ @'
- Testnet test where the relayer pays the fee.
'@),

    (New-Issue 'Add asset handling for XLM and issued assets' @('area: stellar','complexity: medium') '150 (medium)' @'
Support rewards in native and issued assets.
'@ @'
- Represent asset id in `Reward`; map to Stellar asset codes/issuers.
- Validate trustlines for issued assets.
'@ @'
- Asset conversion helpers + tests.
'@ @'
- Tests for native vs issued round trips.
'@),

    (New-Issue 'Add contract deploy and wasm-optimize script' @('area: contracts','complexity: medium') '150 (medium)' @'
Make deploying the escrow repeatable.
'@ @'
- Build with `wasm32-unknown-unknown`, run `wasm-opt`, deploy to testnet.
- Print the contract id; keep secrets in env only.
'@ @'
- `scripts/deploy-escrow.ps1` (or `.sh`) + docs.
'@ @'
- Deploy to testnet and record the contract id output.
'@),

    (New-Issue 'Guard against mainnet use in tests and local runs' @('area: contracts','area: security','complexity: trivial') '100 (trivial)' @'
Prevent accidental real-money operations.
'@ @'
- Refuse to run unless network is explicitly allow-listed.
- Loud error message pointing at testnet.
'@ @'
- Network guard in the deploy script and bridge config.
'@ @'
- Tests/local runs abort on mainnet configuration.
'@),

    (New-Issue 'Implement the stellar-bridge RPC client trait' @('area: stellar','complexity: medium') '150 (medium)' @'
Make the chain calls mockable so tests need no network.
'@ @'
- Trait with the RPC operations the bridge needs.
- Real impl + in-memory mock.
'@ @'
- `rpc.rs` with trait + mock.
'@ @'
- Unit tests run fully offline.
'@),

    (New-Issue 'Implement transaction build, sign, and submit pipeline' @('area: stellar','complexity: high') '200 (high)' @'
Turn intent into a submitted transaction.
'@ @'
- Build operations, attach fees/sequence, sign, submit.
- Surface submission errors with context.
'@ @'
- Pipeline in `stellar-bridge` + tests against the mock.
'@ @'
- Happy path + rejected-transaction path tested.
'@),

    (New-Issue 'Implement confirmation polling with backoff' @('area: stellar','complexity: medium') '150 (medium)' @'
Know when a submitted transaction is final.
'@ @'
- Poll with bounded exponential backoff and a timeout.
- Return a clear timeout error.
'@ @'
- Confirmation helper + tests with a mock clock.
'@ @'
- Success, failure, and timeout covered.
'@),

    (New-Issue 'Implement account sequence management' @('area: stellar','complexity: medium') '150 (medium)' @'
Avoid sequence-number collisions under concurrency.
'@ @'
- Track and reserve sequences; recover from `tx_bad_seq`.
- Document the concurrency model.
'@ @'
- Sequence manager + tests.
'@ @'
- Concurrent submissions do not clash in tests.
'@),

    (New-Issue 'Add a secret-key loader with redaction' @('area: stellar','area: security','complexity: trivial','good first issue') '100 (trivial)' @'
Load signing keys from the environment without leaking them.
'@ @'
- Read `STELLAR_SECRET`; never log or `Debug`-print it.
- Fail fast with an actionable message when missing.
'@ @'
- Loader + `Debug` redaction test.
'@ @'
- Key never appears in logs or panic output.
'@),

    (New-Issue 'Add a ledger-time clock provider' @('area: stellar','complexity: medium') '150 (medium)' @'
Feed real ledger time into the domain `Clock`.
'@ @'
- Implement `Clock` using the latest ledger close time.
- Cache briefly to avoid hammering RPC.
'@ @'
- Provider + mockable wrapper + tests.
'@ @'
- Clock returns monotonic ledger time.
'@),

    # ---------------- ROS 2 ----------------
    (New-Issue 'Add ROS 2 message definitions for capability, task, and proof' @('area: ros','complexity: medium') '150 (medium)' @'
Define the wire contract between robots and the bridge.
'@ @'
- `.msg`/IDL definitions matching `docs/messages.md`.
- Generated bindings usable from `rclrs`.
'@ @'
- Message package + build docs.
'@ @'
- Messages build under ROS 2 Jazzy.
'@),

    (New-Issue 'Implement the capability publisher' @('area: ros','complexity: medium') '150 (medium)' @'
Let a robot advertise what it can do.
'@ @'
- Publish `Capability` on `/robot/capabilities`.
- Configurable topic and rate.
'@ @'
- Publisher behind the `ros` feature + test.
'@ @'
- `cargo build -p ros-bridge --features ros` with ROS sourced.
'@),

    (New-Issue 'Implement the incoming-task subscriber' @('area: ros','complexity: medium') '150 (medium)' @'
Receive work assigned to the robot.
'@ @'
- Subscribe to the task topic and forward into `Transport`.
- Validate messages before handing off.
'@ @'
- Subscriber behind the `ros` feature + test.
'@ @'
- Valid messages flow; malformed ones are rejected.
'@),

    (New-Issue 'Implement the proof publisher' @('area: ros','complexity: medium') '150 (medium)' @'
Report completion evidence back to the bridge.
'@ @'
- Publish `Proof` on `/robot/proofs`.
- Carry the task id and digest.
'@ @'
- Publisher behind the `ros` feature + test.
'@ @'
- Proof round-trips through a subscriber in tests.
'@),

    (New-Issue 'Add QoS profile configuration for bridge topics' @('area: ros','complexity: medium') '150 (medium)' @'
Match reliability/latency needs per topic.
'@ @'
- Reliable for tasks/proofs; best-effort for high-rate telemetry.
- Configurable via parameters.
'@ @'
- QoS config + docs.
'@ @'
- Behavior matches the configured profile in tests.
'@),

    (New-Issue 'Add node parameter configuration for topics and domain' @('area: ros','complexity: trivial','good first issue') '100 (trivial)' @'
Make the node configurable without recompiling.
'@ @'
- Parameters for topic names and `ROS_DOMAIN_ID`.
- Sane defaults matching the docs.
'@ @'
- Parameter parsing + example params file.
'@ @'
- Node honors overridden parameters.
'@),

    (New-Issue 'Add an example robot package that advertises a capability' @('area: ros','complexity: medium') '150 (medium)' @'
Give newcomers a runnable starting point.
'@ @'
- Simulated robot publishes a `navigate` capability and completes a task.
- Uses the mock settlement so no chain is required.
'@ @'
- `examples/` package + README.
'@ @'
- Example runs end to end under ROS 2.
'@),

    (New-Issue 'Add graceful shutdown to the ROS node' @('area: ros','complexity: medium') '150 (medium)' @'
Stop cleanly on SIGINT/SIGTERM.
'@ @'
- Break the spin loop and join threads without panicking.
- Enables in-flight task draining (see node issues).
'@ @'
- Shutdown handling + test.
'@ @'
- Ctrl-C exits cleanly with no panic.
'@),

    (New-Issue 'Add a diagnostics publisher' @('area: ros','complexity: medium') '150 (medium)' @'
Expose bridge health to the ROS ecosystem.
'@ @'
- Publish connection/queue status on `/bridge/diagnostics`.
- Integrate with `diagnostic_msgs` conventions.
'@ @'
- Publisher + docs.
'@ @'
- Diagnostics reflect simulated failures in tests.
'@),

    (New-Issue 'Enable the ROS CI job with setup-ros' @('area: ros','area: ci','complexity: medium') '150 (medium)' @'
Build and test the ROS crate in CI.
'@ @'
- Use `ros-tooling/setup-ros` with Jazzy; enable the currently disabled job.
- Cache the ROS install.
'@ @'
- Working `ros` job in `.github/workflows/ci.yml`.
'@ @'
- CI builds `ros-bridge --features ros` green.
'@),

    (New-Issue 'Add proof signing with the robot key' @('area: ros','area: security','complexity: high') '200 (high)' @'
Sign proofs on the robot side.
'@ @'
- Sign the completion digest with the robot's key before publishing.
- Never expose the key on topics or logs.
'@ @'
- Signing integration + tests.
'@ @'
- Published proofs verify against the robot's public key.
'@),

    # ---------------- bridge-node ----------------
    (New-Issue 'Implement the async runtime driver' @('area: node','complexity: high') '200 (high)' @'
Connect a `Transport` to a `Settlement` and run the lifecycle.
'@ @'
- Drive the state machine from events; handle errors without crashing.
- Runtime-agnostic core with a thin async shell.
'@ @'
- Driver + integration tests using mocks.
'@ @'
- Happy path and failure path both covered.
'@),

    (New-Issue 'Add config loading and validation' @('area: node','complexity: medium') '150 (medium)' @'
Configure the node from files and env, safely.
'@ @'
- Merge file + env; validate required fields with helpful errors.
- Example config committed.
'@ @'
- Loader + example config + tests.
'@ @'
- Invalid config fails fast with a clear message.
'@),

    (New-Issue 'Add tracing spans keyed by TaskId' @('area: node','complexity: medium') '150 (medium)' @'
Make task flows observable end to end.
'@ @'
- Create spans carrying `TaskId` across async boundaries.
- Respect `RUST_LOG`.
'@ @'
- Instrumentation + docs.
'@ @'
- Logs show a coherent per-task trace.
'@),

    (New-Issue 'Add a Prometheus metrics endpoint' @('area: node','complexity: medium') '150 (medium)' @'
Expose operational metrics.
'@ @'
- Counters for tasks accepted/settled/failed; gauges for in-flight.
- Lightweight exporter behind a flag.
'@ @'
- Metrics module + endpoint + tests.
'@ @'
- Endpoint returns expected metric names.
'@),

    (New-Issue 'Add retry and backoff for settlement failures' @('area: node','area: stellar','complexity: medium') '150 (medium)' @'
Survive transient chain errors.
'@ @'
- Retry only idempotent operations; bounded attempts; jittered backoff.
- Distinguish retryable from fatal errors.
'@ @'
- Retry policy + tests.
'@ @'
- Transient failures recover; fatal ones do not retry.
'@),

    (New-Issue 'Drain in-flight tasks on shutdown' @('area: node','complexity: medium') '150 (medium)' @'
Avoid leaving tasks half-settled when stopping.
'@ @'
- On shutdown, stop accepting new work and finish current tasks up to a deadline.
- Log any tasks that could not be finished.
'@ @'
- Draining logic + tests.
'@ @'
- Shutdown with a task in-flight completes or reports cleanly.
'@),

    (New-Issue 'Add health and readiness endpoints' @('area: node','complexity: trivial','good first issue') '100 (trivial)' @'
Support orchestration and monitoring.
'@ @'
- `/healthz` (liveness) and `/readyz` (dependencies reachable).
- Cheap checks only.
'@ @'
- HTTP handlers + tests.
'@ @'
- Readiness reflects a simulated dependency outage.
'@),

    # ---------------- Docs / DX ----------------
    (New-Issue 'Write a quickstart tutorial: robot to testnet settlement' @('area: docs','complexity: medium') '150 (medium)' @'
Take a newcomer from clone to a settled task on testnet.
'@ @'
- Step-by-step commands, expected output, and troubleshooting links.
- Uses the example robot and mock settlement first.
'@ @'
- `docs/quickstart.md` linked from `README.md`.
'@ @'
- A fresh contributor can follow it without questions.
'@),

    (New-Issue 'Add an ADR folder and the first architecture decision' @('area: docs','complexity: medium') '150 (medium)' @'
Record why we chose the trait-based split.
'@ @'
- `docs/adr/` with a template and ADR-0001 documenting the core/ros/stellar/node split.
'@ @'
- ADR template + ADR-0001.
'@ @'
- Indexed in `docs/architecture.md`.
'@),

    (New-Issue 'Add a glossary of project terms' @('area: docs','complexity: trivial','good first issue') '100 (trivial)' @'
Align everyone on vocabulary.
'@ @'
- Define capability, task, proof, escrow, settlement, wave, points.
- Cross-link to the docs that use them.
'@ @'
- `docs/glossary.md`.
'@ @'
- Terms match usage across the repo.
'@),

    (New-Issue 'Add a Mermaid architecture and lifecycle diagram' @('area: docs','complexity: trivial') '100 (trivial)' @'
Make the system readable at a glance.
'@ @'
- Mermaid diagrams for the data flow and the task lifecycle.
- Render on GitHub.
'@ @'
- Diagrams added to `docs/architecture.md`.
'@ @'
- Mermaid renders correctly on GitHub.
'@),

    (New-Issue 'Add docs.rs metadata and a docs build CI job' @('area: docs','area: ci','complexity: medium') '150 (medium)' @'
Publish and protect API docs.
'@ @'
- `[package.metadata.docs.rs]` for all public crates.
- CI job runs `cargo doc --no-deps` with warnings denied.
'@ @'
- Metadata + CI job.
'@ @'
- Docs build clean; broken intra-doc links fail CI.
'@),

    # ---------------- Security ----------------
    (New-Issue 'Write a threat model for the bridge' @('area: security','complexity: medium') '150 (medium)' @'
Enumerate assets, actors, and failure modes before scaling up.
'@ @'
- Assets: funds in escrow, signing keys, task integrity.
- Cover spoofed proofs, griefing, and key theft; map to mitigations.
'@ @'
- `docs/threat-model.md`.
'@ @'
- Each identified threat has a mitigation or a tracked issue.
'@),

    (New-Issue 'Add a security review checklist to the PR template' @('area: security','complexity: trivial') '100 (trivial)' @'
Make security a default consideration in review.
'@ @'
- Items for key handling, replay, authorization, and escrow invariants.
- Only shown when relevant paths change.
'@ @'
- Checklist added to `.github/pull_request_template.md`.
'@ @'
- Checklist appears on new PRs.
'@),

    (New-Issue 'Add SLSA provenance for release artifacts' @('area: security','area: ci','complexity: high') '200 (high)' @'
Let consumers verify where binaries came from.
'@ @'
- Generate SLSA provenance in the release workflow.
- Document how to verify.
'@ @'
- Provenance generation + `docs/releasing.md` verification steps.
'@ @'
- A test release produces verifiable provenance.
'@)
)

function Get-ExistingTitles {
    $titles = @{}
    $page = 1
    while ($true) {
        $resp = Invoke-RestMethod -Uri "$Api/issues?state=all&per_page=100&page=$page" -Headers $Headers
        if (-not $resp) { break }
        foreach ($i in $resp) { if ($i.pull_request -eq $null) { $titles[$i.title] = $true } }
        if ($resp.Count -lt 100) { break }
        $page++
    }
    return $titles
}

if (-not $IssuesOnly) {
    Write-Host "Syncing labels..."
    foreach ($l in $labels) {
        try {
            Invoke-RestMethod -Method Post -Uri "$Api/labels" -Headers $Headers -Body ($l | ConvertTo-Json) -ContentType 'application/json' | Out-Null
            Write-Host "  + $($l.name)"
        } catch {
            Write-Host "  = $($l.name) (exists or skipped)"
        }
    }
}

if (-not $LabelsOnly) {
    Write-Host "Creating issues (matched by title)..."
    $existing = Get-ExistingTitles
    $created = 0; $skipped = 0
    foreach ($issue in $issues) {
        if ($existing.ContainsKey($issue.title)) { $skipped++; Write-Host "  = $($issue.title)"; continue }
        $payload = @{ title = $issue.title; body = $issue.body; labels = $issue.labels } | ConvertTo-Json -Depth 3
        try {
            Invoke-RestMethod -Method Post -Uri "$Api/issues" -Headers $Headers -Body $payload -ContentType 'application/json' | Out-Null
            $created++; Write-Host "  + $($issue.title)"
        } catch {
            Write-Host "  ! FAILED: $($issue.title) -- $($_.Exception.Message)"
        }
        Start-Sleep -Milliseconds 250
    }
    Write-Host "Done. Created: $created, Skipped: $skipped, Total in script: $($issues.Count)"
}
