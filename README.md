# Competition-Performance-Rankings
![](https://upload.wikimedia.org/wikipedia/en/c/ce/World_Athletics_Championships.png)

## Overview

This project focuses on processing and analyzing track and field competition rankings using SQL. It includes data cleaning, transformation, and optimization to ensure accurate rankings and meaningful insights.

## Data Source

The data used in this project comes from the [World Athletics Competition Performance Rankings](https://worldathletics.org/records/competition-performance-rankings?type=2&year=2024&sortBy=score&page=1). The data has been webscraped using a [Python script](https://github.com/Data-JP/Competition-Performance-Rankings/blob/main/track_and_field_competition_rankings.py) to extract relevant ranking information for further processing.

## Features

- **Data Cleaning**: Handles missing values, duplicate records, and misaligned data.

- **Column Renaming**: Updates ambiguous column names for better readability.

- **Data Type Conversion**: Ensures consistency by converting necessary columns to appropriate data types.

- **Duplicate Handling**: Identifies and removes duplicate records using SQL window functions.

- **Special Character Cleaning**: Implements a function to replace encoding errors in textual data.

- **Performance Optimization**: Ensures efficient querying and data retrieval.
