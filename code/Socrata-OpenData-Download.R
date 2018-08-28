library("RSocrata")
new.orleans <- 
    read.socrata("https://data.nola.gov/resource/ahnh-7f2h.csv")
new.orleans.district1 <- 
    read.socrata("https://data.nola.gov/resource/ahnh-7f2h.csv?PoliceDistrict=1")
download.file("https://data.nola.gov/api/views/wgrp-d3ma/rows.csv?accessType=DOWNLOAD", 
              "new_orleans.csv", method="curl")
los.angeles <- read.socrata("https://data.lacity.org/resource/7fvc-faax.csv")
