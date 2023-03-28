library(did)
library(dplyr)
library(ggplot2)
library(foreign)
library(readstata13)

current_dir <- getwd() ## Make sure to set directory here

### Function to plot data
CS_Estimator <- function(data, outcome, wt, ylab) {
  
  atts <- att_gt(
    yname=outcome,
    tname="date",
    idname = "fips",
    gname="policy_date",
    xformla = NULL,
    data= data,
    panel = TRUE,
    allow_unbalanced_panel = FALSE,
    control_group =  c("notyettreated"),
    anticipation = 0,
    weightsname = wt,
    alp = 0.05,
    bstrap = TRUE,
    cband = TRUE,
    biters = 1000,
    clustervars = "fips",
    est_method = "dr",
    print_details = FALSE,
    pl = FALSE,
    cores = 1
  )
  
  
  # Event-study
  agg_effects_es <- aggte(atts, type = "dynamic", na.rm=TRUE)
  
  #Export Overall Beta/SE
  save = outcome #Filename will be yvariable
  
  
  # Plot event-study coefficients
  plot <-  ggdid(agg_effects_es, xgap=3) + 
    xlim(xmin, xmax) +
    theme_classic() +
    theme(legend.position = "none") + 
    labs(x="Time Since Protest", y=paste0("Effect on ", ylab)) +
    geom_hline(yintercept =0, size=1.1, color="gray45") +
    geom_vline(xintercept =-0.5, size=1.1, color="gray45") +
    geom_line() +  geom_point(size=2.5) + 
    geom_errorbar(width=0.4, position=position_dodge(width=4), color="grey20") + 
    scale_x_continuous(limits=c(xmin-.3, xmax+.3,1), breaks = seq(xmin,xmax, by=2)) +
    labs(title="", col="") 
  if (yscale=="yes") {
    plot <- plot + scale_y_continuous(limits=c(ymin, ymax), n.breaks=4) 
  } 
  ggsave(filename=paste0("Figure/CS/es_", save, ".png"), plot=plot, width=12*.7, height=8*.7)
  
}


##################### Load Data #####################
data_case <- read.dta("Data/CS_Data.dta")
data_case <-subset(data_case, primary_county==1)
data_case <- pre_mean(data_case)

############################### Figure 4 ################################

xmin=-11 #Cut the left end point
xmax=35 #Cut the right end point
yscale="yes" # Set to "yes" if I want to manually scale y-axis.
ymin=-0.02
ymax = 0.02
CS_Estimator(data=data_case, outcome="case_growth", wt="countypop", ylab="COVID-19 Case Growth")
CS_Estimator(data=data_case, outcome="death_growth", wt="countypop", ylab="COVID-19 Death Growth")
CS_Estimator(data=data_case, outcome="hosp_growth", wt="countypop", ylab="COVID-19 Hospitalization Growth")



############################### Figure 5 ################################
yscale="yes" # Set to "yes" if I want to manually scale y-axis.
ymin=-0.02
ymax = 0.02
CS_Estimator(data=data_case, outcome="case_agetotal2_growth", wt="countypop", ylab="COVID-19 Case Growth")
CS_Estimator(data=data_case, outcome="case_age20to39_growth", wt="age20to39", ylab="COVID-19 Case Growth")
CS_Estimator(data=data_case, outcome="case_age40to59_growth", wt="age40to59", ylab="COVID-19 Case Growth")
CS_Estimator(data=data_case, outcome="case_age60p_growth", wt="age60p", ylab="COVID-19 Case Growth")



############################### Figure 6 ################################
yscale="yes" # Set to "yes" if I want to manually scale y-axis.
ymin=-0.02
ymax = 0.02
CS_Estimator(data=data_case, outcome="hosp_growth",  wt="countypop", ylab="COVID-19 Hospitalization Growth")
CS_Estimator(data=data_case, outcome="hosp_age20to39_growth",  wt="age20to39", ylab="COVID-19 Hospitalization Growth")
CS_Estimator(data=data_case, outcome="hosp_age40to59_growth", wt="age40to59", ylab="COVID-19 Hospitalization Growth")
CS_Estimator(data=data_case, outcome="hosp_age60p_growth",  wt="age60p", ylab="COVID-19 Hospitalization Growth")






