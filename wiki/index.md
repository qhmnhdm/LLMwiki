---
id: index
title: RAG（檢索增強生成）LLM Wiki 總目錄
category: index
sources:
  - raw/01_rag_original_paper.md
  - raw/02_embeddings_and_vector_db.md
  - raw/03_rag_pipeline_architecture.md
  - raw/04_advanced_rag_and_evaluation.md
  - raw/05_rag_vs_finetuning_vs_llm_wiki.md
tags: [RAG, LLM, Index, Knowledge-Base]
related:
  - "[[what-is-rag]]"
  - "[[chunking-and-embeddings]]"
  - "[[rag-pipeline]]"
  - "[[advanced-rag-and-eval]]"
  - "[[rag-vs-alternatives]]"
slide_mapping: "Slide 1, Slide 12"
updated: "2026-11-21"
---

# RAG（檢索增強生成）LLM Wiki 總目錄

歡迎來到 **RAG（Retrieval-Augmented Generation）** 主題知識庫。本 Wiki 遵循 [SCHEMA.md](../SCHEMA.md) 規範，已完整匯入（Ingest）5 篇原始技術文獻，並編譯為適合初學者循序漸進理解的知識網絡。

## 建議學習路徑（對應教學 HTML 簡報結構）

| 學習階段 | Wiki 頁面 | 核心問題 | 原始資料來源 | 對應簡報頁碼 |
| :--- | :--- | :--- | :--- | :--- |
| **1. 核心概念** | [[what-is-rag]] | 什麼是 RAG？為何純 LLM 會產生幻覺？ | `01`, `05` | Slide 2–3 |
| **2. 底層原理** | [[chunking-and-embeddings]] | 電腦怎麼「讀懂」文字語意並做搜尋？ | `02`, `03` | Slide 4–5 |
| **3. 系統架構** | [[rag-pipeline]] | RAG 的離線索引與線上查詢怎麼運作？ | `01`, `02`, `03` | Slide 6–7 |
| **4. 優化評估** | [[advanced-rag-and-eval]] | 為什麼基礎 RAG 會答錯？如何優化與評估？ | `04` | Slide 8–9 |
| **5. 技術選型** | [[rag-vs-alternatives]] | RAG、Fine-tuning、Long Context 與 LLM Wiki 怎麼選？ | `01`, `04`, `05` | Slide 10–11 |

## 知識圖譜關聯總覽

```text
[[what-is-rag]] (動機與開書考試類比)
       │
       ├──► [[chunking-and-embeddings]] (切塊、Embedding、餘弦相似度、向量庫)
       │           │
       │           ▼
       └──► [[rag-pipeline]] (離線 Indexing + 線上 Retrieval & Generation)
                   │
                   ├──► [[advanced-rag-and-eval]] (Hybrid Search、Rerank、RAGAS 三角評估)
                   │
                   └──► [[rag-vs-alternatives]] (vs Fine-tuning / Long Context / LLM Wiki)
```

## 已匯入原始資料清單（`raw/`）
1. `raw/01_rag_original_paper.md` — Lewis et al. (2020) RAG 奠基論文
2. `raw/02_embeddings_and_vector_db.md` — 切塊、向量嵌入與向量資料庫
3. `raw/03_rag_pipeline_architecture.md` — RAG 完整雙階段架構
4. `raw/04_advanced_rag_and_evaluation.md` — 進階 RAG 優化與 RAGAS 評估指標
5. `raw/05_rag_vs_finetuning_vs_llm_wiki.md` — RAG 技術選型與 LLM Wiki 對比
