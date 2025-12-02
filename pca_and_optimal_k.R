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

# Convert summary into df, simply for presenting
pca_summary <- summary(pca)

pca_df <- as.data.frame(t(pca_summary$importance)) |>
   rownames_to_column(var = "PC") |>
   gt() |>
   tab_header(title = "Principal component summary")
pca_df

# Investigate loadings for each PC
pca_loadings_df <- as.data.frame(t(pca$rotation[, 1:6]))

# Sort col names alphabetically first
pca_loadings_df <- pca_loadings_df[, order(colnames(pca_loadings_df))]

pca_loadings_gt <- pca_loadings_df |>
   rownames_to_column(var = "Variable") |>
   gt() |>
   tab_header(title = "Principal component loadings") |>
   fmt_number(
      columns = -Variable,
      decimals = 3
   )
pca_loadings_gt

# Visualise loadings
pca_loadings_df <- pca_loadings_df |>
   rownames_to_column(var = "PC") |>
   pivot_longer(
      cols = -PC,
      names_to = "Variable",
      values_to = "Loading"
   )

ggplot(pca_loadings_df, aes(x = Variable, y = PC, fill = abs(Loading))) +
   geom_tile() +
   scale_fill_viridis_c() +
   theme_minimal() +
   theme(
      axis.text.x = element_text(angle = 45, hjust = 1),
      legend.key.height = unit(3, "cm")
   ) +
   scale_y_discrete(limits = rev) +
   labs(
      title = "Principal component loadings heatmap",
      x = "Variable",
      y = "Principal Component",
      fill = "Loading (abs)"
   )
# Determine optimal k and number of PCs -----------------------------------

# Create df to store results
optimal_model_df <- data.frame(
   number_of_pcs = integer(),
   optimal_k = integer(),
   silhouette_max_score = numeric(),
   cumulative_variance = numeric()
)

set.seed(123)

# Iterate over first n PCs and extract max silhouette score for varying k
for (n in 1:6) {
   
   # Extract cumulative variance from pca_summary 3rd row
   cum_var <- pca_summary$importance[3, n]
   
   # Extra first n PCs
   pc_data <- as.data.frame(pca$x[, 1:n])
   
   # Calculate optimal k for current number of PCs
   k_analysis <- fviz_nbclust(
      pc_data,
      kmeans,
      method = "silhouette",
      k.max = 10,
      nstart = 25
   )
   
   # Extract data from k_analysis
   k_data <- as.data.frame(k_analysis$data)
   
   # Extract row with max silhouette score
   opt_row <- slice_max(k_data, y, n=1, with_ties = FALSE)
   
   # Extract k and silhouette score
   opt_k <- as.integer(opt_row$clusters)
   max_sil <- as.numeric(opt_row$y)
   
   # Store results in df
   optimal_model_df <- optimal_model_df |> 
      add_row(
         number_of_pcs = n,
         optimal_k = opt_k,
         silhouette_max_score = max_sil,
         cumulative_variance = cum_var
      )
}

optimal_model_df |>
   gt() |> 
   tab_header(title = "Optimal number of PCs and corresponding k value")

# Extract the first two PCs.
pca_data <- as.data.frame(pca$x[, 1:2])