# Project Agent Harness Template (Harness² Standard)

## 1. Role & Architecture Overview (c1)
- **專案目標**：<簡述專案核心目標與技術棧>
- **核心模組分層**：
  - `<path/to/core>`：<職責說明>
  - `<path/to/ui_or_env>`：<職責說明>
- 動手修改前請先閱讀 `docs/ARCHITECTURE.md`（若有）並使用 `code-graph` 確認影響範圍。

## 2. Standing Guardrails & Invariants (c2 / INV & DOM)
- **INV-1（最小完整改動）**：在撰寫、修復或重構代碼時，讀取並遵循 `ponytail` skill（full mode），保持現有模組分層，不引入非必要依賴。
- **INV-2（機密隔離）**：嚴禁將任何 API Key、憑證或 `.env` 內容寫入原始碼、測試資料或版本控制。
- **INV-3（多 Agent 協作邊界）**：若存在 `collaboration/HANDOFF.md`，動手前先確認負責範圍，不覆寫其他協作者或 Agent 持有的檔案。
- **DOM-1（領域核心契約）**：<填入專案不可違反的領域規則，例如存檔相容性、狀態轉移約束或 API 格式>

## 3. Deterministic Workflow & Verification (c4)
1. **基準檢查**：執行 `<verify-command>` 擷取目前通過基準或重現問題。
2. **影響追蹤**：使用 `code-graph` 或搜尋工具確認所有受影響的 callers / callees。
3. **實作與同步**：完成最小修改並同步更新相關呼叫端與文件。
4. **驗證測試**：重新執行 `<verify-command>`；非瑣碎新邏輯需補上 1 個可執行測試。
5. **繁體中文誠實回報**：回報變更項目、**實際執行過的檢查指令**與**剩餘限制**。

## 4. Domain Memory & Lessons Learned (c3)
- 歷史踩坑與實證經驗請見 `docs/EXPERIENCE.md`。
- <補充專案特定的啟動順序、Port 綁定或環境限制>
