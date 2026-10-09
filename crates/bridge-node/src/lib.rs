//! Runtime library for Stellar ROS Bridge.
//!
//! Scaffolding only. The async task-lifecycle driver and its wiring of a
//! `Transport` to a `Settlement` are tracked by the "task lifecycle state
//! machine" Wave issue.

/// The crate version, sourced from `Cargo.toml`.
pub const VERSION: &str = env!("CARGO_PKG_VERSION");
