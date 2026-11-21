# LLM Wiki 操作日誌（Log）

本檔案依照 [SCHEMA.md](SCHEMA.md) 規範，按時間軸記錄每一次 `INGEST`、`LINT` 與 `BUILD_SLIDES` 的執行過程。

---

## [2026-11-21] INIT — 建立 Schema 與專案架構
- 完成「先討論、後生成」確認：主題選定 **RAG（檢索增強生成）**。
- 建立 `SCHEMA.md`，定義 `raw/`（不可變）、`wiki/`（編譯知識庫）、Frontmatter 欄位、`[[wikilink]]` 與 `slide_mapping` 對應規範。

## [2026-11-21] INGEST #1 — `raw/01_rag_original_paper.md`
- **來源**：Lewis et al. (2020) RAG 奠基論文
- **編譯更新**：
  - 新增 `wiki/concepts/what-is-rag.md`（建立閉書 vs. 開書考試類比、三大痛點、參數與非參數記憶）
  - 預留跨頁連結：`[[chunking-and-embeddings]]`、`[[rag-pipeline]]`、`[[rag-vs-alternatives]]`

## [2026-11-21] INGEST #2 — `raw/02_embeddings_and_vector_db.md`
- **來源**：切塊、向量嵌入與向量資料庫技術指南
- **編譯更新**：
  - 新增 `wiki/concepts/chunking-and-embeddings.md`（整理 Chunking、Overlap、Embedding 向量空間、餘弦相似度、ANN 檢索）
  - 補齊與 `[[what-is-rag]]` 的雙向連結

## [2026-11-21] INGEST #3 — `raw/03_rag_pipeline_architecture.md`
- **來源**：RAG 完整雙階段架構（LangChain / LlamaIndex）
- **編譯更新**：
  - 新增 `wiki/concepts/rag-pipeline.md`（整理離線 Indexing 4 步驟與線上 Retrieval & Generation 4 步驟、Top-K 與 Lost in the Middle 陷阱）
  - 回頭補充 `wiki/concepts/chunking-and-embeddings.md`（加入 Metadata 保留與「必須使用同一 Embedding 模型」提醒）

## [2026-11-21] INGEST #4 — `raw/04_advanced_rag_and_evaluation.md`
- **來源**：Gao et al. (2023) RAG Survey & RAGAS 評估框架
- **編譯更新**：
  - 新增 `wiki/concepts/advanced-rag-and-eval.md`（整理 Naive RAG 失敗原因、Query Rewriting / Hybrid Search / Reranking、RAGAS 三角評估法）
  - 串接 `[[rag-pipeline]]` 與 `[[chunking-and-embeddings]]`

## [2026-11-21] INGEST #5 — `raw/05_rag_vs_finetuning_vs_llm_wiki.md`
- **來源**：RAG 技術選型與 LLM Wiki 對比（Anthropic / Karpathy 2026）
- **編譯更新**：
  - 新增 `wiki/comparisons/rag-vs-alternatives.md`（建立四大方案比較表、無狀態 RAG vs 編譯式 LLM Wiki 深度對照與實務選型指南）
  - 更新 `wiki/index.md`，完成全站 5 篇學習路徑與知識圖譜對應表

## [2026-11-21] BUILD_SLIDES #1 — `slides/index.html`
- **來源**：僅依據 `wiki/` 內 6 個知識頁面編譯生成
- **產出**：12 頁互動式教學 HTML 簡報（`slides/index.html`），每頁皆內嵌 `data-wiki-source` 與頁尾來源徽章，第 12 頁包含 3 題互動隨堂測驗。

## [2026-11-21 15:14:23] LINT & CHECK #1 — FAILED（Gate 1 攔截異常）
- **執行腳本**：`workflow/run_pipeline_check.ps1`
- **結果**：Gate 0 PASS（5 篇）、Gate 3 PASS（12 頁簡報 100% 覆蓋 6 個 Wiki 頁），但 **Gate 1 FAILED**。
- **錯誤訊息**：`[斷鏈] wiki/comparisons/rag-vs-alternatives.md 中的 [[wikilink]] 找不到對應 Wiki 頁面`。
- **原因與修正**：內文將 `` `[[wikilink]]` `` 寫在行內程式碼當作語法示範，而腳本未先排除 inline code。修改 `run_pipeline_check.py` 與 `run_pipeline_check.ps1`，在掃描 `[[...]]` 前先過濾 `` `[^`]+` `` 區段。

## [2026-11-21 15:16:40] LINT & CHECK #2 — ALL PASSED
- **執行腳本**：`workflow/run_pipeline_check.ps1`
- **結果**：**ALL PASSED**（Raw 5/5、Wiki 6/6 零斷鏈零孤兒頁、Slides 12/12 頁且 100% 覆蓋 Wiki），報告已寫入 `workflow/execution_report.md`。
