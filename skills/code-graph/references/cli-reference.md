# CodeGraph CLI Reference

### Commands Summary

| Command | Purpose |
|---|---|
| `codegraph init` | Initialize and build local SQLite graph in `.codegraph/` |
| `codegraph status` | Show database stats, indexed files, nodes, and symbol count |
| `codegraph sync` | Incremental sync of modified files since last index |
| `codegraph index` | Force a full rebuild of the entire index |
| `codegraph explore <query>` | Query symbols, call paths, and verbatim source in one shot |
| `codegraph callers <symbol>` | Find all functions/methods calling `<symbol>` |
| `codegraph callees <symbol>` | Find all functions/methods called by `<symbol>` |
| `codegraph impact <symbol>` | Report blast radius / all dependent symbols |
| `codegraph affected [files]` | Find test files affected by source file changes |
| `codegraph context <task>` | Formulate structured context for a specific task |
| `codegraph node [symbol/file]` | Inspect a single node or file |
| `codegraph files` | List all indexed project files |
| `codegraph unlock` | Remove stale lock file if indexing was interrupted |
