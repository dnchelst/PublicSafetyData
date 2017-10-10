library(rmarkdown)
setwd("C:/Users/Dov/Documents/CPSM-Scripts/PublicSafetyData")
setwd("content/post")
render("NFIRS-2015-Improved.Rmarkdown")

setdiff(
  filter(fd.list, STATE=="NJ"),
  select(call.by.agency, -nn)
)

setdiff(
  select(call.by.agency, -nn),
  incident.type.by.agency %>% filter(INC_TYPE=="321") %>% 
    select(STATE, FDID, FD_NAME)
) %>% 
  left_join(call.by.agency) %>%
  filter(STATE=="MI") %>% 
  View

basic.2015 %>% 
  filter(FDID=="07100") %>% head