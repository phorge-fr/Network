---
status: accepted
date: 2026-09-20
decision-makers: l-nmch
---

# State and certificates are never committed

## Context and problem statement

The repository is public with permanent history. The OpenTofu state has no locking and changes constantly, and the provider verifies the router certificate against a local CA file. What may be committed?

## Considered options

* Commit neither the state nor the CA file; encrypt the state locally.
* Commit the state encrypted.

## Decision outcome

Chosen option: "commit neither". The state is not committed, even encrypted; `certs/` is gitignored and fetched with [the reset how-to](../how-to/reset-and-bootstrap-the-router.md); the provider lock file is committed. State encryption stays on, with its passphrase only in the gitignored `.env`, which the maintainer keeps in a password manager.

### Consequences

* Good, because nothing recoverable sits in the permanent history.
* Bad, because the state lives on one machine; losing it means re-importing.

## Pros and cons of the options

### Commit neither

* Good, because no secret in history.
* Bad, because a single copy of the state.

### Commit the state encrypted

* Good, because a backup in Git.
* Bad, because permanent history, churn and no locking.
