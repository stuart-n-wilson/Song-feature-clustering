# <img width="32" height="32" alt="image" src="https://github.com/user-attachments/assets/cf5c4d70-733c-42d3-8949-dc00db480040" /> Pop song feature clustering <img width="32" height="32" alt="image" src="https://github.com/user-attachments/assets/673026e0-091c-4aaf-9a09-dca867dedc7d" />

This project uses machine learning techniques to cluster Billboard Top 100 songs into 2 groups, and then uses tech mining methods to find the most frequent lyrics.

## Introduction
Many music streaming services like Spotify and Apple Music utilise song reccomendation algorithms - machine learning techniques act as the backbone of these systems. This project focuses on the use of k-means clustering as a method to group similar Billboard Top 100 songs by their features, such as acousticness, energy and danceability. This project also makes use of text mining techniques on the lyrics, to see which (meaningful) lyrics are most frequent in these pop songs, as lyric analysis can also be used in reccomendation systems.

### Research questions
1. What is the optimal number of clusters when clustering popular songs?
2. What are the song features within each cluster?
3. What are the most frequent lyrics within each cluster?

## Instructions 
### Dataset
The [MusicOSet](https://marianaossilva.github.io/DSW2019/index.html) dataset contains data on Billboard Top 100 songs from 1962 to 2018. This project uses the 'musicoset_songfeatures.zip' files that contain the songs along with their attributes and lyrics.
### Running the project
1. Extract the files from the zip folder into the working directory for the R project.
2. Install necessary packages - for each ```library(LIBRARY_NAME)```, type ```install.packages("LIBRARY_NAME")``` to install that package e.g. for ```library(tidyverse)```, first run the line ```install.packages("tidyverse")```.
3. To obtain the main results for the project, use 'main.R'. This file contains a stripped down version of each step and will run in full to provide the main results (ensure to run the file in line order!).
4. For greater detail into the methodology, the remaining R scripts are written to run entirely independently of one another, with the full detailed steps and extra visualisations.

## Results
### Clustering
<img width="1091" height="758" alt="14_song_feature_2_cluster" src="https://github.com/user-attachments/assets/64f4b3be-8858-4a7b-b23a-d8cf484e2865" />
The Billboard Top 100 songs from this time period are most optimally separated into two groups - high energy, danceable songs, and more relaxed, acoustic songs.
<img width="1091" height="758" alt="16b_numeric_feature_distribution_density" src="https://github.com/user-attachments/assets/0718e592-15a1-408d-bb1b-bd6a8a1fe59c" />



### Lyrics
<img width="1091" height="758" alt="40_most_common_lyrics_billboard_top100" src="https://github.com/user-attachments/assets/289cfa72-e6a2-410e-a42d-26c4ea677b99" />
The most frequent meaningful lyric is 'love' (or a related word, such as loving, lover). This is true for both the high energy songs and the acoustic ones.
<img width="1091" height="758" alt="19_lyric_cluster_comparison" src="https://github.com/user-attachments/assets/46acac80-2d87-4513-aab9-396fa7fbe4de" />


