# Loop / Graph 實際執行與檢查紀錄

- **執行時間**：2026-11-21 15:40:39
- **執行腳本**：`workflow/run_pipeline_check.ps1`（跨平台 Python 版：`workflow/run_pipeline_check.py`）
- **整體結果**：**ALL PASSED**

## Gate 0：原始資料數量檢查（`raw/`）
- 偵測到 5 篇原始資料（作業最低要求：5 篇）。

## Gate 1：Wiki 結構檢查（Lint）
- 共掃描 6 個 Wiki 頁面。
- PASS：所有 Frontmatter、raw 來源引用、[[wikilink]] 雙向連結與孤兒頁檢查皆通過。

## Gate 3：HTML 簡報與 Wiki 對應檢查（`slides/index.html`）
- 共解析 12 張投影片。
- Wiki 覆蓋率：6 / 6 頁（100%）。
- PASS：每張投影片皆有有效 Wiki 來源，且 100% 覆蓋知識庫頁面。

### 投影片 ↔ Wiki 對應明細表
| 頁碼 | 投影片標題 | 對應 Wiki 來源 | 狀態 |
| :--- | :--- | :--- | :--- |
| Slide 1 | 封面：RAG 新手完全入門 | `wiki/index.md` | OK |
| Slide 2 | 為什麼純 LLM 還不夠？ | `wiki/concepts/what-is-rag.md` | OK |
| Slide 3 | 什麼是 RAG？開書考試類比 | `wiki/concepts/what-is-rag.md` | OK |
| Slide 4 | 底層原理 I：Text Chunking | `wiki/concepts/chunking-and-embeddings.md` | OK |
| Slide 5 | 底層原理 II：Embedding 與向量庫 | `wiki/concepts/chunking-and-embeddings.md` | OK |
| Slide 6 | 系統架構 I：離線索引階段 | `wiki/concepts/rag-pipeline.md` | OK |
| Slide 7 | 系統架構 II：線上查詢與生成 | `wiki/concepts/rag-pipeline.md` | OK |
| Slide 8 | 進階 RAG 三大優化技巧 | `wiki/concepts/advanced-rag-and-eval.md` | OK |
| Slide 9 | RAGAS 三角評估指標 | `wiki/concepts/advanced-rag-and-eval.md` | OK |
| Slide 10 | 技術選型：四大方案比較 | `wiki/comparisons/rag-vs-alternatives.md` | OK |
| Slide 11 | 傳統 RAG vs. LLM Wiki | `wiki/comparisons/rag-vs-alternatives.md` | OK |
| Slide 12 | 互動隨堂小測驗與總結 | `wiki/index.md` | OK |

