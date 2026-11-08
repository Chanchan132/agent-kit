---
name: code-graph
description: >-
  Semantic code intelligence and knowledge graph tool for deep codebase exploration,
  symbol relationship tracing, call flows (callers/callees), and pre-edit impact analysis (blast radius).
  Use whenever exploring unfamiliar codebases, finding definitions/usages across 30+ languages,
  tracing call paths/flows, analyzing regression risks before editing or refactoring,
  or when the user asks for code graph, codegraph, 程式碼圖譜, or symbol call graphs.
metadata:
  version: "1.6.2"
  official_repository: "https://github.com/colbymchenry/codegraph"
---

# CodeGraph (Code Intelligence & Knowledge Graph)

CodeGraph is a fast, 100% local-first semantic code intelligence engine and SQLite knowledge graph powered by Tree-sitter. It pre-computes symbols, references, definitions, and call paths across 30+ languages (TypeScript/JavaScript, Python, Go, Rust, Java, C#, C/C++, PHP, Ruby, Swift, Kotlin, etc.), replacing expensive token-burning `grep` / `find` loops with single-shot deterministic lookups.

---

## 1. Project Initialization Workflow

In any project workspace, check if a `.codegraph/` directory exists at the project root.

### A. When `.codegraph/` is missing:
If the user asks to analyze the project with CodeGraph, or if deep code intelligence is required:
1. Run initialization from the workspace root:
   ```bash
   codegraph init
   ```
2. Verify indexing status:
   ```bash
   codegraph status
   ```

### B. When `.codegraph/` exists:
The repository is already indexed. You can immediately use CodeGraph MCP tools or CLI commands. The background watcher automatically syncs changes within ~1 second of file modifications. If manual sync is needed:
```bash
codegraph sync
```

---

## 2. Core Exploration & Analysis Tools

CodeGraph exposes its intelligence via two channels:
- **MCP Server** (preferred when loaded in Antigravity): `codegraph_explore`
- **CLI Commands** (always available in terminal): `codegraph <command>`

### Primary Action: `explore` (Replaces `Read` & `Grep` loops)
Use `explore` whenever you need to understand "how does feature X work", locate an unfamiliar symbol, or trace an architectural flow.
- **MCP**: `codegraph_explore(query: "auth flow from middleware to database")`
- **CLI**:
  ```bash
  codegraph explore "authMiddleware verifyToken"
  ```
- **What it returns in one shot:**
  - Verbatim line-numbered source code of relevant symbols (safe to `Edit` from).
  - Exact call paths and dynamic-dispatch hops between symbols.
  - Upstream callers and downstream blast radius.

### Finding Callers & Callees (Cross-File Call Flows)
To trace who calls a function or what a function invokes:
```bash
# Find all functions/methods calling <symbol>
codegraph callers <symbol>

# Find all functions/methods called by <symbol>
codegraph callees <symbol>
```

### Blast Radius & Impact Analysis (Before Editing/Refactoring)
Before modifying a core function, interface, or shared utility, calculate the exact blast radius to prevent regressions:
```bash
# Determine everything affected if <symbol> changes
codegraph impact <symbol>

# Find test files affected by changes in specific source files
codegraph affected path/to/file.ts
```

### Context Construction for Tasks
Generate targeted code context and relationship blocks for a specific task:
```bash
codegraph context "Refactor payment webhook handling"
```

---

## 3. Best Practices & Anti-Patterns

1. **Trust CodeGraph results over `grep`**:
   Results come from concrete AST parses. Do not re-verify symbol locations or call links using manual `grep` loops—it wastes tokens and loses dynamic flow relationships.
2. **Explore before reading files**:
   A single `codegraph explore` call usually provides the complete relevant context across multiple files. Do not read 10 separate files when one query covers the entire flow.
3. **Always check Impact before major refactoring**:
   Run `codegraph impact <symbol>` before editing shared signatures or public interfaces to identify all external dependencies.
4. **Unindexed repositories**:
   If a repository does not have a `.codegraph/` folder and the user has not asked to initialize one, fall back to standard codebase search tools.
