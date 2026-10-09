# Issue guide (for maintainers)

This follows the Drips Wave "Creating Meaningful Issues" guidance. The goal is
issues that attract serious contributors, are completable in one Wave, and just
plain get done.

## Five principles

1. **Real impact.** Does this improve the product, DX, or safety? If not, don't
   file it.
2. **Clear context.** Give the *why*, the background, and what "done" looks
   like.
3. **Right scope.** Completable within one Wave. Too big → split it. Too small →
   combine it or drop it.
4. **Guidance, not handcuffs.** Point at files/modules, designs, edge cases, and
   how to validate — then leave room for judgement.
5. **Explicit expectations.** State the acceptance criteria, how you'll review,
   and what the PR must contain.

## Complexity and points

| Label | Points | Use for |
| --- | --- | --- |
| `complexity: trivial` | 100 | Small, bounded changes with obvious acceptance criteria. |
| `complexity: medium` | 150 | Standard features or logic across a few modules. |
| `complexity: high` | 200 | Integrations, architecture, on-chain logic. |

Tag honestly. Inflating or underpricing points breaks trust and the reward math.

## Required fields for every Wave issue

Use the `Wave task` issue template. Every issue must include:

- **Description** — what to build/fix, 2–4 sentences.
- **Requirements and context** — the why, links, constraints, definition of done.
- **Suggested execution** — branch name and the files/modules to touch.
- **Implement changes** — concrete deliverables.
- **Test and commit** — how to verify and what evidence goes in the PR.
- **Example commit message** — Conventional Commits form.
- **Guidelines** — assignment required; `Closes #<id>` in the PR.
- **Complexity** — one of Trivial / Medium / High.

## Assignment and reviews

- Assign contributors quickly — speed is critical during a Wave.
- Use the applicant's Code Metrics + languages profile to gauge fit.
- If an applicant doesn't fit and you already have several, reject explicitly so
  they can move on.
- Merge before the Wave ends, or mark resolved if the PR is blocked for reasons
  outside the contributor's control, so they are still paid.
- Leave a two-way review within 14 days of closing.

## Anti-patterns

- "Fix typo" / "change button color" issues with no stated impact.
- Issues with no acceptance criteria.
- Doing the work yourself in the issue and asking for a verbatim paste.
- Assigning one person to overlapping issues.
