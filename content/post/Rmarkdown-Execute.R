library(rmarkdown)
library(tidyverse)
git.directories <- c("C:/Users/Dov/Documents/CPSM-Scripts",
                 "/home/dchelst/git")
post.directory <- ifelse(file.exists(git.directories[1]), git.directories[1],
                         git.directories[2]) %>%
  file.path("PublicSafetyData/content/post")
setwd(post.directory)
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