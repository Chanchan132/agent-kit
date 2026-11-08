# Agent Kit (`agent-kit`) — 個人多 Agent 習慣、規則與 33 Skills 統一武裝庫

這是一個用來統一管理 **Google Antigravity (`~/.gemini`)**、**OpenAI Codex (`~/.codex`)**、**Claude Code (`~/.claude`)** 與各專案 `.agents/` 的單一真相來源（Single Source of Truth）。

當你在新電腦、新 CLI 工具或新專案追加 Agent 時，不需再一個一個重新建立設定——只需執行 `sync-agents.bat`，即可一鍵同步你的個人開發哲學、**33 個通用工程 Skills（10 個獨立 Skills + 23 個 Plugin Skills）**、Plugins 與 MCP 設定。

---

## 一、 核心使用習慣（`rules/AGENTS.global.md`）

1. **繁體中文 + 結論先行**：所有分析、計畫、進度回報與交接（Handoff）統一使用繁體中文，高密度呈現，讓忙碌工程師一眼讀懂。
2. **Ponytail 反過度設計（Full Mode）**：只做能完整解決問題的最小改動（YAGNI）；優先重用既有架構與 helper；刻意採取的捷徑以 `shortcut:` 註解標記並由 `ponytail-debt` 追蹤。
3. **Code-Graph 改動前影響分析**：修改跨檔案邏輯前，先讀 `ARCHITECTURE.md` 並搭配 `code-graph`（與 `codegraph` MCP）確認 callers / callees 與爆炸半徑（Blast Radius）。
4. **確定性驗證五步閉環（Deterministic Workflow）**：
   - `建立基準 (Baseline)` → `追蹤流程 (Trace)` → `最小完整實作並同步更新呼叫端 (Implement)` → `執行驗證並補測試 (Verify)` → `誠實回報實際跑過的指令與剩餘限制 (Honest Report)`。
5. **Harness² 護欄結構與多 Agent 協作**：
   - 以 **INV（流程／工具不變量）+ DOM（領域契約）+ Memory（`EXPERIENCE.md` 踩坑紀錄）** 組織專案規範。
   - 透過 `collaboration/HANDOFF.md` 切分 Lead Agent 與 Review Agent 職責，絕不直接覆寫其他 Agent 持有的檔案，且嚴格隔離 API Keys / `.env` 機密。

---

## 二、 收錄的 33 個通用 Skills & 3 個 Plugins 總覽

### A. 獨立 Skills (`skills/`，共 10 個)

| 類別 | Skill 名稱 | 功能說明 |
| :--- | :--- | :--- |
| **精簡開發與審查**<br>*(Ponytail 系列)* | `ponytail` | 反過度工程／最簡代碼模式（支援 `lite` / `full` / `ultra`） |
| | `ponytail-review` | 變更品質審查：檢查邏輯正確性、真實負載表現、測試覆蓋與多餘代碼 |
| | `ponytail-audit` | 全專案健檢報告：找出 Bug、資安漏洞、慢路徑與可刪除／合併的冗餘模組 |
| | `ponytail-debt` | 掃描並列出所有 `shortcut:` / `ponytail:` 技術債帳本 |
| | `ponytail-gain` | 展示 Ponytail 模式的代碼量、成本與速度節省數據 |
| | `ponytail-help` | Ponytail 等級、指令與使用快速參考 |
| **代碼圖譜與影響分析** | `code-graph` | 跨 30+ 語言的語意知識圖譜、呼叫鏈追蹤與修改前爆炸半徑分析（搭配 `codegraph` MCP） |
| **Agent Harness 演化** | `harness2` | Google Harness² 遞迴護欄優化框架（`c1–c8` 驗證、Propose-Probe-Compose 迴圈） |
| **視覺化與簡報生成** | `archify` | 生成支援深淺主題、動畫與 SVG/WebM 匯出的獨立 HTML 架構圖與一頁式懶人包 |
| | `ppt-master` | AI 驅動的可編輯 PPTX 簡報生成、視覺重構、品牌模板填充與旁白動畫工作流 |

### B. 封裝 Plugins (`plugins/`，共 3 個 Plugins / 23 個 Skills)
> `sync-agents` 會將這些 Plugins 原生安裝至 Antigravity (`~/.gemini/config/plugins/`)，並自動展開（Flatten）同步至 Codex (`~/.codex/skills/`) 與 Claude Code (`~/.claude/skills/`)。

| Plugin 名稱 | 內含 Skills / 元件 | 功能說明 |
| :--- | :--- | :--- |
| **`mattpocock-engineering`**<br>*(20 個工程 Skills)* | `tdd`, `diagnosing-bugs`, `codebase-design`, `code-review`, `domain-modeling`, `prototype`, `research`, `pr`, `wizard`, `grill-with-docs`, `to-spec`, `to-tickets`, `implement`, `implement-spec`, `improve-codebase-architecture`, `triage`, `retro`, `wayfinder`, `ask-matt`, `setup-matt-pocock-skills` | Matt Pocock 軟體工程方法論全集：從需求訪談 (`grill-with-docs`)、規格撰寫 (`to-spec`)、票務拆解 (`to-tickets`)、TDD 實作 (`tdd` / `implement-spec`)、深模組設計 (`codebase-design`) 到雙軸審查 (`code-review`) 與迭代復盤 (`retro`) |
| **`gemini-api`**<br>*(3 個 Skills + Docs MCP)* | `gemini-api-dev`, `gemini-live-api-dev`, `gemini-omni-flash-api` + `gemini-api-docs` MCP | 官方 Gemini API SDK、Live API 即時音視訊串流與 Omni 1.2 Flash 影片生成／編輯開發套件 |
| **`antigravity-pet`**<br>*(Lifecycle Hooks)* | `plugin.json` + `hooks.json` | 桌面寵物狀態追蹤與 `run_command` 外部審批／Discord 通知橋接 |

---

## 三、 快速使用指南

### 1. 一鍵同步到本機所有 Agent（Antigravity + Codex + Claude Code）

直接執行 `sync-agents.bat`（或在 PowerShell 執行）：

```powershell
# 預設 Copy 模式（安全複製所有規則、33 個 Skills、Plugins 與 MCP 設定）
.\sync-agents.bat

# 或使用 Junction 模式（建立 Windows 目錄連結，改 agent-kit 內檔案即全環境即時生效）
.\sync-agents.bat -Mode Junction
```

執行後會自動完成：
- 將 `rules/AGENTS.global.md` 同步至 `~/.gemini/config/rules/AGENTS.md`、`~/.gemini/GEMINI.md` 與 `~/.codex/AGENTS.md`
- 將 10 個獨立 Skills + 3 個 Plugins（含 23 個 Skills）同步至 Antigravity (`~/.gemini/config/`)
- 將全部 33 個通用 Skills 展開同步至 Codex (`~/.codex/skills/`)
- 確保 `codegraph` MCP 同時註冊於 Antigravity (`mcp_config.json`) 與 Codex (`config.toml`)

### 2. 為新專案一鍵建立 `.agents` 與 `AGENTS.md`

```powershell
.\sync-agents.bat -Project "C:\path\to\your\new-project" -Mode Junction
```

會自動在目標專案建立：
- `AGENTS.md`（含 Harness² INV/DOM 與五步驗證模板）
- `GEMINI.md`（多 Agent 協作與唯讀審查入口）
- `.agents/skills/`（掛載全套 33 個通用 Skills）
