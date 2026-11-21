# Raw Source 03: RAG 完整雙階段架構（Pipeline Architecture）

- **主題**：End-to-End RAG Pipeline — Indexing vs. Retrieval & Generation
- **參考來源**：LangChain RAG Tutorial、LlamaIndex High-Level Concepts
- **定位**：拆解 RAG 從建立知識庫到回答使用者問題的標準雙階段流程。

## 階段一：離線索引階段（Offline Indexing Pipeline）
此階段在系統上線前或資料更新時執行，目的是將外部文件預先處理成可檢索的向量知識庫：
1. **載入（Load）**：透過 Document Loaders 讀取不同格式來源（PDF、Markdown、HTML、Notion、SQL 資料庫）。
2. **切分（Split / Chunk）**：依照段落、標題或 token 長度將文件切成多個 Chunk，並保留 metadata（檔名、頁碼、章節標題）以利後續引用。
3. **嵌入（Embed）**：呼叫 Embedding 模型將每個 Chunk 轉為數值向量。
4. **儲存（Store）**：將「向量 + 原始文字 + Metadata」寫入向量資料庫建立索引。

## 階段二：線上查詢階段（Online Retrieval & Generation Pipeline）
當使用者實際輸入問題（Query）時，系統即時執行以下 4 個步驟：
1. **問題向量化（Query Embedding）**：使用與離線階段**相同的 Embedding 模型**，將使用者的問題轉換成查詢向量。
2. **相似度檢索（Retrieve Top-K）**：在向量資料庫中比對查詢向量，撈出最相關的前 K 個片段（例如 Top-3 或 Top-5）。
3. **提示詞增強（Prompt Augmentation）**：將「系統指令 + 檢索到的 Context 片段 + 使用者問題」組合成最終的 Augmented Prompt，並明確要求模型「僅根據提供的資料回答，若資料未提及請直接說明不知道」。
4. **答案生成（LLM Generation）**：將組合好的 Prompt 送入 LLM，產出附帶來源依據的最終回答。

## 常見實作注意事項
- 離線索引與線上查詢**必須使用同一個 Embedding 模型**，否則兩者的向量空間無法對齊，檢索結果會完全失準。
- `Top-K` 設太小會漏掉關鍵資訊；設太大會引入雜訊並增加 Token 成本，還可能觸發「Lost in the Middle」效應（LLM 容易忽略長上下文中間段的資訊）。
