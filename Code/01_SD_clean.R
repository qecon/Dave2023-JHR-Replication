library(stringr)
library(dplyr)
library(readr)
cbg_pop <- read.csv("data/cbg_pop.csv") %>% select(census_block_group,B01001e1) %>% rename(pop=B01001e1)

d <- c(15:31)
may <- paste0("05","-",str_pad(d,2, pad = "0"))
d <- c(1:13)
jun  <- paste0("06","-",str_pad(d,2, pad = "0"))

days <- c(may,jun)


for (day in days){

m <- substr(day,1,2)
d <- substr(day,4,5)
print(paste0(m,"-",d))

data <- 
  read_csv(paste0("../../safe_graph_data/2020-",m,"-",d,"-social-distancing.csv.gz")) %>%  
  mutate(origin_census_block_group=origin_census_block_group %>% as.numeric(),state_fips=floor(origin_census_block_group/10000000000)) %>% 
  mutate(county_fips=floor(origin_census_block_group/10000000)) %>% rename(census_block_group=origin_census_block_group) %>% 
  merge(read.csv("data/stateFIPS.csv") %>% select(state_fips),by="state_fips") %>% 
  merge(cbg_pop,by="census_block_group") %>% 
  mutate(pop=pop %>% as.numeric(),
         pct_home=completely_home_device_count/device_count,
         pct_full=full_time_work_behavior_devices/device_count,
         pct_part=part_time_work_behavior_devices/device_count,
         travel=distance_traveled_from_home,
         pct_time_home=median_percentage_time_home,
         home_dwell=median_home_dwell_time,
         non_home_dwel=median_non_home_dwell_time) %>%  
  select(state_fips,county_fips,pop,pct_home,pct_full,pct_part,pct_time_home,travel,home_dwell,non_home_dwel) %>% 
  group_by(state_fips,county_fips) %>%
  # summarise_all(mean) %>% 
  summarise(pct_home = weighted.mean(pct_home,pop),
            pct_full = weighted.mean(pct_full,pop),
            pct_part = weighted.mean(pct_part,pop),
            pct_time_home = weighted.mean(pct_time_home,pop),
            home_dwell = weighted.mean(home_dwell,pop),
            non_home_dwel = weighted.mean(non_home_dwel,pop)) %>%
  mutate(date=paste0(m,"-",d)) 


write.csv(data,paste0("Data/Safegraph/pct_home",m,"-",d,".csv"),row.names=F)
}

