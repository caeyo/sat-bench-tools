#!/bin/bash

# use as basis for constructing mass downloads from SAT benchmark DB

# for all in main track
mkdir main_track_allyrs
cd main_track_allyrs
wget --content-disposition "https://benchmark-database.de/getinstances?query=track%3Dmain_2017+or+track%3Dmain_2018+or+track%3Dmain_2019+or+track%3Dmain_2020+or+track%3Dmain_2021+or+track%3Dmain_2022+or+track%3Dmain_2023+or+track%3Dmain_2024&context=cnf"
wget --content-disposition --inet4-only -nc -U "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/58.0.3029.110 Safari/537.3" --no-check-certificate -i "track_main_2017_or_track_main_2018_or_track_main_2019_or_track_main_2020_or_track_main_2021_or_track_main_2022_or_track_main_2023_or_track_main_2024.uri" # various options for speed improvements
rm "track_main_2017_or_track_main_2018_or_track_main_2019_or_track_main_2020_or_track_main_2021_or_track_main_2022_or_track_main_2023_or_track_main_2024.uri"
