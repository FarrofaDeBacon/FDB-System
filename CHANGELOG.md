# CHANGELOG.md — RSG-Core Premium Fork

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [Unreleased] - Phase 1 Setup & Security Audit

### Security & Audit (Phase 1)
- Whitelisted client-updatable metadata keys in `RSGCore:Server:SetMetaData` to prevent unauthorized client manipulation of protected stats (e.g. jobs, money, death states).
- Enforced admin permission checks on `RSGCore:DebugSomething` net event to prevent unauthorized client console/log spam.
- Completed Phase 1 security audit matrix in `AUDIT.md`.
