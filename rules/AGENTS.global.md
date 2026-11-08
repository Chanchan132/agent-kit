# Global Agent Operating Guidelines (Personal Engineering Harness)

## 1. 語言與溝通風格 (Language & Communication)
- **預設語言**：所有分析、計畫、進度回報、Code Review 與交接文件（Handoff）一律使用**繁體中文（Traditional Chinese）**。
- **高密度、結論先行**：回覆應讓忙碌的工程師一眼讀懂（One-read clarity），直擊結論與核心變更，避免冗長鋪陳與空洞客套。
- **視覺化輔助**：當使用者要求「做成一頁」、「用页面講」、或需要解釋複雜架構／API 流程／狀態機時，優先讀取 `archify` skill 產出獨立互動式 HTML 圖表或一頁式懶人包。

## 2. 編碼哲學：反過度設計與最小完整改動 (Ponytail Mode)
- **預設載入 `ponytail`（full mode）**：在撰寫、修復、重構、審查代碼或選擇依賴時，優先遵循 `ponytail` 精神——**用最小且完整的改動解決問題（YAGNI）**。
- **重用優先**：動手前先讀既有架構（如 `docs/ARCHITECTURE.md`）與相鄰模組，重用專案現有的 helper、資料分層與原生機制，不無故引入新框架、多餘抽象層或非必要套件。
- **技術債顯式標記**：若為求精簡而採取刻意捷徑（Intentional Shortcut），必須在代碼中加上 `// shortcut: <原因與觸發重構條件>` 或 `# shortcut: ...` 註解，以便後續透過 `ponytail-debt` 追蹤。

## 3. 修改前影響分析 (Pre-Edit Impact & Code Graph)
- **先看呼叫鏈再改碼**：修改任何跨檔案邏輯或不熟悉的模組前，必須先追蹤所有 callers / callees 與資料流。
- **善用 `code-graph`**：優先使用 `codegraph` MCP 工具或 `code-graph` skill 分析符號定義、呼叫圖（Call Graph）與爆炸半徑（Blast Radius），確保改動不會破壞下游契約。

## 4. 確定性驗證閉環 (Deterministic Verification Workflow)
每次執行代碼修改時，依序遵循以下五步閉環：
1. **建立基準（Baseline）**：先執行專案既有的驗證或測試指令（如 `npm run verify`、`pytest`），確認改動前的基準狀態或重現問題。
2. **追蹤流程（Trace）**：定位受影響的完整路徑與邊界條件。
3. **最小完整實作（Implement）**：完成代碼變更，並**同步更新所有受影響的呼叫端（callers）、型別與相關文件**。
4. **執行驗證（Verify）**：重新執行測試與靜態檢查；若新增了非瑣碎邏輯（non-trivial logic），必須補上至少 1 個可實際執行的驗證測試。
5. **誠實回報（Honest Reporting）**：
   - 明確列出**實際執行過的驗證指令與結果**，以及**尚未涵蓋的限制（Remaining Limitations）**。
   - 嚴格區分「離線檢查／準備好的 Context Packet」與「實際連線／真實模型或環境執行結果」，絕不將模擬或快取狀態宣稱為已連線驗證。

## 5. 架構護欄與多 Agent 協作 (Harness² & Multi-Agent Collaboration)
- **Harness² 規範結構**：撰寫或維護專案級 `AGENTS.md` 時，採用 **INV（Workflow / Tool Invariants，工具與流程不變量）**、**DOM（Domain Contracts，領域與業務契約）** 與 **Memory（`EXPERIENCE.md` 實證踩坑紀錄）** 結構。
- **多 Agent 職責邊界**：
  - 當專案存在 `collaboration/HANDOFF.md` 時，動手前必先讀取以確認當前 Scope 與檔案所有權（Ownership）。
  - 嚴禁直接覆寫其他 Agent 或協作者正在負責的檔案；若擔任 Review Agent，僅輸出具體檔案路徑、最小修改建議與驗證步驟，交由 Lead Agent 整合並跑驗證。
- **安全與機密保護（Zero Secret Leakage）**：
  - 絕不將 API Keys、Token、`.env`、憑證或使用者個人存檔寫入源碼、Log、Context Bundle 或前端資源中。
