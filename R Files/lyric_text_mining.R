# Libraries ---------------------------------------------------------------

# Wrangling
library(tidyverse)
library(reshape2)
library(fastmatch)

# Machine Learning
library(factoextra)
library(cluster)

# Visualisation
library(patchwork) 
library(gt)
library(viridis)
library(ggwordcloud)

# Text mining
library(tm)
library(textclean)
library(textstem)
library(tidytext)
library(qdapDictionaries)

# Importing data ----------------------------------------------------------

# Files should be in working directory
acoustic_features <- read.delim(
   "acoustic_features.csv",
   sep = "\t",
   header = TRUE,
   stringsAsFactors = FALSE
)

lyrics <- read.delim(
   "lyrics.csv",
   sep = "\t",
   header = TRUE,
   stringsAsFactors = FALSE
)

# Merge dataframes by song_id. Remove songs without lyrics
df <- inner_join(acoustic_features, lyrics, by = "song_id") |>
   filter(!(lyrics == ""))

# Data pre processing and k-means -----------------------------------------

df <- df |>
   mutate(
      key = as.factor(key),
      mode = as.factor(mode),
      time_signature = as.factor(time_signature)
   )

df_numeric <- df |>
   select(-song_id, -key, -mode, -time_signature, -lyrics) |> 
   select(-duration_ms, -instrumentalness, -speechiness, -liveness)

# Run PCA and scale data
pca <- prcomp(df_numeric, scale. = TRUE)

# Extract the first two PCs
pca_data <- as.data.frame(pca$x[, 1:2])

# k-means model
km.out <- kmeans(pca_data, centers = 2, nstart = 25, iter.max = 100)


# Lyric pre processing ----------------------------------------------------

df_lyrics <- df |>
   select(lyrics) |>
   mutate(cluster = km.out$cluster) |>
   filter(lyrics != "")

clean_lyrics <- function(x) {
   x |>
      # remove leading [" or ['
      str_remove("^\\[[\"']") |>
      # remove trailing "]
      str_remove("[\"']\\]$") |>
      # convert \n to space
      str_replace_all("\\\\n", " ") |>
      # convert \xa0 to space
      str_replace_all("\\\\xa0", " ") |>
      # remove any [Verse], [Chorus], etc.
      str_remove_all("\\[.*?\\]") |>
      # fix \'
      str_replace_all("\\\\'", "'") |>
      # expand contractions
      replace_contraction() |>
      # lower-case
      str_to_lower() |>
      # remove punctuation
      removePunctuation() |>
      # remove numbers
      removeNumbers() |>
      # lemmatize
      lemmatize_strings()
}

# Create new col with cleaned lyrics (this takes a long time to run)
df_lyrics <- df_lyrics |>
   mutate(clean_lyrics = clean_lyrics(lyrics))

# Create word df with tokenisation, remove stopwords in process, use only
# words in dictionary.
data("stop_words")

words_df <- df_lyrics |>
   filter(lyrics != "") |>
   unnest_tokens(word, clean_lyrics) |>
   anti_join(stop_words, by = "word") |>
   filter(word %fin% GradyAugmented) |>
   filter(nchar(word) > 2)

# Lyric visualisations ----------------------------------------------------

# Top words for all songs
word_count <- words_df |>
   select(word, cluster) |>
   group_by(word) |>
   summarise(count = n()) |>
   arrange(desc(count)) |>
   # rotate about 85% of the words for the wordcloud
   mutate(angle = 45 * sample(-2:2, n(),replace = TRUE, prob = c(1, 1, 6, 1, 1))
   )
set.seed(12)
ggplot(word_count[1:40, ], aes(
   label = word,
   size = count,
   angle = angle,
   color = factor(sample.int(40, 40, replace = TRUE))
)) +
   geom_text_wordcloud_area() +
   scale_size_area(max_size = 50) +
   scale_colour_viridis_d() +
   theme_minimal() +
   labs(
      title = "40 most common lyrics from nearly 20,000 Billboard Top 100 songs",
      subtitle = "Lyrics have been filtered and lemmatised",
      caption = "Data source: MusicOSet"
   )

# Top words in cluster 1 (higher energy)
word_count_cluster_1 <- words_df |>
   select(word, cluster) |>
   filter(cluster == 1) |>
   group_by(word) |>
   summarise(count = n()) |>
   arrange(desc(count))

cluster1_words <- ggplot(word_count_cluster_1[1:40, ], aes(
   label = word,
   size = count,
   color = factor(sample.int(40, 40, replace = TRUE))
)) +
   geom_text_wordcloud_area(shape = "square", eccentricity = 1) +
   scale_size_area(max_size = 40) +
   scale_colour_viridis_d() +
   theme_minimal() +
   labs(title = "Cluster 1")

# Top words in cluster 2 (more acoustic)
word_count_cluster_2 <- words_df |>
   select(word, cluster) |>
   filter(cluster == 2) |>
   group_by(word) |>
   summarise(count = n()) |>
   arrange(desc(count))

cluster2_words <- ggplot(word_count_cluster_2[1:40, ], aes(
   label = word,
   size = count,
   color = factor(sample.int(40, 40, replace = TRUE))
)) +
   geom_text_wordcloud_area(shape = "square", eccentricity = 1) +
   scale_size_area(max_size = 40) +
   scale_colour_viridis_d() +
   theme_minimal() +
   labs(title = "Cluster 2")


cluster1_words / cluster2_words +
   plot_annotation(title = "40 most common lyrics, by cluster")
