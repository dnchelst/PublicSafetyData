library(tidyverse)
library(lubridate)
library(magrittr)


root.dir <- c("C:/Users/Dov/Documents/CPSM", "/home/dchelst/Documents")
nfirs.dir <- root.dir %>%
  lapply(list.dirs) %>%
  lapply(grep, pattern="NFIRS.*2015", value=TRUE) %>%
  unlist
setwd(nfirs.dir)

basic.file <- "basicincident.txt"
ff.casualty.file <- "ffcasualty.txt"
civilian.casualty.file <- "civiliancasualty.txt"
basic <- read_delim(basic.file, delim="^", n_max=10000)
ff.casualty <- read_delim(ff.casualty.file, delim="^", n_max=10)
civilian.casualty <- read_delim(civilian.casualty.file, delim="^", n_max=10)

d.format <- "%m%d%Y"
dt.format <- "%m%d%Y%H%M"
# the columns that I need for basic incident table
basic.cols <- cols_only(STATE="c", FDID="c", 
  INC_DATE=col_date(format=d.format), 
  INC_NO="c", EXP_NO="i", INC_TYPE="i", AID="c",
  ALARM=col_datetime(format=dt.format),  ARRIVAL=col_datetime(dt.format),
  FF_DEATH="i", OTH_DEATH="i", FF_INJ="i", OTH_INJ="i")
basic1 <- read_delim(basic.file, delim="^", col_types=basic.cols)
saveRDS(basic1, file="NFIRS-2015-basicincident1.rds")

basic.2014 <- file.path("../2014", basic.file) %>% 
  read_delim(delim="^", col_type=basic.cols)

ff.casualty.cols <- cols_only(STATE="c", FDID="c", 
  INC_DATE=col_date(format=d.format), 
  INC_NO="c", EXP_NO="i", GENDER="i", CAREER="i", AGE="i", 
  INJ_DATE = col_datetime(format=dt.format))
ff.casualty1 <- read_delim(ff.casualty.file, delim="^", 
                           col_types=ff.casualty.cols)
saveRDS(ff.casualty1, file="NFIRS-2015-ffcasualty1.rds")

codes <- read_delim("codelookup.txt", delim="^") 
saveRDS(codes, file="NFIRS-2015-codes.rds")

fd.list <- read_delim("fdheader.txt", delim="^") %>%
  mutate(FD_NAME=str_to_upper(FD_NAME),
         FD_NAME=str_trim(FD_NAME)) %>%
  select(STATE, FDID, FD_NAME)
saveRDS(fd.list, file="NFIRS-2015-fdlist.rds")
# analysis of calls by agency
basic.2015 <- readRDS("NFIRS-2015-basicincident1.rds")
codes <- readRDS("NFIRS-2015-codes.rds")
fd.list <- readRDS("NFIRS-2015-fdlist.rds")

incident.types <- codes %>%
  filter(fieldid=="INC_TYPE") %>% 
  filter(grepl("^\\d+$", code_value), !is.na(code_value)) %>%  
  select(INC_TYPE=code_value, INC_DESCRIPTION=code_descr) %>%
  mutate(INC_TYPE=as.numeric(INC_TYPE)) 

incident.type.by.agency <- basic.2015 %>%
  filter(EXP_NO==0) %>%
  count(STATE, FDID, INC_TYPE) %>%
  ungroup %>%
  left_join(incident.types, by="INC_TYPE") %>%
  left_join(select(fd.list, STATE, FDID, FD_NAME), by=c("STATE", "FDID"))

call.by.agency <- incident.type.by.agency %>%
  count(STATE, FDID, FD_NAME, wt=n) %>%
  ungroup 

incident.by.type <- incident.type.by.agency %>%
  count(INC_TYPE, INC_DESCRIPTION, wt=n) %>%
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

# fire vs. medical comparison
medical.types <- incident.types %>%
  filter(INC_TYPE %in% c(300, 311, 320, 321, 661))
fire.types <- incident.types %>% 
  filter(INC_TYPE %in% 
           c(100, 111:118, 120:123, 130:138, 140:143, 150:155, 160:164, 
                170:173, 400, 410:413, 420:424, 430:431, 440:445, 451, 
                460:463, 471, 480:482, 561, 631:632))
accident.types <- incident.types %>% 
  filter(INC_TYPE %in% c(322:324)) 

type.pct.by.agency <- incident.type.by.agency %>%
  mutate(type2 = case_when(INC_TYPE %in% fire.types$INC_TYPE ~ "fire",
                           INC_TYPE %in% medical.types$INC_TYPE ~ "medical", 
                           TRUE ~ "other")) %>%
  count(STATE, FDID, FD_NAME, type2, wt=n) %>%
  spread(type2, nn, fill=0) %>%
  mutate(total=fire + medical + other,
         fire.pct = fire / total,
         medical.pct = medical / total)


save(incident.type.by.agency, call.by.agency, incident.by.type, 
     fire.types, medical.types, accident.types, type.pct.by.agency,
     file="NFIRS-2015-BasicAnalysis.RData")  

load("NFIRS-2015-BasicAnalysis.RData")

# lack of reporting (months missing)
fd.total.months <- basic.2015 %>%
  mutate(month=month(INC_DATE)) %>%
  distinct(STATE, FDID, month) %>%
  count(STATE, FDID) %>%
  ungroup 
fd.missing.months <- fd.total.months %>%
  filter(n < 12) %>%
  left_join(select(fd.list, STATE, FDID, FD_NAME), by=c("STATE", "FDID"))

# Number of responding agencies by state
agencies.by.state <- call.by.agency %>%
  count(STATE) %>%
  left_join(count(fd.list, STATE), by="STATE", suffix=c(".reporting", ".total"))

aid.by.agency <-  basic.2015 %>% 
  filter(EXP_NO==0) %>%
  mutate(aid2 = case_when(AID %in% 3:5 ~ "given",
                          AID %in% 1:2 ~ "received",
                          TRUE ~ "none")) %>%
  count(STATE, FDID, aid2) %>% 
  spread(aid2, n, fill=0) %>%
  mutate(total = given + received + none) %>%
  left_join(select(fd.list, STATE, FDID, FD_NAME), by=c("STATE", "FDID"))
  

# some quick math about
count.limits <- c(5*12, 6*12, 100, 1000, 5*365, 6*365)
count.limits %>% sapply(function(x){sum(call.by.agency$nn > x)}) %>%
  as.tibble %>% 
  set_names("count") %>% 
  bind_cols(limits=count.limits, .) %>%
  mutate(probability.12 = round(12*exp(-limits / 12), 4),
         probability.365 = round(365*exp(-limits / 365), 4))
sum(call.by.agency$nn > 1000)

SingleProbability <- function(number.of.calls, time.periods){
  calls.per.period = number.of.calls / time.periods
  zero.prob = exp(-calls.per.period)
  total.zero.prob = 1 - (1-zero.prob)^time.periods 
  # approximated by (time.periods * zero.prob)
  return(total.zero.prob)
}
OverallProbability <- function(time.periods){
    temp.data <- call.by.agency %>%
      arrange(desc(nn)) %>%
      mutate(single.probability = SingleProbability(nn, time.periods),
           overall.probability = 1-cumprod(1-single.probability)) 
    return(temp.data$overall.probability)
    }

MonthProbability <- function(number.of.calls){
  months <- rep(c(28, 30, 31), times=c(1, 4, 7))
  Func1 <- function(calls){
    calls.per.month <- calls / 365 * months
    zero.prob = exp(-calls.per.month)
    total.zero.prob = 1 - prod(1-zero.prob)
    return(total.zero.prob)
  }
  # approximated by (time.periods * zero.prob)
  sapply(number.of.calls, Func1)
}

call.probabilities <- call.by.agency %>%
  select(nn) %>%
  arrange(desc(nn)) %>%
  mutate(overall.prob.12 = OverallProbability(12),
         overall.prob.365 = OverallProbability(365),
         better.prob.12 = MonthProbability(nn),
         overall.prob2.12 = 1-cumprod(1-better.prob.12)) %>%
  select(-better.prob.12)

