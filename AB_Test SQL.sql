drop table ab_test;
CREATE TABLE ab_data (
    index        INTEGER,
    user_id      BIGINT,
    test_group   VARCHAR(10),
    converted    BOOLEAN,
    total_ads    INTEGER,
    most_ads_day VARCHAR(10),
    most_ads_hour INTEGER
);


copy ab_data
FROM 'C:\Users\aditya\Desktop\AB Testing\marketing_AB.csv\marketing_AB.csv'
WITH (FORMAT csv, HEADER, DELIMITER ',', ENCODING 'UTF8');


select * from ab_data;

--how many rows are there?

select count(*) as total_rows
from ab_data;

--how are the split between the two groups?

select test_group,
count(*) as users,
round(count(*) * 100.0 / sum(count(*)) over(), 2) as pct_of_total
from ab_data
group by test_group;

--96% ad, 4% psa

--calculate conversion rates

SELECT 
    test_group,
    COUNT(*) AS total_users,
    SUM(CASE WHEN converted = TRUE THEN 1 ELSE 0 END) AS converted_users,
    ROUND(
        SUM(CASE WHEN converted = TRUE THEN 1 ELSE 0 END) * 100.0 / COUNT(*),
        2
    ) AS conversion_rate_pct
FROM ab_data
GROUP BY test_group;

-- ad = 2.55% conversion while psa = 1.79% conversion

--looking at the ad expense

select 
test_group,
round(avg(total_ads),1) as avg_ads_seen,
min(total_ads) as min_ads,
max(total_ads) as max_ads,
percentile_cont(0.5) within group (order by total_ads) as median_ads
from ab_data
group by test_group;

-- both groups avg 24.8 ads seen with median 13

--need to look at conversion rate by ad volume

SELECT 
    CASE 
        WHEN total_ads BETWEEN 1 AND 10 THEN '1-10 ads'
        WHEN total_ads BETWEEN 11 AND 50 THEN '11-50 ads'
        WHEN total_ads BETWEEN 51 AND 100 THEN '51-100 ads'
        ELSE '100+ ads'
    END AS ads_bucket,
    COUNT(*) AS users,
    ROUND(
        SUM(CASE WHEN converted = TRUE THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 
        2
    ) AS conversion_rate_pct
FROM ab_data
WHERE test_group = 'ad'
GROUP BY ads_bucket
ORDER BY ads_bucket;

-- find the best day and hour to show ads

SELECT 
    most_ads_day,
    COUNT(*) AS users,
    SUM(CASE WHEN converted = TRUE THEN 1 ELSE 0 END) AS conversions,
    ROUND(
        SUM(CASE WHEN converted = TRUE THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 
        2
    ) AS conversion_rate_pct
FROM ab_data
WHERE test_group = 'ad'
GROUP BY most_ads_day
ORDER BY conversion_rate_pct DESC;

-- Which hour of the day drives the most conversions?

SELECT 
    most_ads_hour,
    COUNT(*) AS users,
    ROUND(
        SUM(CASE WHEN converted = TRUE THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 
        2
    ) AS conversion_rate_pct
FROM ab_data
WHERE test_group = 'ad'
GROUP BY most_ads_hour
ORDER BY conversion_rate_pct DESC
LIMIT 5;

-- the data says, monday is the strongest with 3.32%,
-- while sunday is the weakest with 2.13%
-- the spread accross the weak is 1.19%
-- the best hour is 16:00(3.09%) and 20:00(3.03%)

-- summarizing the findings

SELECT 
    test_group,
    COUNT(*) AS total_users,
    SUM(CASE WHEN converted = TRUE THEN 1 ELSE 0 END) AS conversions,
    ROUND(
        SUM(CASE WHEN converted = TRUE THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 
        2
    ) AS conversion_rate_pct,
    ROUND(AVG(total_ads), 1) AS avg_ads_seen
FROM ab_data
GROUP BY test_group;

-- the ad campaign drove a 43% relative lift in conversion rate compared to the control group
-- conversion rate increases steadily with ad frequency, reaching 17% for users who saw 100 or more ads
-- monday and mid-to-late afternoon and early evenings are the highest-converting windows









