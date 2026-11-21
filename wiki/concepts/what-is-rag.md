---
id: what-is-rag
title: 什麼是 RAG？（Retrieval-Augmented Generation）
category: concept
sources:
  - raw/01_rag_original_paper.md
  - raw/05_rag_vs_finetuning_vs_llm_wiki.md
tags: [RAG, Hallucination, LLM, Fundamentals]
related:
  - "[[index]]"
  - "[[chunking-and-embeddings]]"
  - "[[rag-pipeline]]"
  - "[[rag-vs-alternatives]]"
slide_mapping: "Slide 2-3"
updated: "2026-11-21"
---

# 什麼是 RAG？（檢索增強生成）

**RAG（Retrieval-Augmented Generation，檢索增強生成）** 是由 Meta AI 研究團隊（Lewis et al., 2020）正式提出的一種 AI 架構。它的核心想法非常直覺：**在讓大型語言模型（LLM）回答問題之前，先去外部知識庫「查資料」，再把查到的段落交給 LLM 整理作答**（來源：`raw/01_rag_original_paper.md`）。

## 一句話類比：閉書考試 vs. 開書考試
- **純 LLM（閉書考試）**：只能靠訓練時背進腦袋（模型權重）的舊記憶作答，碰到沒學過或忘記的內容就容易亂猜。
- **RAG（開書考試）**：先翻閱指定的最新課本或公司文件，找到對應頁數後，再根據書上寫的內容組織答案（來源：`raw/01_rag_original_paper.md`）。

## RAG 解決了純 LLM 的三大痛點

| 純 LLM 痛點 | 問題說明 | RAG 如何解決 |
| :--- | :--- | :--- |
| **1. 知識過期** | 模型訓練完成後知識即凍結，重新訓練成本極高。 | 只需更新外部資料庫（Hot-swappable），不需重訓模型。 |
| **2. 幻覺問題（Hallucination）** | 沒有證據時，模型會憑機率流暢地編造錯誤事實。 | 強制模型依據檢索到的真實段落作答，大幅降低胡說機率。 |
| **3. 缺乏私有資料與出處** | 無法存取企業內部文件，也無法交代資料來源。 | 可安全掛載私有文件庫，並在回答中附帶來源引用。 |

## 兩種記憶的結合
RAG 的本質是結合了兩種互補的記憶系統（來源：`raw/01_rag_original_paper.md`）：
1. **參數記憶（Parametric Memory）**：LLM 本身，負責語意理解、邏輯推理與流暢語言生成。
2. **非參數記憶（Non-parametric Memory）**：外部向量資料庫或文件庫，負責儲存可隨時替換、可查證的最新事實。

## 延伸閱讀
- 外部資料庫怎麼聽懂人類的語意？見 [[chunking-and-embeddings]]
- 完整的系統運作步驟是什麼？見 [[rag-pipeline]]
- 如果不是用 RAG，還有哪些做法？見 [[rag-vs-alternatives]]
