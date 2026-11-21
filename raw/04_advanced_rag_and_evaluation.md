# Raw Source 04: 進階 RAG 優化與評估指標

- **主題**：Advanced RAG Techniques and Evaluation Frameworks (RAGAS)
- **參考來源**：Gao et al. (2023) *Retrieval-Augmented Generation for Large Language Models: A Survey* (arXiv:2312.10997)、RAGAS Evaluation Framework
- **定位**：說明 Naive RAG（基礎版 RAG）在實務上為何仍會出錯，以及如何優化與量化評估。

## Naive RAG 的常見失敗原因
1. **檢索失準（Retrieval Failure）**：使用者問法太口語或含糊，導致語意向量撈不到真正包含答案的段落。
2. **專有名詞漏抓**：純向量搜尋對精確型號、法條編號、程式碼識別字（如 `ERR_4042`）不敏感，不如傳統 BM25 關鍵字搜尋精準。
3. **排序雜訊**：撈回 Top-10 片段中，最關鍵的那一段排在第 8 名，被其他次要段落干擾。
4. **忠實度不足**：即使撈到正確段落，LLM 仍可能自行腦補未出現在 Context 中的內容。

## 三大進階 RAG 優化技巧（Advanced RAG）
1. **查詢改寫（Query Rewriting / HyDE）**：在檢索前先請 LLM 將口語、省略主詞的問題改寫成更精確的檢索句，或拆解成多個子問題（Multi-Query）。
2. **混合檢索（Hybrid Search）**：同時結合 **BM25（關鍵字精確比對）** 與 **Vector Search（語意相似度）**，再用 RRF（Reciprocal Rank Fusion）合併排名，兼顧語意與專有名詞精準度。
3. **重新排序（Reranking）**：先用快速的雙編碼器（Bi-encoder）粗篩出 Top-20，再用精準度更高的交叉編碼器（Cross-encoder Reranker，如 Cohere Rerank / BGE-Reranker）重新打分，只把最相關的 Top-3～5 送給 LLM。

## RAGAS 評估框架（RAG Triad 三大核心指標）
要客觀衡量 RAG 系統好不好，不能只靠感覺，通常使用 **RAG Triad（三角評估法）**：
1. **檢索精準度（Context Precision / Relevance）**：撈出來的參考段落，真的跟問題相關嗎？（檢驗 Retrieval 品質）
2. **忠實度（Faithfulness / Groundedness）**：LLM 生成的答案是否完全忠於檢索到的參考段落，沒有憑空捏造？（檢驗是否幻覺）
3. **答案相關性（Answer Relevance）**：最終答案是否直接、完整地回應了使用者的原始問題？（檢驗整體可用性）
