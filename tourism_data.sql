CREATE DATABASE tourism_data;

USE tourism_data;
select * from tourism;
-- creates 'tourism' table

CREATE TABLE tourism(
visitor_id VARCHAR(12),
district VARCHAR(55),
month_number TINYINT UNSIGNED,
`month` VARCHAR(9),
`year` YEAR,
domestic_visitors BIGINT,
foreign_visitors BIGINT,
total_visitors BIGINT,
PRIMARY KEY(visitor_id)
);

-- loads data into 'tourism' table

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/cleaned_tourism_data.csv' 
INTO TABLE tourism
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES;

SELECT * FROM tourism;

-- ============================================== DATA ANALYSIS ==============================================

-- Q1. Find the top 5 districts with the highest total number of visitors in the year 2022.

-- top 5 districts, highest number of visitors, year 2022

SELECT district, SUM(total_visitors) AS total_visitors
FROM tourism
WHERE year = 2022
GROUP BY district
ORDER BY total_visitors DESC
LIMIT 5;

-- Q2. Find the average of total visitors for each district in 2023.

-- avg of total visitors, for each district, year 2023

SELECT district, ROUND(AVG(total_visitors),2) AS avg_visitors
FROM tourism
WHERE year = 2023
GROUP BY district;

-- Q3. Find the month with the highest number of visitors for each district in 2023.

SELECT district, `month`, MAX(total_visitors) AS max_visitors
FROM tourism
WHERE `year` = 2023
GROUP BY district, `month`;

-- Q4. Calculate the percentage of foreign visitors compared to domestic visitors for each district in 2021.

-- percentage of foreign to domestic visitors, for each district, year 2021

SELECT district,
(SUM(foreign_visitors) / (SUM(domestic_visitors) + SUM(foreign_visitors))) * 100 AS foreign_visitor_percentage
FROM tourism
WHERE `year` = 2021
GROUP BY district;

-- Q5. Calculate the percentage of domestic visitors compared to foreign visitors for each district in 2021.

SELECT district,
(SUM(domestic_visitors) / (SUM(domestic_visitors) + SUM(foreign_visitors))) * 100 AS domestic_visitor_percentage
FROM tourism
WHERE `year` = 2021
GROUP BY district;

-- Q6. Find the districts that showed a significant increase in total visitors from 2022 to 2023.

SELECT district,
(SUM(CASE WHEN year = 2023 THEN total_visitors END) - SUM(CASE WHEN year = 2022 THEN total_visitors END)) / 
SUM(CASE WHEN year = 2022 THEN total_visitors END) * 100 AS growth_percentage
FROM tourism
WHERE `year` IN (2022, 2023)
GROUP BY district
HAVING growth_percentage > 10;

-- Q7. calculate the year-over-year growth rate for each district.

SELECT district,
(SUM(CASE WHEN year = 2023 THEN total_visitors END) - SUM(CASE WHEN year = 2022 THEN total_visitors END)) /
SUM(CASE WHEN year = 2022 THEN total_visitors END) * 100 AS growth_percentage
FROM tourism
WHERE `year` IN (2022, 2023)
GROUP BY district;

 -- Q8. Find districts with high growth potential.

-- year over year growth rate for each district, rank districts based on their growth rate

SELECT district, yoy_growth, RANK() OVER (ORDER BY yoy_growth DESC) AS growth_rank 
FROM (
    SELECT t1.district, (t1.total_visitors - t2.total_visitors) / t2.total_visitors AS yoy_growth
    FROM tourism t1
    JOIN tourism t2 
    ON t1.district = t2.district AND t1.year = t2.year + 1
    WHERE t1.year = 2023 
) AS visitor_count;

-- Q9. Find the seasonality of tourism within each district.

SELECT district, `month`, total_visitors, 
AVG(total_visitors) OVER (PARTITION BY district) AS avg_monthly_visitors, 
(total_visitors - AVG(total_visitors) OVER (PARTITION BY district)) AS deviation 
FROM tourism;

-- Q10. Find districts where the total visitors have consistently increased year over year. 

SELECT t1.district, t1.`year`, (t1.total_visitors - t2.total_visitors) / t2.total_visitors AS yoy_growth
FROM tourism t1
JOIN tourism t2 
ON t1.district = t2.district AND t1.`year` = t2.`year` + 1
WHERE t1.`year` IN (2014, 2015, 2016, 2017, 2018, 2019, 2020, 2021, 2022, 2023)
ORDER BY t1.district, t1.`year`;


