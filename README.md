# Abandoned Wells in New York State

This is the Github repository for our article on abandoned wells in New York State. The contents of the repository are as follows:

[wells_1860.ipynb](https://github.com/ilenapeng/wells/blob/main/wells_1860.ipynb) & [wells_abandoned.ipynb](https://github.com/ilenapeng/wells/blob/main/wells_abandoned.ipynb): The script for our data analysis

graphics: Contains the charts included in the article, along with the R script for generating them

[data_raw](https://github.com/ilenapeng/wells/tree/main/data_raw): Contains the raw data from the New York State Department of Environmental Conservation, Division of Mineral Resources, via Open Data NY used in this analysis

* [wells_1860.csv](https://github.com/ilenapeng/wells/blob/main/data_raw/wells_1860.csv) — [Oil, Gas, & Other Regulated Wells: Beginning 1860](https://data.ny.gov/Energy-Environment/Oil-Gas-Other-Regulated-Wells-Beginning-1860/szye-wmt3). Is updated daily, our download is from October 5 
* [wells_abandoned.csv](https://github.com/ilenapeng/wells/blob/main/data_raw/wells_abandoned.csv) —  [Abandoned Wells](https://data.ny.gov/Energy-Environment/Abandoned-Wells/vgue-bamz). Is updated annually, documents abandoned and unplugged oil & gas wells 

[data_output](https://github.com/ilenapeng/wells/tree/main/data_output): CSVs we generated from the raw data
* [timespan.csv](https://github.com/ilenapeng/wells/blob/main/data_output/timespan.csv) (from wells_1860.ipynb) — Used to generate violin plot, time between the dates a well was completed and plugged
* [timespan_summ.csv](https://github.com/ilenapeng/wells/blob/main/data_output/timespan_summ.csv) (from wells_1860.ipynb) — Summary statistics by county, for time between the dates a well was completed and plugged
* [plug_abdn.csv](https://github.com/ilenapeng/wells/blob/main/data_output/plug_abdn.csv) (from wells_1860.ipynb) — Number of abandoned and plugged wells in each county
* [active.csv](https://github.com/ilenapeng/wells/blob/main/data_output/active.csv) (from wells_1860.ipynb) — Number of active wells in each county
* [unplug_abdn.csv](https://github.com/ilenapeng/wells/blob/main/data_output/unplug_abdn.csv) (from wells_abandoned.ipynb) — Number of abandoned and unplugged wells in each county
