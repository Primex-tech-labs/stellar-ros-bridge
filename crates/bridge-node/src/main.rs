fn main() {
    tracing::info!(
        version = bridge_node::VERSION,
        "Stellar ROS Bridge node (scaffolding) — no lifecycle wired up yet"
    );
    eprintln!(
        "stellar-ros-bridge {} — scaffolding, see docs/roadmap.md",
        bridge_node::VERSION
    );
}
