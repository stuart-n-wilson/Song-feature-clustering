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

# Files should be in working directory.
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

# Merge dataframes by song_id. Remove songs without lyrics.
df <- inner_join(acoustic_features, lyrics, by = "song_id") |>
   filter(!(lyrics == ""))

# Check for any remaining NA's or empties.
sum(is.na(df) | df == "")

# Check for duplicate songs
length(unique(df$song_id))
nrow(df)

# Exploring the data ------------------------------------------------------

# Look at data, except lyrics and song_id, for display reasons.
df |>
   select(-lyrics) |>
   select(-song_id) |>
   head() |>
   gt() |>
   tab_header(
      title = "Song features"
   )

# We see that we should treat key, mode and time_signature as factors.
df <- df |>
   mutate(
      key = as.factor(key),
      mode = as.factor(mode),
      time_signature = as.factor(time_signature)
   )

# Correlation matrix ------------------------------------------------------

# We consider only the numeric values, as this will be for the model.
df_numeric <- df |>
   select(-song_id, -key, -mode, -time_signature, -lyrics)

corr_matrix <- cor(df_numeric, method = "spearman")

# Turn matrix into table for ggplot
corr_matrix <- melt(corr_matrix)

# Fill with absolute value for readability
ggplot(
   corr_matrix,
   aes(x = Var1, y = Var2, fill = abs(value))
) +
   geom_tile() +
   theme_minimal() +
   scale_fill_viridis_c() +
   theme(
      legend.key.height = unit(3, "cm"),
      legend.title = element_blank()
   ) +
   labs(
      x = "",
      y = "",
      title = "Absolute Spearman correlation matrix"
   )

# Principal component analysis --------------------------------------------

# Remove heavily skewed or meaningless variables (reduce variance)
df_numeric <- df_numeric |> 
   select(-duration_ms, -instrumentalness, -speechiness, -liveness)

# Run PCA on numeric data, scale it.
pca <- prcomp(df_numeric, scale. = TRUE)

# Extract the first two PCs.
pca_data <- as.data.frame(pca$x[, 1:2])

# k-means model -----------------------------------------------------------

# Model with just k = 2.
km.out <- kmeans(pca_data, centers = 2, nstart = 25, iter.max = 100)

fviz_pca_ind(
   pca,
   habillage = km.out$cluster,
   label = "none",
   geom = "point",
   palette = viridis(2),
) +
   labs(title = "Song feature k-means clustering, with k = 2")

# Numeric feature cluster analysis ----------------------------------------

# Add cluster col to df_numeric
df_clusters_num <- df_numeric |>
   mutate(cluster = factor(km.out$cluster))

# Sort col names alphabetically then produce gt table
df_clusters_num <- df_clusters_num[, order(colnames(df_clusters_num))]
df_clusters_num |>
   group_by(cluster) |>
   summarise(across(everything(), median)) |>
   gt() |>
   tab_header("Numeric features for the two clusters") |>
   fmt_number(decimals = 3)

# Boxplots
energy_boxpot <- df_clusters_num |> 
   ggplot(aes(y = energy, fill = cluster)) +
   geom_boxplot() +
   scale_fill_viridis_d() +
   theme_minimal() +
   theme(legend.position = "none") +
   labs(title = "Energy",
        y = "") +
   scale_x_continuous(name = NULL, breaks = NULL)

acousticness_boxpot <- df_clusters_num |> 
   ggplot(aes(y = acousticness, fill = cluster)) +
   geom_boxplot() +
   scale_fill_viridis_d() +
   theme_minimal() +
   theme(legend.position = "none") +
   labs(title = "Acousticness",
        y = "") +
   scale_x_continuous(name = NULL, breaks = NULL)

danceability_boxpot <- df_clusters_num |> 
   ggplot(aes(y = danceability, fill = cluster)) +
   geom_boxplot() +
   scale_fill_viridis_d() +
   theme_minimal() +
   theme(legend.position = "none") +
   labs(title = "Danceability",
        y = "") +
   scale_x_continuous(name = NULL, breaks = NULL)

valence_boxplot <- df_clusters_num |> 
   ggplot(aes(y = valence, fill = cluster)) +
   geom_boxplot() +
   scale_fill_viridis_d() +
   theme_minimal() +
   theme(legend.position = "none") +
   labs(title = "Valence",
        y = "") +
   scale_x_continuous(name = NULL, breaks = NULL)

loudness_boxplot <- df_clusters_num |> 
   ggplot(aes(y = loudness, fill = cluster)) +
   geom_boxplot() +
   scale_fill_viridis_d() +
   theme_minimal() +
   theme(legend.position = "none") +
   labs(title = "Loudness",
        y = "") +
   scale_x_continuous(name = NULL, breaks = NULL)

tempo_boxplot <- df_clusters_num |> 
   ggplot(aes(y = tempo, fill = cluster)) +
   geom_boxplot() +
   scale_fill_viridis_d() +
   theme_minimal() +
   theme(legend.position = "none") +
   labs(title = "Tempo",
        y = "") +
   scale_x_continuous(name = NULL, breaks = NULL)

(acousticness_boxpot + danceability_boxpot + energy_boxpot + loudness_boxplot +
      tempo_boxplot + valence_boxplot) +
   theme(legend.position = "bottom",
         legend.key.height= unit(1, "cm")) +
   plot_annotation("Numeric feature distribution, by cluster")

# Density plots
energy_density <- df_clusters_num |> 
   ggplot(aes(x = energy, fill = cluster)) +
   geom_density(alpha = 0.8) +
   scale_fill_viridis_d() +
   theme_minimal() +
   theme(legend.position = "none") +
   labs(title = "Energy",
        x = "")

acousticness_density <- df_clusters_num |> 
   ggplot(aes(x = acousticness, fill = cluster)) +
   geom_density(alpha = 0.8) +
   scale_fill_viridis_d() +
   theme_minimal() +
   theme(legend.position = "none") +
   labs(title = "Acousticness",
        x = "")

danceability_density <- df_clusters_num |> 
   ggplot(aes(x = danceability, fill = cluster)) +
   geom_density(alpha = 0.8) +
   scale_fill_viridis_d() +
   theme_minimal() +
   theme(legend.position = "none") +
   labs(title = "Danceability",
        x = "")

loudness_density <- df_clusters_num |> 
   ggplot(aes(x = loudness, fill = cluster)) +
   geom_density(alpha = 0.8) +
   scale_fill_viridis_d() +
   theme_minimal() +
   theme(legend.position = "none") +
   labs(title = "Danceability",
        x = "")

tempo_density <- df_clusters_num |> 
   ggplot(aes(x = tempo, fill = cluster)) +
   geom_density(alpha = 0.8) +
   scale_fill_viridis_d() +
   theme_minimal() +
   theme(legend.position = "none") +
   labs(title = "Danceability",
        x = "")

valence_density <- df_clusters_num |> 
   ggplot(aes(x = valence, fill = cluster)) +
   geom_density(alpha = 0.8) +
   scale_fill_viridis_d() +
   theme_minimal() +
   theme(legend.position = "none") +
   labs(title = "Valence",
        x = "")

(acousticness_density + danceability_density + energy_density +
      loudness_density + tempo_density + valence_density) +
   theme(legend.position = "bottom") +
   plot_annotation("Numeric feature distribution, by cluster")

# Categorical feature cluster analysis ------------------------------------

df_clusters_cat <- df |>
   select(key, mode) |>
   mutate(cluster = factor(km.out$cluster))

df_clusters_cat_long <- df_clusters_cat |>
   group_by(cluster) |>
   pivot_longer(cols = -cluster, names_to = "feature", values_to = "value")

ggplot(
   df_clusters_cat_long,
   aes(x = value, y = after_stat(prop), fill = cluster, group = cluster)
) +
   geom_bar(position = "dodge") +
   facet_wrap(~feature, scales = "free") +
   scale_y_continuous(labels = scales::percent) +
   theme_minimal() +
   labs(
      x = "Category value",
      y = "Proportion",
      title = "Proportion of categorical features by cluster"
   ) +
   scale_fill_viridis_d()

# Lyrics text mining ------------------------------------------------------

# Pre-processing

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

# Create new col with cleaned lyrics (this takes a long time to run).
df_lyrics <- df_lyrics |>
   mutate(clean_lyrics = clean_lyrics(lyrics))

# Create word df with tokenisation, remove stopwords in process, use only
# word in dictionary.
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
