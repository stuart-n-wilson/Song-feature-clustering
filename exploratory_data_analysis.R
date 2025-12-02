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

# Feature visualisation ---------------------------------------------------

# Generate 10 colour palette from viridis.
# show_col(viridis_pal()(10))

# 440154FF acoustic
# 482878FF dance
# 3E4A89FF energy
# 31688EFF instrumentalness
# 26828EFF liveness
# 1F9E89FF loudness
# 35B779FF song duration
# 6DCD59FF speechiness
# B4DE2CFF tempo
# FDE725FF valence

p_acou <- df |>
   ggplot(aes(acousticness)) +
   geom_density(fill = "#440154FF") +
   theme_minimal() +
   labs(
      title = "Acousticness",
      x = ""
   )

p_dance <- df |>
   ggplot(aes(danceability)) +
   geom_density(fill = "#482878FF") +
   theme_minimal() +
   labs(
      title = "Danceability",
      x = ""
   )

p_energy <- df |>
   ggplot(aes(energy)) +
   geom_density(fill = "#3E4A89FF") +
   theme_minimal() +
   labs(
      title = "Energy",
      x = ""
   )

p_instru <- df |>
   ggplot(aes(instrumentalness)) +
   geom_density(fill = "#31688EFF", bw = 0.003) +
   coord_cartesian(xlim = c(0, 0.05)) +
   theme_minimal() +
   labs(
      title = "Instrumentalness (< 0.05)",
      x = ""
   )

p_key <- df |>
   ggplot(aes(key, fill = key)) +
   geom_bar() +
   scale_fill_viridis_d() +
   theme_minimal() +
   labs(
      title = "Key",
      x = ""
   ) +
   theme(legend.position = "none")

p_live <- df |>
   ggplot(aes(liveness)) +
   geom_density(fill = "#26828EFF") +
   theme_minimal() +
   labs(
      title = "Liveness",
      x = ""
   )

p_loud <- df |>
   ggplot(aes(loudness)) +
   geom_density(fill = "#1F9E89FF") +
   theme_minimal() +
   labs(
      title = "Loudness",
      x = ""
   )

p_mode <- df |>
   ggplot(aes(mode, fill = mode)) +
   geom_bar() +
   theme_minimal() +
   scale_fill_viridis_d() +
   labs(
      title = "Mode",
      x = ""
   ) +
   theme(legend.position = "none")

p_s_dur <- df |>
   ggplot(aes(duration_ms)) +
   geom_density(fill = "#35B779FF") +
   theme_minimal() +
   labs(
      title = "Song duration",
      x = ""
   )

p_speech <- df |>
   filter(speechiness > 0) |>
   ggplot(aes(speechiness)) +
   geom_density(fill = "#6DCD59FF") +
   scale_x_continuous(transform = "log10") +
   theme_minimal() +
   labs(
      title = "Speechiness (log transform)",
      x = ""
   )

p_t_sig <- df |>
   ggplot(aes(time_signature, fill = time_signature)) +
   geom_bar() +
   theme_minimal() +
   labs(
      title = "Time signature",
      x = ""
   ) +
   theme(legend.position = "none")

p_tempo <- df |>
   ggplot(aes(tempo)) +
   geom_density(fill = "#B4DE2CFF") +
   theme_minimal() +
   labs(
      title = "Tempo",
      x = ""
   )

p_val <- df |>
   ggplot(aes(valence)) +
   geom_density(fill = "#FDE725FF") +
   theme_minimal() +
   labs(
      title = "Valence",
      x = ""
   )

# Format the combined plot.

design <- "
   ABCD
   EFGH
   IJKK
   MMPP
   "

p_acou + p_dance + p_energy + p_instru + p_live + p_loud + p_speech +
   p_s_dur + p_tempo + p_val + p_mode + p_t_sig + p_key +
   plot_layout(design = design) +
   plot_annotation(title = "Song features")

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

# Scatterplots for correlated variables -----------------------------------

ggplot(df, aes(x = loudness, y = energy, colour = acousticness)) +
   geom_point() +
   theme_minimal() +
   scale_colour_viridis_c() +
   labs(title = "Loudness energy correlation") +
   theme(legend.key.height = unit(3, "cm"))

ggplot(df, aes(x = acousticness, y = energy, colour = loudness)) +
   geom_point() +
   theme_minimal() +
   scale_colour_viridis_c() +
   labs(title = "Acousticness energy correlation") +
   theme(legend.key.height = unit(3, "cm"))

ggplot(df, aes(x = acousticness, y = loudness, colour = energy)) +
   geom_point() +
   theme_minimal() +
   scale_colour_viridis_c() +
   labs(title = "Acousticness loudness correlation") +
   theme(legend.key.height = unit(3, "cm"))

ggplot(df, aes(x = valence, y = danceability)) +
   geom_point(colour = "#440154FF") +
   theme_minimal() +
   labs(title = "Valence danceability correlation")
