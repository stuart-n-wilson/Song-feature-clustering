# Song-feature-clustering
## Introduction
Many music streaming services like Spotify and Apple Music utilise song reccomendation algorithms - machine learning techniques act as the backbone of these systems. This project focuses on the use of k-means clustering as a method to group similar Billboard Top 100 songs by their features, such as acousticness, energy and danceability. Analysis was then conducted on the lyrics of these songs, to see which lyrics are most frequent in these pop songs as lyric analysis can also be used in reccomendation systems.

### Research questions
1. What is the optimal number of clusters when clustering popular songs?
2. What are the song features within each cluster?
3. What are the most frequent lyrics within each cluster?

## Instructions 
### Dataset
The [MusicOSet](https://marianaossilva.github.io/DSW2019/index.html) dataset contains data on Billboard Top 100 songs from 1962 to 2018. This project uses the 'musicoset_songfeatures.zip' files that contain the songs along with their attributes and lyrics.
### Running the project
Ensure that the files downloaded from the 'musicoset_songfeatures.zip' folder and contain within the working directory of the R project. The 'main.R' file then contains the full script, broken up into sections with descriptive subtitles.

## Results
### Clustering
<img width="1091" height="758" alt="14_song_feature_2_cluster" src="https://github.com/user-attachments/assets/64f4b3be-8858-4a7b-b23a-d8cf484e2865" />
The Billboard Top 100 songs from this time period are most optimally separated into two groups - high energy, danceable songs, and more relaxed, acoustic songs.
<img width="1091" height="758" alt="16b_numeric_feature_distribution_density" src="https://github.com/user-attachments/assets/0718e592-15a1-408d-bb1b-bd6a8a1fe59c" />



### Lyrics
<img width="1091" height="758" alt="40_most_common_lyrics_billboard_top100" src="https://github.com/user-attachments/assets/289cfa72-e6a2-410e-a42d-26c4ea677b99" />
The most frequent meaningful lyric is 'love' (or a related word, such as loving, lover). This is true for both the high energy songs and the acoustic ones.
<img width="1091" height="758" alt="19_lyric_cluster_comparison" src="https://github.com/user-attachments/assets/46acac80-2d87-4513-aab9-396fa7fbe4de" />


