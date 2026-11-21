---
id: rag-vs-alternatives
title: 技術選型：RAG vs. Fine-tuning vs. Long Context vs. LLM Wiki
category: comparison
sources:
  - raw/01_rag_original_paper.md
  - raw/04_advanced_rag_and_evaluation.md
  - raw/05_rag_vs_finetuning_vs_llm_wiki.md
tags: [Comparison, Fine-Tuning, Long-Context, LLM-Wiki, Decision-Guide]
related:
  - "[[index]]"
  - "[[what-is-rag]]"
  - "[[advanced-rag-and-eval]]"
slide_mapping: "Slide 10-11"
updated: "2026-11-21"
---

# 技術選型：RAG vs. Fine-tuning vs. Long Context vs. LLM Wiki

導入外部知識時，RAG 不是唯一解。理解四種主流方案的差異，能幫助你在正確的場景選擇最合適的工具（來源：`raw/05_rag_vs_finetuning_vs_llm_wiki.md`）。

## 四大方案全方位比較

| 比較面向 | RAG（檢索增強生成） | Fine-tuning（模型微調） | Long Context（超長上下文） | LLM Wiki（編譯式知識庫） |
| :--- | :--- | :--- | :--- | :--- |
| **知識整合時機** | 查詢當下臨時檢索（Query-time） | 訓練階段寫入權重 | 每次查詢整份塞入 | **匯入時預先編譯（Ingest-time）** |
| **資料更新速度** | 快（更新向量庫即可） | 慢且昂貴（需重訓） | 極快（直接換檔案） | 快（增量更新 Markdown） |
| **來源可追溯性** | 高（附 Chunk 出處） | 低（黑箱權重） | 中（需模型自行標註） | **極高（Frontmatter + 雙向連結）** |
| **知識是否隨時間累積** | 否（無狀態、每次重撈） | 僅固定在權重 | 否（單次對話） | **是（越編譯結構越完整）** |
| **最佳適用場景** | 百萬級變動文件、企業客服搜尋 | 調整語氣、固定輸出格式、領域風格 | 單次深度閱讀數份長文件 | 研究筆記、個人／團隊知識庫、教學教材 |

## 特別對照：傳統 RAG 與 LLM Wiki 的互補
- **傳統 RAG 的盲點**：屬於**無狀態（Stateless）檢索**。每次問問題都是把零散的 Chunk 臨時拼在一起，系統不會主動幫你整理出結構、交叉比對矛盾或沉澱出總結（來源：`raw/05_rag_vs_finetuning_vs_llm_wiki.md`）。
- **LLM Wiki 的突破**：由 Andrej Karpathy 提倡，將 LLM 視為「知識編譯器」。每當新資料進入 `raw/`，LLM 會在 **Ingest 階段**主動整理進 `wiki/` 頁面、建立 `[[wikilink]]` 與更新 `log.md`，讓人類與 AI 共享一份可讀、可查證、可版本控制的活知識庫。
- **實務建議**：
  - 需要**改變模型說話風格或任務行為** → 選 **Fine-tuning**
  - 文件量少、單次分析 → 選 **Long Context**
  - 文件量極大（數萬～數百萬篇）且頻繁變動 → 選 **RAG**（並搭配 [[advanced-rag-and-eval]]）
  - 重視**跨文件深度整理、可審查與知識長期複利** → 選 **LLM Wiki**（就像本作業的知識庫本身！）
