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
# Elbow plot --------------------------------------------------------------

elbow_plot <- fviz_nbclust(
   pca_data,
   kmeans,
   method = "wss",
   k.max = 10,
   nstart = 25,
   iter.max = 100
)

elbow_plot +
   labs(title = "Elbow plot for optimal clusters") +
   theme_minimal() +
   geom_line(aes(group = 1), linewidth = 1) +
   geom_point(size = 3)
# Silhouette plot ---------------------------------------------------------

# Confirm correct number of clusters with silhouette plot
silhouette_plot <- fviz_nbclust(pca_data,
                                kmeans,
                                method = "silhouette"
)

silhouette_plot +
   theme_minimal() +
   labs(title = "Optimal number of clusters - silhouette method") +
   geom_line(aes(group = 1), linewidth = 1) +
   geom_point(size = 3)

# k-means model -----------------------------------------------------------

# Create and visualise model for k = 2 to k = 5

cluster_plots <- list()

set.seed(123)

for (k in 2:5) {
   # km model
   km.out <- kmeans(pca_data, centers = k, nstart = 25, iter.max = 100)
   
   # Visualisation
   cluster_plot <- fviz_pca_ind(
      pca,
      habillage = km.out$cluster,
      label = "none",
      geom = "point",
      palette = viridis(k)
   ) +
      ggtitle(paste("k = ", k)) +
      theme(legend.position = "none")
   
   cluster_plots[[paste0("k", k)]] <- cluster_plot
}

cluster_plots$k2 + cluster_plots$k3 + cluster_plots$k4 + cluster_plots$k5 +
   plot_annotation(title = "k-means clustering for k = 2 - 5")

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

# Analyse clusters
sil <- silhouette(km.out$cluster, dist(pca_data))
summary(sil)