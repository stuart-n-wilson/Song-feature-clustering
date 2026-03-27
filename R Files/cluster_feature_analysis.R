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

# Convert key, mode and time_signature to factors.
df <- df |>
   mutate(
      key = as.factor(key),
      mode = as.factor(mode),
      time_signature = as.factor(time_signature)
   )

# Data pre processing -----------------------------------------------------

# We consider only the numeric values, as this will be for the model.
df_numeric <- df |>
   select(-song_id, -key, -mode, -time_signature, -lyrics)

# Remove heavily skewed or meaningless variables (reduce variance)
df_numeric <- df_numeric |> 
   select(-duration_ms, -instrumentalness, -speechiness, -liveness)

# Principal component analysis --------------------------------------------

# Run PCA on numeric data, scale it.
pca <- prcomp(df_numeric, scale. = TRUE)

# Extract the first two PCs.
pca_data <- as.data.frame(pca$x[, 1:2])
# k-means model -----------------------------------------------------------

# Model with just k = 2.
km.out <- kmeans(pca_data, centers = 2, nstart = 25, iter.max = 100)

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
