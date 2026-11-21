# LLM Wiki Schema — RAG（檢索增強生成）知識庫

## 1. 設計原則
- **Raw 不可變原則**：`raw/` 內的原始資料僅供讀取與引用，不得修改原文。
- **編譯式知識庫（Incremental Compilation）**：每次 `ingest` 一篇新資料時，不只新增摘要，而是將知識整合進現有的 `wiki/` 概念頁中，更新雙向連結與來源引用。
- **可追溯性（Traceability）**：每個 `wiki/` 頁面必須在 Frontmatter 標註 `sources`（對應的 `raw/` 檔名）與 `slide_mapping`（對應的教學簡報頁碼），確保「原始資料 → Wiki → 簡報」三層明確對應。

## 2. 目錄結構
- `raw/`：原始資料來源（`01_*.md` ～ `05_*.md`），每篇包含標題、出處、發布年份與核心原文重點。
- `wiki/index.md`：總索引頁，列出所有概念頁、比較頁與建議學習路徑。
- `wiki/concepts/`：核心概念頁（每個檔案聚焦單一主題）。
- `wiki/comparisons/`：技術比較與選型頁。
- `log.md`：按時間順序記錄每次 `INGEST`、`LINT`、`BUILD_SLIDES` 的操作與結果。

## 3. Wiki 頁面格式規範（Frontmatter）
每個 `wiki/` 內容頁皆需包含以下 YAML Frontmatter：
```yaml
---
id: unique-slug
title: 頁面標題
category: concept | comparison
sources:
  - raw/01_example.md
tags: [RAG, NLP]
related:
  - "[[other-page-slug]]"
slide_mapping: "Slide 2-3"
updated: "2026-11-21"
---
```

## 4. 連結與引用規則
- 跨頁引用一律使用雙向連結語法：`[[page-slug]]`（對應檔名不含 `.md`）。
- 重要名詞、數據或結論須標註來源檔案，例如 `(來源：raw/01_rag_original_paper.md)`。
- 禁止出現斷鏈（Broken Links）或孤兒頁（Orphan Pages，未被 `index.md` 或其他頁面連結）。

## 5. 標準操作流程
1. **INGEST（匯入）**：讀取 `raw/` 新文件 → 抽取關鍵概念 → 更新或新增 `wiki/` 頁面 → 補齊 `[[wikilink]]` → 更新 `wiki/index.md` → 寫入 `log.md`。
2. **LINT（結構檢查）**：透過腳本檢查 Frontmatter 完整性、斷鏈、孤兒頁、來源引用是否指向實際存在的 `raw/` 檔案。
3. **QUERY / COMPILE（產出簡報）**：僅依據 `wiki/` 內容生成教學 HTML 簡報，並驗證每一頁簡報都有對應的 Wiki 來源。
