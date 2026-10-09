<!--
Keep PRs focused: one issue per PR. Conventional Commits in the title.
-->

## Summary

<!-- What changed and why, in a few sentences. -->

Closes #

## Type of change

- [ ] Bug fix
- [ ] New feature
- [ ] Refactor / internal
- [ ] Documentation
- [ ] Tests / tooling

## How it was verified

<!-- Paste the commands you ran and the relevant output. -->

```
cargo fmt --all -- --check
cargo clippy --workspace --all-targets -- -D warnings
cargo test --workspace
```

## Checklist

- [ ] Assigned on the linked issue before starting.
- [ ] One issue per PR; no unrelated changes.
- [ ] Tests added or updated for new logic (edge cases included for money/signing/escrow paths).
- [ ] Public items documented; no build warnings.
- [ ] Docs updated where behavior changed.
- [ ] No secrets, keys, or credentials committed.

## Notes for reviewers

<!-- Design trade-offs, follow-ups, or anything that needs a closer look. -->
