//! Stellar/Soroban settlement client.
//!
//! Scaffolding only. The [`Settlement`](bridge_core) implementation and its
//! mockable RPC layer are tracked by the "stellar-bridge escrow client" Wave
//! issue. No live network calls should ever be made from unit tests.

/// The crate version, sourced from `Cargo.toml`.
pub const VERSION: &str = env!("CARGO_PKG_VERSION");
