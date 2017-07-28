library(tidyverse)
library(magrittr)
root.dir <- c("C:/Users/Dov/Documents/CPSM", "/home/dchelst/Documents")
nfirs.dir <- list.dirs(root.dir[1]) %>% 
  grep("NFIRS.*2015", ., value=TRUE)
setwd(nfirs.dir)

basic.file <- "basicincident.txt"
ff.casualty.file <- "ffcasualty.txt"
civilian.casualty.file <- "civiliancasualty.txt"
basic <- read_delim(basic.file, delim="^", n_max=10)
ff.casualty <- read_delim(ff.casualty.file, delim="^", n_max=10)
civilian.casualty <- read_delim(civilian.casualty.file, delim="^", n_max=10)

d.format <- "%m%d%Y"
dt.format <- "%m%d%Y%H%M"
# the columns that I need for basic incident table
basic.cols <- cols(STATE=col_character(), FDID=col_character(), 
  INC_DATE=col_date(format=d.format), INC_NO=col_character(), 
  EXP_NO=col_integer(), INC_TYPE=col_integer(), AID=col_character(),
  #ALARM=col_datetime(format=dt.format),  ARRIVAL=col_datetime(dt.format),
  FF_DEATH=col_integer(), OTH_DEATH=col_integer(), 
  FF_INJ=col_integer(), OTH_INJ=col_integer(),
  .default=col_skip())
basic1 <- read_delim(basic.file, delim="^", col_types=basic.cols)
saveRDS(basic1, file="NFIRS-2015-basicincident1.rds")

ff.casualty.cols <- cols(STATE=col_character(), FDID=col_character(),
  INC_DATE=col_date(format=d.format), INC_NO=col_character(),
  EXP_NO=col_integer(), 
  GENDER=col_integer(), CAREER=col_integer(), AGE=col_integer(),
  INJ_DATE = col_datetime(format=dt.format),
  .default=col_skip())
ff.casualty1 <- read_delim(ff.casualty.file, delim="^", 
                           col_types=ff.casualty.cols)
saveRDS(ff.casualty1, file="NFIRS-2015-ffcasualty1.rds")

# analysis of calls by agency
basic.2015 <- readRDS("NFIRS-2015-basicincident1.rds")

incident.type.by.agency <- basic.2015 %>%
  filter(EXP_NO==0) %>%
  count(STATE, FDID, INC_TYPE) %>%
  ungroup

call.by.agency <- incident.type.by.agency %>%
  count(STATE, FDID, wt=n) %>%
  ungroup

incident.by.type <- incident.type.by.agency %>%
  count(INC_TYPE, wt=n) %>%
  ungroup %>%
  mutate(percent = nn / sum(nn))

# departments based upon total calls
call.by.agency %$% quantile(nn, probs=seq(0, 1, .1))

# medical call percentage for "larger" departments
call.min <- 100
large.agencies <- call.by.agency %>%
  filter(nn >= call.min) %>%
  select(STATE, FDID) 
incident.by.type.larger <- incident.type.by.agency %>%
  inner_join(large.agencies) %>%
  count(INC_TYPE, wt=n) %>%
  ungroup %>%
  mutate(percent = nn / sum(nn))



save(incident.type.by.agency, call.by.agency, incident.by.type, 
     file="NFIRS-2015-BasicAnalysis.RData")  
