#!/usr/bin/env Rscript

# Set the file path
file_path <- "missing_damage_grade.csv"

# Load the data
data <- read.csv(file_path)

# Print the loaded data
print(data)
library(ggplot2)

# Create a scatter plot of the data
ggplot(data, aes(x = x_column, y = y_column)) + geom_point() + labs(x = "X Axis", y = "Y Axis") + ggtitle("Data Scatter Plot")

# Save the plot as an image file
ggsave("data_plot.png")