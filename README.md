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
## Clustering
The Billboard Top 100 songs from this time period are most optimally separated into two groups - high energy, danceable songs, and more relaxed, acoustic songs.

## Lyrics
The most frequent meaningful lyric is 'love' (or a related word, such as loving, lover). This is true for both the high energy songs and the acoustic ones.
