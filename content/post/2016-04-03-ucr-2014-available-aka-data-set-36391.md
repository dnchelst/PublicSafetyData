---
title: UCR 2014 Available (aka data set 36391)
author: Dov Chelst
date: '2016-04-03'
slug: ucr-2014-available-aka-data-set-36391
categories:
  - R
tags:
  - crime
  - police
---

It's common for citizens to be interested in local crime rates either 
personally or professionally. Most local law enforcement agencies report 
monthly crime statistics to city officials and/or residents as well as to a 
state agency. The state then aggregates the data and forwards it to the FBI as 
part of the 
[Uniform Crime Reporting](https://www.fbi.gov/about-us/cjis/ucr/ucr) (UCR) 
program. The FBI annually releases a report on crime. The most recent was 
called 
[Crime in the United States 2014](https://www.fbi.gov/about-us/cjis/ucr/crime-in-the-u.s/2014/crime-in-the-u.s.-2014) 
which was released on 
[September 28, 2015](https://www.fbi.gov/news/stories/2015/september/latest-crime-stats-released/latest-crime-stats-released). 

So, why talk about it now in April 2016? Well the FBI's site is incomplete; 
however, the FBI eventually forwards a comprehensive version of their data set 
to the 
[National Archive of Criminal Justice Data (NACJD)](http://www.icpsr.umich.edu/icpsrweb/NACJD/index.jsp). 
All the data for 2014 is available available as data set [36391](http://www.icpsr.umich.edu/icpsrweb/NACJD/studies/36391) 
provided in 
multiple formats for easy consumption. It's at a granular level, with over 100
variables recorded for each month of the year, and reported individually for 
over 22,000 agencies. It was published to the site at the beginning of March 
and I only noticed it a few weeks ago.

What makes the FBI's site incomplete? You can access information that shows 
crimes for an individual department. However, you can't see clearance 
information at that level. In other words, the number of crimes are available, 
but not how many of those were "solved." 
_All clearance information is available in this the newly published data set._ 

Here are a few more tidbits if you haven't lost interest yet:

- A 
[nice article on clearance rates](http://www.npr.org/2015/03/30/395799413/how-many-crimes-do-your-police-clear-now-you-can-find-out) 
was written by Martin Kaste for NPR last year. 
It also has a 
[nifty web app](http://apps.npr.org/dailygraphics/graphics/lookup-clearance-rates/child.html) 
embedded within it.  
- If you get a chance to compare the FBI website's crime statistics and the 
NACJD's data file, try looking for information on Glendale, Arizona.  
- California's Office of the Attorney General has a particularly nice website 
providing 
[crime data](https://oag.ca.gov/crime) 
to the general public. Try out their [tool](https://oag.ca.gov/crime/cjsc/stats/crimes-clearances) for extracting 
up to 10 years of crime and clearance data.  

Now, I thought I'd ask for input on a problem that I'm having calculating 
**crime rates at the county level**. Reported crimes are useful to know, but 
it's hard to compare between jurisdictions without first converting to crime 
"rates". Rates are determined by dividing a jurisdiction's crimes by its 
population and multiplying by 100,000. 

Crime rates are not actually reported by municipalities, 
but rather by law enforcement agencies. 
In most cities, there isn't much difference. 
However, _there is a big difference at the county level_. 
"County crimes" are just crimes reported by the county sheriff's office, 
ignoring all crimes handled by municipal police departments. 
To find the crime rate at the county level, you can't just take county crimes 
and divide by the county's total population. 
In fact, the FBI's data tool won't show crime rates if you select a county agency.
Nevertheless, how can I compare crimes in two neighboring counties? 

- Can anyone recommend an accurate way to report crime rates at a county level? 
- What about a way to report crime rates focusing on residents that live within 
the county's unincorporated areas? 
- I tend to do best when a problem is concrete. If that's how you work, 
[pick two neighboring counties in Wisconsin](https://en.wikipedia.org/wiki/List_of_counties_in_Wisconsin) 
as an example. 

I welcome your ideas as I don't have a good answer at the moment. I intentionally focused on the big picture. I'm aware that I've glossed over lots of details. Feel free to comment on the missing details.