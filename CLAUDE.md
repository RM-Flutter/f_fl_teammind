# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

The full project guide is in AGENTS.md. It is shared with other coding agents. Edit that file, not this one.

@AGENTS.md

## Claude-specific notes

- The backend is the RightMind Laravel monorepo at `/var/www/html/rightmind`. When an API contract is unclear, read the matching package there (`packages/rm/<package>/src/routes/api.php` and its `ARCHITECTURE.md`). The URL prefix tells you the package, for example `emp_requests/v1/...` belongs to the employee-request package.
- Before you change a module, read its `README.md` in `lib/modules/<module>/`. Update that README when you change how the module works.
