library(rgdal)
library(tidyverse)
library(extrafont)
library(sf)
library(tigris)
library(ggtext)

### Loading data
# Abandoned and unplugged
abandoned <- read_csv('https://raw.githubusercontent.com/ilenapeng/wells/main/data_raw/wells_abandoned.csv')
# Abandoned and unplugged counts, by county & drop index column
unplug_abdn <- read_csv('https://raw.githubusercontent.com/ilenapeng/wells/main/data_output/unplug_abdn.csv')
unplug_abdn <- unplug_abdn[ -c(1) ]
# Abandoned and plugged well counts, by county & drop index column
plug_abdn <- read_csv('https://raw.githubusercontent.com/ilenapeng/wells/main/data_output/plug_abdn.csv')
plug_abdn <- plug_abdn[ -c(1) ]
# All active wells
active <- read_csv('https://raw.githubusercontent.com/ilenapeng/wells/main/data_output/active_all.csv')
active <- active[ -c(1) ]
# Active well counts, by county & drop index column
active_ct <- read_csv('https://raw.githubusercontent.com/ilenapeng/wells/main/data_output/active.csv')
active_ct <- active[ -c(1) ]
# Time between completed and plugged
timespan <- read_csv('https://raw.githubusercontent.com/ilenapeng/wells/main/data_output/timespan.csv')
timespan <- timespan[ -c(1) ]

#Chart theme
plot_theme <- theme(
  text=element_text(family="Helvetica", color="black"), 
  plot.title=element_text(face="bold", size=16), 
  plot.subtitle=element_text(size=12), 
  plot.caption=element_text(size=8),
  plot.margin=margin(1,1,1,1, "cm"),
  axis.title.y=element_blank(),
  axis.title.x=element_text(color="black", face="bold", size=12),
  axis.text=element_text(color="black", size=12),
  legend.position="left",
  legend.title=element_blank())

########### Map of abandoned and unplugged wells
#Removing nulls now for plotting purposes - did not remove them in the counts because they were not marked as UM 
abandoned <- abandoned %>% filter(!is.na(`SURFACE LONGITUDE`) & !is.na(`SURFACE LATITUDE`)) 
active <- active %>% filter(!is.na(`Surface Longitude`) & !is.na(`Surface Latitude`)) 
#Merging wells data and shapefile
ny <- counties("New York", cb = TRUE)
merge <- ny %>% full_join(unplug_abdn, by = c("NAME" = "county"))

p_abdn <-
  ggplot() +
  geom_sf(data=merge, fill="#E9F3E2", color="white") +
  geom_point(data=active, aes(x=SurfaceLongitude, y=SurfaceLatitude), alpha=0.1, size=0.05, color="#562399") +
  geom_point(data=abandoned, aes(x=`SURFACE LONGITUDE`, y=`SURFACE LATITUDE`), alpha=0.2, size=0.05, color="#3FA62E") +
  theme_void() +
  labs(
    title="Western New York is the region of concern - for both<br><span style='color:#3FA62E'>abandoned & unplugged</span> and <span style='color:#562399'>active</span> wells", 
    subtitle="Documented abandoned & unplugged and active wells in New York",
    caption="Data from NY State Department of Environmental Conservation via NY Open Data\nGraphic by Ilena Peng") +
  plot_theme + theme (plot.title=element_markdown(face="bold", size=16), axis.text=element_blank(), axis.title.x=element_blank())

print(p_abdn)
ggsave("map_abandoned.png", width=9, height=6, unit="in")

########### Dot plot of unplugged and abandoned vs active wells
#Merge these two datasets
abdn_active <- full_join(unplug_abdn, active, by = c("county" = "County"))
abdn_active = rename(abdn_active,c("abandon"="count","active"="Ct"))
#replace NAs with 0
abdn_active[is.na(abdn_active)] <- 0
## Creating "Other counties" designation
#variable for keep or not
abdn_active$keep = ifelse(abdn_active$abandon >= 30, "yes", "no")
#calculate means for each group so we know the "no" values
abdn_active %>% group_by(keep) %>% summarise(abandon_avg = mean(abandon), active_avg = mean(active))
# No: abandon average is 6.82, active average is 50.7
for_plt <- abdn_active %>% filter(keep=="yes")
#Add in our new averaged row
for_plt <- for_plt %>% add_row(county = "Other counties", abandon = 6.82, active=50.7)

#Adding if-else statements for visual hierarchy
pt_alpha = ifelse(for_plt$county == "Allegany" | for_plt$county == "Chautauqua", 0.8, 0.5)
pt_size = ifelse(for_plt$county == "Allegany" | for_plt$county == "Chautauqua", 4, 3)
line_color = ifelse(for_plt$county == "Allegany" | for_plt$county == "Chautauqua", "black", "gray")

p_abdn_active <- for_plt %>% 
  ggplot(aes(y=reorder(county, abandon))) +
  geom_segment( aes(x=abandon, xend=active, y=reorder(county, abandon), yend=reorder(county, abandon)), color=line_color) +
  geom_point(aes(x=abandon), color="#889933", size=pt_size, alpha=pt_alpha) +
  geom_point(aes(x=active), color="#562399", size=pt_size, alpha=pt_alpha) +
  labs (
    title="Unplugged wells in Allegany County, former seat of New York oil\nindustry, now exceed number of active wells",
    subtitle="Abandoned and unplugged wells in New York counties with more than 50 abandoned wells",
    caption="Data from NY State Department of Environmental Conservation via NY Open Data\nGraphic by Ilena Peng",
    x="Number of wells"
  ) +
  theme_minimal() +
  plot_theme

print(p_abdn_active)
ggsave("abdn_active.png", width=9, height=6, unit="in")

#Plugged and abandoned vs unplugged and abandoned
plug_unplug <- full_join(unplug_abdn, plug_abdn, by = c("county" = "County"))
plug_unplug = rename(plug_unplug,c("unplug"="count","plug"="Count"))
#Replace NAs with 0
plug_unplug[is.na(plug_unplug)] <- 0

## Creating "Other counties" designation
#variable for keep or not
plug_unplug$keep = ifelse(
  plug_unplug$county == "Allegany" |
  plug_unplug$county == "Cattaraugus" |
  plug_unplug$county == "Steuben" |
  plug_unplug$county == "Erie" |
  plug_unplug$county == "Chautauqua", "yes", "no")

#calculate means for each group so we know the "no" values
plug_unplug %>% group_by(keep) %>% summarise(plug_avg = mean(plug), unplug_avg = mean(unplug))
# No: plug average is 27.6, unplug average is 10.8
for_barplt <- plug_unplug %>% filter(keep=="yes")
#Add in our new averaged row
for_barplt <- for_barplt %>% add_row(county = "Other counties", unplug=10.8, plug = 27.6)
#Drop keep column
for_barplt <- for_barplt[ -c(4) ]

#Gather data for stacked bar & drop keep column
gather <- gather(for_barplt, "type", "count", -county)
gather$type <- factor(gather$type, levels = c('unplug','plug'))

p_plug_unplug <- gather %>% 
  ggplot(aes(y=reorder(county, count), x=count, fill=type)) +
  geom_bar(position="dodge", stat="identity") +
  scale_fill_manual(values=c("#889933", "#429799"), labels=c("Unplugged","Plugged")) +
  labs (
    title="Most documented abandoned wells in NY are already plugged, but\nthousands more are undocumented and unplugged",
    subtitle="Top counties with the most plugged and unplugged abandoned wells",
    caption="Data from NY State Department of Environmental Conservation via NY Open Data\nGraphic by Ilena Peng",
    x="Number of wells"
  ) +
  theme_minimal() +
  plot_theme +
  theme(legend.position="top", legend.text=element_text(size=12))

print(p_plug_unplug)
ggsave("plug_unplug.png", width=9, height=6, unit="in")

### Timespan chart
counties <- c("Allegany", "Cattaraugus", "Steuben", "Genesee", "Erie", "Chautauqua", "Wyoming")
plt_counties <- timespan %>% filter(County %in% counties)

p_timespan <- plt_counties %>%
  mutate(County = fct_rev(factor(County, levels=counties))) %>% 
  ggplot(aes(x=WellTime_Yr, y=County)) + 
  geom_violin(fill="#889933", color="#889933") +
  stat_summary(fun="mean", geom="point", shape=124, size=8, color="#414A12") +
  labs(
    title="NY oil and gas wells are open on average only for the typical 20 to\n30-year lifespan, but some remain unplugged much longer",
    subtitle="Years between well completion and plugging in counties that had over 100 wells with complete data",
    caption="Data from NY State Department of Environmental Conservation via NY Open Data\nGraphic by Ilena Peng",
    x="Years"
  ) + theme_minimal() + plot_theme

print(p_timespan)
ggsave("timespan.png",  width=9, height=6, unit="in")



