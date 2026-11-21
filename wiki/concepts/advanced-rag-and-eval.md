---
id: advanced-rag-and-eval
title: 進階 RAG 優化與 RAGAS 評估指標
category: concept
sources:
  - raw/04_advanced_rag_and_evaluation.md
tags: [Advanced-RAG, Hybrid-Search, Reranking, RAGAS, Evaluation]
related:
  - "[[index]]"
  - "[[chunking-and-embeddings]]"
  - "[[rag-pipeline]]"
  - "[[rag-vs-alternatives]]"
slide_mapping: "Slide 8-9"
updated: "2026-11-21"
---

# 進階 RAG 優化與 RAGAS 評估指標

基礎版的 [[rag-pipeline]]（常稱為 **Naive RAG**）雖然容易實作，但在真實場景下常出現四類失敗：**問題太口語撈不到、專有名詞／編號漏抓、最相關段落排在後段、LLM 仍偶爾自行腦補**（來源：`raw/04_advanced_rag_and_evaluation.md`）。

## 三大進階優化技巧（Advanced RAG）

| 階段 | 技術名稱 | 解決的問題與運作方式 |
| :--- | :--- | :--- |
| **檢索前** | **Query Rewriting（查詢改寫）** | 先請 LLM 將含糊口語改寫成精確查詢，或拆成多個子問題（Multi-Query）。 |
| **檢索中** | **Hybrid Search（混合檢索）** | 同時跑 **BM25（關鍵字精確比對）** + **向量語意搜尋**，再用 RRF 融合排序，解決專有名詞與代碼漏抓。 |
| **檢索後** | **Reranking（重新排序）** | 先快速粗篩 Top-20，再用精準的 Cross-encoder 模型重算分數，只把最精華的 Top-3～5 交給 LLM。 |

## 如何客觀評分？RAGAS 三角評估法（RAG Triad）
判斷一個 RAG 系統好壞，不能只憑體感，業界常用 **RAGAS** 的三大核心指標（來源：`raw/04_advanced_rag_and_evaluation.md`）：

1. **檢索精準度（Context Precision）**：撈出來的參考段落，真的跟問題高度相關嗎？
   - *對應檢查*：`Query ↔ Retrieved Context`
2. **忠實度（Faithfulness）**：LLM 的回答是否 100% 忠於參考段落，沒有憑空瞎編？
   - *對應檢查*：`Retrieved Context ↔ Generated Answer`
3. **答案相關性（Answer Relevance）**：最終答案是否真正回答了使用者的原始問題？
   - *對應檢查*：`Query ↔ Generated Answer`

## 延伸閱讀
- 即使做了 Advanced RAG，它還是有一些結構性限制，與 Fine-tuning、LLM Wiki 相比該怎麼選？見 [[rag-vs-alternatives]]
