# -*- coding: utf-8 -*-
"""
Created on Thu Nov 14 12:33:33 2024

@author: J-P-F
"""
# Import packages
import re
from urllib.request import urlopen
from bs4 import BeautifulSoup
import pandas as pd

# Base URL with placeholder for page number
base_url = "https://worldathletics.org/records/competition-performance-rankings?type=2&year=2024&sortBy=score&page={}"

# List to store all rows across pages
all_rows = []
clean = re.compile('<.*?>')  # Regular expression to match HTML tags

# Loop through each page (assuming there are 12 pages)
for page_num in range(13):  
    url = base_url.format(page_num)
    print(f"Scraping page {page_num}: {url}")
    
    # Fetch the page content
    html = urlopen(url)
    soup = BeautifulSoup(html, 'lxml')
    
    # Find all table rows
    rows = soup.find_all('tr')
    print(f"Found {len(rows)} rows on page {page_num}.")

    # Loop through rows and clean the data
    for row in rows:
        cells = row.find_all('td')
        str_cells = str(cells)
        # Remove HTML tags
        clean_text = re.sub(clean, '', str_cells)
        # Strip unwanted characters (e.g., brackets) and append to all_rows
        clean_text = clean_text.strip("[]")  # Remove square brackets
        all_rows.append(clean_text)
    

# Split cleaned text by commas and convert each row into a list of cells
all_rows = [row.split(", ") for row in all_rows]

# Create DataFrame from all scraped data
df = pd.DataFrame(all_rows)

# Export to CSV
# df.to_csv("track_and_field_competition_rankings.csv", index=False)
# print("Data successfully scraped and saved to 'track_and_field_competition_rankings.csv'")
