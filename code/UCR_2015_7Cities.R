ProjectDir("UCR") %>% setwd

ucr.col.types <- cols(.default=col_double(),
                      numeric.state.code=col_character(),
                      ori.code=col_character(),
                      agency.name=col_character(),
                      agency.state.name=col_character(),
                      mailing.address.line.2=col_character())
ucr <- read_csv("UCR_Crimes_Clearances_2005_to_2015.csv",
                col_types=ucr.col.types)

cities <- data_frame(city=c("boston", "atlanta", "longmont", "schenectady", 
                            "ithaca", "new orleans", "los angeles"),
                     state=c("mass", "ga", "colo", "n y", "n y", "la", "calif"))
ucr.small <- ucr %>%
  filter(year==2015) %>%
  mutate_at(matches("agency"), tolower) %>%
  inner_join(cities, by=c("agency.name"="city", "agency.state.name"="state")) %>%
  filter(!grepl("county", mailing.address.line.2))

save(ucr.small, file="UCR2015-BlogPost.RData")
