# Raw Source 01: RAG 奠基論文（Lewis et al., 2020）

- **標題**：Retrieval-Augmented Generation for Knowledge-Intensive NLP Tasks
- **作者與機構**：Patrick Lewis, Ethan Perez, Aleksandra Piktus 等（Facebook AI Research / Meta AI, UCL, NYU）
- **發表**：NeurIPS 2020 (arXiv:2005.11401)
- **定位**：正式提出「RAG」架構與名詞的奠基論文。

## 核心動機：純預訓練語言模型的三大限制
1. **知識過期（Static Knowledge）**：大型語言模型（LLM）的知識被凍結在訓練當下的權重裡，若要更新最新資訊，必須耗費高昂成本重新訓練或微調。
2. **幻覺問題（Hallucination）**：在缺乏外部證據的情況下，生成式模型傾向憑機率「一本正經地胡說八道」。
3. **缺乏可追溯性（Lack of Provenance）**：模型無法直接指出回答是依據哪一份文件或哪一段事證，且難以存取企業或個人內部的私有資料。

## 核心架構：結合兩種記憶
Lewis 等人提出將以下兩種記憶結合在同一生成流程中：
- **參數記憶（Parametric Memory）**：預訓練好的生成式語言模型（論文中使用 BART），擅長語言理解、推理與流暢表達。
- **非參數記憶（Non-parametric Memory）**：外部密集向量索引資料庫（論文中使用 Wikipedia 的 Dense Vector Index），透過 Dense Passage Retriever (DPR) 即時檢索最相關的 Top-K 文件段落。

## 生活化類比
- **純 LLM**：像是「閉書考試」，只能憑腦中背過的舊知識作答，忘記時容易瞎編。
- **RAG**：像是「開書考試（Open-book Exam）」，先根據題目去翻閱指定的最新參考書，再根據找到的段落整理出有憑有據的答案。

## 論文關鍵結論
- 在開放領域問答（Open-domain QA）任務上，RAG 超越了純參數模型與純抽取式問答系統。
- 生成的內容比純 LLM 更具事實性（more factual）、更具體（more specific）且更少幻覺。
- 只需更新外部非參數索引（無須重訓模型權重），即可即時讓模型掌握新知識（Hot-swappable knowledge）。
