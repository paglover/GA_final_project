library(ggplot2)
library(sqldf)

# import data from crunchbase into R dataframes
acquisitions <- read.csv("~/Downloads/crunchbase/acquisitions.csv", header = TRUE)
companies <- read.csv("~/Downloads/crunchbase/companies.csv", header = TRUE)
investments <- read.csv("~/Downloads/crunchbase/investments.csv", header = TRUE)
rounds <- read.csv("~/Downloads/crunchbase/rounds.csv", header = TRUE)

# test to make sure dataframe was imported and check format
head(acquisitions,10)
head(companies,10)
head(investments,10)
head(rounds,10)

# create smaller files head() of each data frame
acquisitions_head <- head(acquisitions,500)
companies_head <- head(companies, 500)
investments_head <- head(investments, 500)
rounds_head <- head(investments,500)

## COMPANIES
# understand basic breakdown of companies
summary(companies)
head(companies)
nrow(companies) #55240
length(unique(unlist(companies$name))) #32585
unique(unlist(companies$category_code)) #43 unique category codes
length(unique(unlist(companies$country_code))) #118 countries represented
unique(companies$funding_rounds) #up to 15 different funding rounds
unique(companies$founded_quarter) #181 quarters represented
length(unique(unlist(companies$region))) #2529
length(unique(unlist(companies$city))) #4659

# ggplot explanatory plots of companies
ggplot(companies, aes(founded_quarter)) + geom_histogram() # fairly distributed
ggplot(companies, aes(category_code)) + geom_histogram() # most are advertising, otherwise fairly varied

# basic funding stats to see what is interesting for further analysis
ggplot(companies_head, aes(funding_total_usd)) + geom_histogram()

# query to find the top company category_codes
sql_category <- sqldf("SELECT category_code, count(category_code) from companies GROUP BY category_code ORDER BY count(category_code) DESC")
# top 10 categories are software, biotech, web, mobile, ecommerce, enterprise, games_video, advertising, hardware, cleantech
sql_category_top10 <- sqldf("SELECT category_code, count(category_code) AS count from companies WHERE category_code IN ('software', 'biotech', 'web', 'mobile', 'ecommerce', 'enterprise', 'games_video', 'advertising', 'hardware', 'cleantech') GROUP BY category_code ORDER BY count(category_code) DESC")
ggplot(sql_category_top10, aes(category_code, count)) + geom_bar()

# query to find the cities with the most startups
sql_city <- sqldf("SELECT city, count(city) AS count from companies GROUP BY city ORDER BY count(city) ASC")
sql_city_top10 <- sqldf("SELECT city, count(city) AS count from companies WHERE city IN ('San Francisco', 'New York', 'London', 'Palo Alto', 'Cambridge', 'Seattle', 'Austin', 'Mountain View', 'San Diego', 'Boston') GROUP BY city ORDER BY count(city) DESC")
ggplot(sql_city_top10, aes(city, count)) + geom_bar()

# Dataset is very large that is is difficult to see trends or find a more focused area of interest.
# Need to minimize dataset size. Couple approaches:
# 1: create a sample with head()
companies_sample <- head(companies, 500)
ggplot(companies_head, aes(category_code)) + geom_histogram() # no longer skewed towards advertising. 

# create sample of 1000
companies_sample <- companies[sample(nrow(companies),1000), ]


## INVESTMENTS
summary(investments)
nrow(investments) #81,234
unique(unlist(investments$funding_round_type)) #8 levels

## ACQUISITIONS
summary(acquisitions)
ggplot(acquisitions_head, aes(company_category_code, price_amount)) + geom_point()

## ROUNDS
summary(rounds)

# sql query for funding per quarter
sql_rounds_fundedyear_fundinground <- sqldf("SELECT funded_year, funding_round_type, count(funding_round_type) AS count, company_city FROM rounds WHERE funded_year IN ('2008', '2009', '2010', '2011', '2012', '2013') GROUP BY funded_year, funding_round_type")

# ggplot + facet_wrap
ggplot(sql_rounds_fundedyear_fundinground, aes(funding_round_type,count)) + geom_point()
ggplot(sql_rounds_fundedyear_fundinground, aes(funding_round_type,count)) + geom_bar() + facet_wrap(~funded_year)

# amounts raised per year
sql_rounds_fundingperyear <- sqldf("SELECT funded_year, SUM(raised_amount_usd) AS total_raised FROM rounds WHERE funded_year IN ('2008', '2009', '2010', '2011', '2012', '2013') GROUP BY funded_year")


## Ideas for potential hypothesis for final project
# 1)

## Notes for further exploration:
# 1) create a smaller, more representative sample of my data
# create ggplot data with only top 5-10 most popular fields (i.e., top 5 company_category_code or top 5 countries only)
# compare summary-level counts on ggplot
# sample per factor
# sort by TOP 5 in pandas
# try density plot or stat_smooth
# plot changes over time
# need to remove all empty/blankrows (see when pulling random sample)
# need to convert funding_total_usd to a numeric value
