# Test file for R IDE features
library(dplyr)
library(meta)
library(netmeta)

# Create some example data
data <- data.frame(
    study = c("Study1", "Study2", "Study3"),
    treatment = c("A", "B", "A"),
    control = c("B", "C", "C"),
    n_treatment = c(100, 150, 120),
    n_control = c(100, 150, 120),
    mean_treatment = c(10, 15, 12),
    mean_control = c(8, 13, 9),
    sd_treatment = c(2, 3, 2.5),
    sd_control = c(2, 3, 2.5)
)

# Using dplyr for data manipulation
data_processed <- data %>%
    mutate(
        effect_size = mean_treatment - mean_control,
        pooled_sd = sqrt((sd_treatment^2 + sd_control^2) / 2)
    )

# Perform meta-analysis
meta_result <- metacont(
    n.e = n_treatment,
    mean.e = mean_treatment,
    sd.e = sd_treatment,
    n.c = n_control,
    mean.c = mean_control,
    sd.c = sd_control,
    studlab = study,
    data = data
)

# Print results
print(meta_result)

# Network meta-analysis preparation
# Instead of using pairwise, we'll use the netmeta function directly
# with the appropriate data format
net_data <- data.frame(
    studlab = rep(data$study, 2),
    treat = c(data$treatment, data$control),
    n = c(data$n_treatment, data$n_control),
    mean = c(data$mean_treatment, data$mean_control),
    sd = c(data$sd_treatment, data$sd_control)
)

# Perform network meta-analysis
net_result <- netmeta(
    TE = effect_size,
    seTE = pooled_sd/sqrt(n_treatment + n_control),
    treat = treatment,
    studlab = study,
    data = data_processed
)

# Print network meta-analysis results
print(net_result) 