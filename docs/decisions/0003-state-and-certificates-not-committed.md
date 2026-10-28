# 0003: State and certificates are never committed

Status: accepted.

The repository is public with permanent history, the state has no locking and changes constantly. So: the state is not committed, not even encrypted; `certs/` (the router CA used to verify its HTTPS certificate) is gitignored and fetched with the runbook; the provider lock file is committed. State encryption is nevertheless on, with its passphrase only in the gitignored `.env`, which the maintainer keeps in a password manager.
