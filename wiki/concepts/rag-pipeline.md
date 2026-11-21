---
id: rag-pipeline
title: RAG 完整雙階段架構（離線索引與線上查詢）
category: concept
sources:
  - raw/01_rag_original_paper.md
  - raw/02_embeddings_and_vector_db.md
  - raw/03_rag_pipeline_architecture.md
tags: [Architecture, Pipeline, Indexing, Retrieval, Generation]
related:
  - "[[index]]"
  - "[[what-is-rag]]"
  - "[[chunking-and-embeddings]]"
  - "[[advanced-rag-and-eval]]"
slide_mapping: "Slide 6-7"
updated: "2026-11-21"
---

# RAG 完整雙階段架構

一個標準的 RAG 系統可以拆解為兩條獨立運作的管線：**事前準備（離線索引）** 與 **即時作答（線上檢索與生成）**（來源：`raw/03_rag_pipeline_architecture.md`）。

## 階段一：離線索引階段（Offline Indexing）
在資料匯入或更新時執行，把非結構化文件變成可搜尋的向量庫：
1. **Load（載入）**：讀取 PDF、Markdown、網頁或資料庫內容。
2. **Split（切分）**：透過 [[chunking-and-embeddings]] 的切塊與 Overlap 策略切分段落，保留 Metadata。
3. **Embed（嵌入）**：用 Embedding 模型將每個 Chunk 轉成語意向量。
4. **Store（儲存）**：將「向量 + 原文 + Metadata」存入向量資料庫。

```text
原始文件 ──► Load ──► Split (Chunks) ──► Embed (Vectors) ──► Vector DB
```

## 階段二：線上查詢階段（Online Retrieval & Generation）
當使用者提出問題（Query）時即時執行：
1. **Query Embed**：用**同一個** Embedding 模型將問題轉成查詢向量。
2. **Retrieve Top-K**：在向量資料庫中計算餘弦相似度，取出最相關的前 K 個片段（常見 K = 3～5）。
3. **Prompt Augmentation（提示詞增強）**：把「系統規範 + Top-K 參考段落 + 使用者問題」組裝成增強提示詞，要求 LLM 僅能依據參考段落作答。
4. **LLM Generation（生成回答）**：LLM 結合 [[what-is-rag]] 所述的參數與非參數記憶，輸出流暢且附帶來源依據的答案。

```text
使用者問題 ──► Query Embed ──► Retrieve Top-K ──► 組裝 Prompt ──► LLM ──► 有憑有據的回答
```

## 參數調校陷阱：Top-K 與 Lost in the Middle
- `Top-K` 太小：可能漏掉包含關鍵答案的段落。
- `Top-K` 太大：不只增加 Token 費用，還會塞入大量雜訊，引發 **Lost in the Middle** 效應（LLM 容易忽略長上下文中間區域的重點）（來源：`raw/03_rag_pipeline_architecture.md`）。

## 延伸閱讀
- 當基礎管線（Naive RAG）仍會答錯時如何升級？見 [[advanced-rag-and-eval]]
