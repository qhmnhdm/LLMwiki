# Raw Source 02: 切塊、向量嵌入與向量資料庫

- **主題**：Text Chunking, Embeddings, and Vector Databases in RAG
- **參考來源**：OpenAI Embeddings Guide、Pinecone Learning Center、Milvus Documentation
- **定位**：說明 RAG 如何把人類閱讀的文字轉換成電腦能做「語意搜尋」的數學向量。

## 1. 為什麼需要切塊（Text Chunking）？
- 原始文件（PDF、網頁、手冊）往往長達數十頁，直接整份塞進模型會超過上下文視窗（Context Window），也會稀釋語意焦點。
- **切塊策略**：將長文件切分為固定大小（例如 300～800 tokens）或依段落／標題切分的語意片段（Chunks）。
- **重疊設計（Chunk Overlap）**：相鄰兩塊之間通常保留 10%～20% 的重疊文字（例如 50～100 tokens），避免關鍵句子剛好被從中間切斷，導致上下文遺失。

## 2. 什麼是向量嵌入（Embedding）？
- Embedding 模型（如 `text-embedding-3-small`、`BGE-M3`）會將一段文字轉換成一組高維浮點數陣列（例如 768 維或 1536 維的向量）。
- **語意空間特性**：意思相近的句子，在向量空間中的距離會很近；意思無關的句子則距離很遠。
- 例如：「如何幫手機充電」與「行動裝置電池補充方式」幾乎沒有相同字詞，但它們的 Embedding 向量距離會非常接近——這正是**語意搜尋（Semantic Search）**勝過傳統關鍵字搜尋之處。

## 3. 相似度計算與向量資料庫（Vector Database）
- **餘弦相似度（Cosine Similarity）**：最常用的衡量方式，透過計算兩個向量的夾角餘弦值（範圍 -1 到 1，越接近 1 代表語意越相似）來排序相關度。
- **向量資料庫**：專門用來儲存數百萬筆高維向量並加速檢索的資料庫（如 Chroma、FAISS、Pinecone、Milvus、Qdrant）。
- **ANN（Approximate Nearest Neighbor，近似最近鄰）**：透過 HNSW 等索引演算法，在毫秒等級內從海量向量中找出最相似的 Top-K 片段，而不必逐一暴力比對。
