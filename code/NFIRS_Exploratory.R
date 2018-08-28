library(tidyverse)
library(lubridate)
library(magrittr)
library(glue)
root.dir <- c("C:/Users/Dov/Documents/CPSM", "/home/dchelst/Documents")
year <- 2016
nfirs.dir <- root.dir %>%
  lapply(list.dirs) %>%
  #lapply(grep, pattern="NFIRS.*2015", value=TRUE) %>%
  lapply(grep, pattern=paste0("NFIRS.*", year), value=TRUE) %>%
  unlist
setwd(nfirs.dir)

if(file.exists("NFIRS-2015-2016-IncidentsByDateByAgency.rds")){
  incident.type.by.agency <- 
    readRDS("NFIRS-2015-2016-IncidentsByDateByAgency.rds")
  incident.date.by.agency <- 
    readRDS("NFIRS-2015-2016-IncidentsByDateByAgency.rds")
} else {
  basic.2016 <- readRDS("NFIRS-2016-basicincident1.rds")
  basic.2015 <- readRDS("../NFIRS-2015/NFIRS-2015-basicincident1.rds")
  basic <- bind_rows(basic.2015, basic.2016) %>%
    mutate(year = year(INC_DATE))
  rm(basic.2015, basic.2016)
  codes <- readRDS("NFIRS-codes.rds")
  fd.list <- readRDS("NFIRS-2016-fdlist.rds")
  names(basic) %<>% tolower %>% gsub(pattern="_", replacement=".")
  incident.type.by.agency <- basic %>%
    filter(exp.no==0) %>%
    count(state, fdid, inc.type, year) %>%
    ungroup 
  
  incident.date.by.agency <- basic %>%
    filter(exp.no==0) %>%
    count(state, fdid, inc.date) %>%
    ungroup
  rm(basic)
  saveRDS(incident.type.by.agency, "NFIRS-2015-2016-IncidentTypesByAgency.rds")
  saveRDS(incident.date.by.agency, "NFIRS-2015-2016-IncidentsByDateByAgency.rds")
  
}

# call type analysis
incident.types <- codes %>%
  set_names(gsub("_", ".", names(codes))) %>%
  filter(fieldid=="INC_TYPE") %>% 
  filter(grepl("^\\d+$", code.value), !is.na(code.value)) %>%  
  select(inc.type=code.value, inc.description=code.descr) %>%
  mutate(inc.type=as.numeric(inc.type)) 

medical.types <- incident.types %>% 
  filter(inc.type %in% c(300, 311, 320, 321, 661))
fire.types <- incident.types %>% 
  filter(inc.type %in% 
           c(100, 111:118, 120:123, 130:138, 140:143, 150:155, 160:164, 
             170:173, 400, 410:413, 420:424, 430:431, 440:445, 451, 
             460:463, 471, 480:482, 561, 631:632))
accident.types <- incident.types %>% 
  filter(inc.type %in% c(322:324)) 

call.type.file <- "NFIRS-2015-2016-CallTypesByAgency.rds"
if(file.exists(call.type.file)){
  incident.call.type.by.agency <- readRDS(call.type.file)
} else {
  incident.call.type.by.agency <- incident.type.by.agency %>%
    mutate(call.type = case_when(
      inc.type %in% medical.types$inc.type ~ "medical",
      inc.type %in% fire.types$inc.type ~ "fire",
      inc.type %in% accident.types$inc.type ~ "accident",
      TRUE ~ "other"
    )) %>%
    count(state, fdid, year, call.type, wt=n) %>%
    ungroup
  saveRDS(incident.call.type.by.agency, call.type.file)
} 

missing <- fd.list %>% 
  select(STATE, FDID) %>% 
  dplyr::setdiff(distinct(basic.2016, STATE, FDID)) %>%
  left_join(fd.list)

missing %>% 
  mutate_at(vars(matches("NO")), replace_na, 0) %>%
  mutate(TOTAL_FF = NO_PD_FF + NO_VOL_FF + NO_VOL_PDC) %>%
  arrange(desc(TOTAL_FF)) %>%
  head(10)
