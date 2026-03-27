# 🎵 Pop Song Feature Clustering

![R](https://img.shields.io/badge/R-blue)
![Clustering](https://img.shields.io/badge/Clustering-K--Means-green)
![PCA](https://img.shields.io/badge/PCA-Dimensionality-orange)
![Text Mining](https://img.shields.io/badge/NLP-Text%20Mining-purple)

Unsupervised learning and text mining on 50+ years of Billboard Top 100 songs, identifying two distinct musical clusters and discovering lyrical trends.

---

## 🚀 Overview

This project explores patterns in popular music using k-means clustering and text analysis, combining **audio features and lyrics** to uncover structure in acoustic song features.

---

## 📊 Key Results

* Pop songs cluster into **two primary groups**:

  * High-energy / danceable
  * Acoustic / relaxed
* Optimal clustering confirmed using silhouette and elbow methods
* “Love” is the most frequent lyrical theme across all clusters

---

## 🔍 Exploratory Analysis

* Analysed feature distributions and correlations
* Visualised pairwise feature relationships to highlight patterns.

---

## ⚙️ Modelling

* PCA for dimensionality reduction and feature understanding
* K-means clustering (k = 2 selected via evaluation metrics)
* Cluster validation using silhouette scores

---

## 📝 Text Mining

* Cleaned and lemmatised lyrics, including stop word removal
* Frequency analysis
* Compared themes across clusters
* Visualised in wordclouds

---

## 📂 Project Structure

```text
song-feature-clustering/
├── R Files/
│   ├── exploratory_data_analysis.R   # EDA and feature exploration
│   ├── pca_and_optimal_k.R           # PCA + optimal cluster selection
│   ├── k_means_model.R               # K-means clustering implementation
│   ├── cluster_feature_analysis.R    # Interpretation of cluster features
│   └── lyric_text_mining.R           # Text mining and lyric analysis
├── Visualisations/                   # Output plots and figures
├── main.R                            # Runs core pipeline and reproduces results
└── README.md
```


---

## 🧠 Key Insights

* Pop songs naturally cluster into 2 main styles: energetic and acoustic.
* Acoustic features such as danceability, acousticness and energy drive this separation.
* **Love** is the most common theme and lyric across all pop songs and within each cluster.

---

## ▶️ How to Run

1. Download [MusicOSet](https://marianaossilva.github.io/DSW2019/index.html) dataset
2. Place CSV files in working directory
3. Run `main.R` to obtain main results.
