################ This R Code will clean CDC's race specific COVID-19 cases data ##################################
library(dplyr)
library(dummies)
library(data.table)
library(readstata13)


### Load in protest dates to filter data
protest <- read.dta13(paste0(datadir2,"Protest.dta")) %>% 
  select(fips) %>% group_by(fips) %>% filter(row_number()==1 & fips!=36999)
protest$county_fips_code = protest$fips


## Varlist to keep
variable <- c("current_status", 
              "race_ethnicity_combined", 
              "age_group", 
              "sex", 
              "county_fips_code", 
              "cdc_case_earliest_dt",
              "death_yn",
              "pos_spec_dt")

## Funciton to load & filter data
import_filter <- function(import) {
  data <- read.csv(paste0("Data/CDC/", import)) %>% select(variable) %>% 
          filter(pos_spec_dt <= "2020-07-07" | cdc_case_earliest_dt <= "2020-07-07" )
  data$test_date <- data$pos_spec_dt
  data
}

## Load & append each dataset
data1 <- import_filter("20210718_Ridura_32_Part1.csv")
data2 <- import_filter("20210718_Ridura_32_Part2.csv")
data3 <- import_filter("20210718_Ridura_32_Part3.csv")
data4 <- import_filter("20210718_Ridura_32_Part4.csv")
data <- rbind(data1, data2, data3, data4)


### Clean Demographic variables
data$age_group <- ifelse(data$age_group=="NA", "Missing", data$age_group) ##Combine Missing & NA
data$race = data$race_ethnicity_combined
data = data %>% mutate(race=replace(race, race=="Black, Non-Hispanic", "Black"))
data = data %>% mutate(race=replace(race, race=="White, Non-Hispanic", "White"))
data = data %>% mutate(race=replace(race, race=="Hispanic/Latino", "Hispanic"))
data = data %>% mutate(race=replace(race, race=="Missing" | race=="Unknown", "Missing"))
data = data %>% mutate(race=replace(race, race!="Black" & race!="White" & race!="Hispanic" & race!="Unknown", "Other"))
data$race = ifelse(is.na(data$race), "Missing", data$race)
           

### Final clean/collapsing of the data
data$date <- data$test_date
data <- data %>% mutate(death_yn=ifelse(death_yn=="Yes", "Yes", "No"))
data_new = data %>% filter(date <= "2020-07-07")
data_new = data_new %>%
  group_by(county_fips_code, age_group, date, race, death_yn) %>%
  summarize(new_cases = n())
setDT(data_new)
data_new = dcast(data_new, county_fips_code + date + race + death_yn ~ age_group,
                 value.var = "new_cases")

data_new$age0to9 <- data_new$`0 - 9 Years`
data_new$age10to19 <- data_new$`10 - 19 Years`
data_new$age20to29 <- data_new$`20 - 29 Years`
data_new$age30to39 <- data_new$`30 - 39 Years`
data_new$age40to49 <- data_new$`40 - 49 Years`
data_new$age50to59 <- data_new$`50 - 59 Years`
data_new$age60to69 <- data_new$`60 - 69 Years`
data_new$age70to79 <- data_new$`70 - 79 Years`
data_new$age80p <- data_new$`80+ Years`
data_new$agemissing <- data_new$Missing

data_new <- data_new %>% select(county_fips_code, date,  race, death_yn, age0to9, age10to19, age20to29, age30to39,
                                age40to49, age50to59, age60to69, age70to79, age80p, agemissing)
data_new <- right_join(data_new, protest, by = "county_fips_code")

write.csv(data_new, "Data/CDC_Age_Spec_Cases.csv", row.names = TRUE)







