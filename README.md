# <img width="32" height="32" alt="image" src="https://github.com/user-attachments/assets/cf5c4d70-733c-42d3-8949-dc00db480040" /> Pop song feature clustering <img width="32" height="32" alt="image" src="https://github.com/user-attachments/assets/673026e0-091c-4aaf-9a09-dca867dedc7d" />

### Machine learning & text mining on 50+ years of Billboard Top 100 songs

This project uses **k-means clustering**, **PCA**, and **lyric text mining** to explore patterns in Billboard Top 100 songs from 1962–2018. It identifies two dominant song groups—**high-energy/danceable** and **acoustic/relaxed**—and visualises their musical and lyrical characteristics.

---

# 📑 Table of Contents
- [Overview](#overview)  
- [Dataset](#dataset)  
- [Quick Start](#quick-start)  
- [Project Structure](#project-structure)  
- [Methodology Summary](#methodology-summary)  
- [Results](#results)  
  - [Clustering](#clustering)  
  - [Lyrics](#lyrics)  
- [Key Findings](#key-findings)  
- [Future Work](#future-work)  

---

## Overview
- Clusters Billboard Top 100 songs using **k-means**
- Uses **PCA** to understand feature structure  
- Evaluates optimal k (elbow + silhouette methods)  
- Performs **lyric text mining** and word frequency analysis  
- Produces numerous visualisations for features and lyrics  
- All results reproducible in R

---

## Research Questions
This project aims to answer the following:

1. What is the optimal number of clusters when grouping popular songs?
2. What are the song features within each cluster?
3. What are the most frequent lyrics within each cluster?


---

## Project Structure

```
├── main.R                         # Reproduces core results
├── exploratory_data_analysis.R    # Correlations, feature plots
├── pca_and_optimal_k.R            # PCA + k selection
├── k_means_model.R                # K-means modelling
├── cluster_feature_analysis.R     # Interpreting cluster features
├── lyric_text_mining.R            # Lyric text mining + wordclouds
```
---

## Methodology summary

1. Exploratory data analysis (EDA) - feature distributions, correlations and scatterplots.
2. Principal component analysis (PCA) - reduced dimensionality, calculate optimal k
3. Clustering - Silhouette and elbow plots, confirmed k = 2
4. Text mining - Cleaned, lemmatised and used frequency analysis on lyrics.
5. Results - analysed features and lyrics from within each cluster.

---

## Quick start
### Dataset
🔗 The [MusicOSet](https://marianaossilva.github.io/DSW2019/index.html) dataset contains data on Billboard Top 100 songs from 1962 to 2018.

Extract `musicoset_songfeatures.zip` into your project directory.
### Running the project
1. Extract the files from the zip folder into the working directory for the R project.
2. Install necessary packages - for each ```library(LIBRARY_NAME)```, type ```install.packages("LIBRARY_NAME")``` to install that package e.g. for ```library(tidyverse)```, first run the line ```install.packages("tidyverse")```.
3. To obtain the main results for the project, use [```main.R```](https://github.com/stuart-n-wilson/Song-feature-clustering/blob/main/main.R). This file contains a (**very**) stripped down version of the key steps and will run in full to provide the main results (ensure to run the file in line order!).
4. For greater detail into the methodology, used the steps below.

---

## Results
### Clustering
The Billboard Top 100 songs from this time period are most optimally separated into two groups - high energy, danceable songs, and more relaxed, acoustic songs. This defined separation would aid a song recommendation system with the two types of Billboard Top 100 songs being grouped with similarly attributed songs.
<p align="center">
  <img width="500" src="https://github.com/user-attachments/assets/64f4b3be-8858-4a7b-b23a-d8cf484e2865" />
  <img width="500" src="https://github.com/user-attachments/assets/0718e592-15a1-408d-bb1b-bd6a8a1fe59c" />
</p>

### Lyrics

The most frequent meaningful lyric is 'love' (including variants such as loving, lover). This is true for both the high energy songs and the acoustic ones. This matches up with existing research that says love is the most prominant theme in popular music in Billboard songs.
<p align="center">
  <img width="500" src="https://github.com/user-attachments/assets/27ae993e-ffdf-4fca-9e07-0929acc1d175" />
  <img width="500" src="https://github.com/user-attachments/assets/46acac80-2d87-4513-aab9-396fa7fbe4de" />
</p>

---

## Key findings
- Pop songs naturally from **2 clusters**, primarily separated by acousticness, danceability and energy.
- **Love** is the most frequent meaningful lyric across all pop songs and within each cluster.
  
---

## Future work
Combining feature analysis with lyric sentiment analysis to improve clustering performance.
  
