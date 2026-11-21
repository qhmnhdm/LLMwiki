---
id: chunking-and-embeddings
title: 切塊（Chunking）、向量嵌入（Embedding）與向量資料庫
category: concept
sources:
  - raw/02_embeddings_and_vector_db.md
  - raw/03_rag_pipeline_architecture.md
tags: [Chunking, Embedding, Vector-Database, Semantic-Search]
related:
  - "[[index]]"
  - "[[what-is-rag]]"
  - "[[rag-pipeline]]"
  - "[[advanced-rag-and-eval]]"
slide_mapping: "Slide 4-5"
updated: "2026-11-21"
---

# 切塊、向量嵌入與向量資料庫

要讓 RAG 在「開書考試」時翻對頁數，系統必須先能理解文字的**語意**而不只是比對字面關鍵字。這仰賴三個核心基礎技術（來源：`raw/02_embeddings_and_vector_db.md`）。

## 1. 文字切塊（Text Chunking）
- **為什麼要切塊？** 原始檔案（如 100 頁 PDF）太長，直接整份塞給 LLM 會超出 Context Window 並稀釋檢索焦點。
- **怎麼切？** 將文件切分為數百 tokens 左右的段落（Chunk），並同時保留 Metadata（檔名、章節、頁碼）方便未來附註出處（來源：`raw/03_rag_pipeline_architecture.md`）。
- **重疊設計（Chunk Overlap）**：相鄰兩塊保留 10%～20% 的重疊字元，避免重要句子剛好被腰斬而失去前後文（來源：`raw/02_embeddings_and_vector_db.md`）。

## 2. 向量嵌入（Embedding）
- Embedding 模型會將每段文字轉成一串高維數字向量（例如 `[0.021, -0.418, ..., 0.115]`，常見維度為 768 或 1536 維）。
- **核心直覺：把「意思」變成「座標」**。語意相近的句子，在多維空間中的位置會彼此靠近。
- 例如「如何幫手機充電」與「行動裝置電池補充方式」幾乎沒有重複字詞，卻能透過向量距離被精準配對（來源：`raw/02_embeddings_and_vector_db.md`）。

## 3. 相似度計算與向量資料庫（Vector Database）
- **餘弦相似度（Cosine Similarity）**：計算查詢向量與文件向量的夾角餘弦值（範圍 -1 到 1，越接近 1 代表越相關）。
- **向量資料庫**：如 Chroma、FAISS、Pinecone、Milvus、Qdrant，利用 **ANN（近似最近鄰，如 HNSW）** 演算法在毫秒內從百萬筆片段中撈出最相關的 Top-K 段落（來源：`raw/02_embeddings_and_vector_db.md`）。

## 實作關鍵提醒
- 建立索引與線上查詢**必須使用同一個 Embedding 模型**，否則向量空間座標系不同，相似度比對會完全失效（來源：`raw/03_rag_pipeline_architecture.md`）。

## 延伸閱讀
- 這些元件如何串成完整系統？見 [[rag-pipeline]]
- 純向量搜尋遇到專有名詞漏抓怎麼辦？見 [[advanced-rag-and-eval]]
