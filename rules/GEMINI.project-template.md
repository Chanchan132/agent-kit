# Gemini / Review Agent Entry

@./AGENTS.md

開始工作前請先閱讀 `collaboration/HANDOFF.md`（若存在）。
- **預設角色**：審查提供的 Context 並提出最小完整修改方案（遵循 `ponytail` 與 `code-graph` 規範）。
- **協作邊界**：請勿直接覆寫其他 Agent 負責的檔案；請記錄建議修改的檔案路徑、具體變更與驗證步驟，由主責 Agent 整合並執行驗證。
- **語言與安全**：交接與報告請統一使用**繁體中文**；絕不讀取或輸出任何憑證與 `.env` 機密。
