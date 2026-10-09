//! Core domain types, traits, and error model for Stellar ROS Bridge.
//!
//! This crate is intentionally free of ROS 2 and Stellar dependencies so the
//! task lifecycle can be unit-tested with mocks. See `docs/architecture.md`.
//!
//! The domain model (`Capability`, `Task`, `Proof`, ...) is defined by the
//! `bridge-core` Wave issue; this crate currently exposes only scaffolding.

/// The crate version, sourced from `Cargo.toml`.
pub const VERSION: &str = env!("CARGO_PKG_VERSION");
