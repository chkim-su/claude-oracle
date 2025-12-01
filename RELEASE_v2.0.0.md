# v2.0.0 — Cross-Platform Support & Oracle Intelligence

## Highlights

- **Cross-platform installation** — Full support for Linux, macOS, and WSL with automatic line ending normalization
- **Intelligent response routing** — Oracle now distinguishes between strategic questions and implementation requests
- **FULLAUTO recovery system** — Automatic instruction persistence across conversation compaction

## New Features

### Oracle Response Types
The Oracle now automatically selects the appropriate response format:
- `strategic_advice` — Direct answers for questions and recommendations
- `implementation_plan` — Structured execution plans with steps, risks, and success criteria

### Cross-Platform Installer
- Automatic CRLF → LF conversion during installation
- Shell detection (bash, zsh, profile) with appropriate PATH configuration
- Python 3.8+ validation with clear error messaging
- Cleanup of conflicting prior installations

### FULLAUTO Enhancements
- Full `/fullauto` instructions are now appended to `FULLAUTO_CONTEXT.md` on each Oracle invocation
- Protected section with clear demarcation prevents accidental modification
- Ensures instruction continuity after context compaction

## Improvements

- Upgraded to Gemini 3 Pro with updated API syntax
- Image generation now uses `gemini-3-pro-image-preview` with streaming support
- Added `.gitattributes` for consistent line endings across contributors
- Improved Oracle system prompt with clearer role definition

## Bug Fixes

- Fixed recursive "consult the Oracle" steps in implementation plans
- Fixed `bash\r: command not found` errors on Windows-cloned repositories
- Fixed oracle wrapper path resolution when invoked from PATH

## Technical Summary

- 16 commits
- 7 files changed (+2,399 / -2,192)

## Compatibility

Fully backward compatible with v1.0.0. No migration steps required.

---

**Full Changelog**: https://github.com/n1ira/claude-oracle/compare/v1.0.0...v2.0.0
