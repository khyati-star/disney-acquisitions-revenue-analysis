-- Create the Database --
DROP DATABASE IF EXISTS disney_analysis;
CREATE DATABASE disney_analysis;
USE disney_analysis;
-- Create Tables--
-- Acquisitions Table --
CREATE TABLE acquisitions (
    id INT PRIMARY KEY AUTO_INCREMENT,
    company_acquired VARCHAR(255),
    date DATE,
    country VARCHAR(255),
    price DECIMAL(15, 2),
    price_adjusted DECIMAL(15, 2),
    parent_merged_with VARCHAR(255),
    reference  VARCHAR(255)
);
-- Revenue Table
CREATE TABLE revenue (
    year INT PRIMARY KEY,
    revenue DECIMAL(15, 2)
);
-- Step 3: Insert Sample Data
-- Insert Acquisitions Data
INSERT INTO acquisitions (company_acquired, date, country, price, price_adjusted, parent_merged_with, reference)
VALUES
('Disneyland, Inc. (64% controlling stake)', '1957-01-01', 'USA', 562500, 6000000, 'Disney Parks, Experiences and Products', '[1]'),
('Disneyland, Inc. (remaining shares)', '1960-01-01', 'USA', 7500000, 80000000, NULL, '[2],[3]'),
('Capital Cities/ABC Inc.', '1996-02-09', 'USA', 19000000000, 38093000000, 'Disney General Entertainment Content', '[7]'),
('Pixar', '2006-05-05', 'USA', 7400000000, 11542000000, 'Walt Disney Studios', '[16]'),
('Marvel Entertainment', '2009-12-31', 'USA', 4400000000, 6449000000, 'The Walt Disney Company', '[22]'),
('Lucasfilm', '2012-12-21', 'USA', 4050000000, 5547000000, 'Walt Disney Studios', '[27],[28]'),
('21st Century Fox', '2019-03-20', 'USA', 71300000000, 87689000000, 'The Walt Disney Company', '[36],[37]');

-- Insert Revenue Data (in millions USD)
INSERT INTO revenue (year, revenue)
VALUES
(2009, 36149),
(2010, 38063),
(2011, 40893),
(2012, 42278),
(2013, 45041),
(2014, 48813),
(2015, 52465),
(2016, 55632),
(2017, 55137),
(2018, 59434),
(2019, 69607),
(2020, 65388),
(2021, 67418),
(2022, 82722),
(2023, 88898),
(2024, 91361);

-- Step 4: Data Validation
-- Check for duplicate years in revenue
SELECT year, COUNT(*) AS count
FROM revenue
GROUP BY year
HAVING COUNT(*) > 1;

-- Check for missing data in acquisitions
SELECT *
FROM acquisitions
WHERE date IS NULL OR price IS NULL;

-- Query 1: List all acquisitions after 2000
SELECT * FROM acquisitions WHERE date > '2000-01-01' ORDER BY date;

-- Query 2: Count acquisitions per year
SELECT YEAR(date) AS year, COUNT(*) AS num_acquisitions
FROM acquisitions
GROUP BY YEAR(date)
ORDER BY year;

-- Query 3: Revenue trend with year-over-year growth rate
SELECT year, revenue,
       (revenue - LAG(revenue) OVER (ORDER BY year)) / LAG(revenue) OVER (ORDER BY year) AS growth_rate
FROM revenue
ORDER BY year;

-- Query 4: Total revenue before and after 21st Century Fox acquisition (2019)
SELECT SUM(revenue) AS total_revenue_before
FROM revenue
WHERE year < 2019;

SELECT SUM(revenue) AS total_revenue_after
FROM revenue
WHERE year >= 2019;

-- Query 5: Revenue for major acquisitions (price_adjusted > $1 billion)
SELECT company_acquired, date, price_adjusted
FROM acquisitions
WHERE price_adjusted > 1000000000
ORDER BY date;

-- Query 6: Revenue in the year of and year after major acquisitions (example for 21st Century Fox)
SELECT r.year, r.revenue
FROM revenue r
WHERE r.year IN (2019, 2020);

-- Query 7: Cumulative acquisitions vs. revenue
WITH cumulative_acquisitions AS (
    SELECT YEAR(date) AS year, COUNT(*) AS num_acquisitions
    FROM acquisitions
    GROUP BY YEAR(date)
),
cumulative_revenue AS (
    SELECT year, revenue,
           SUM(revenue) OVER (ORDER BY year) AS cumulative_revenue
    FROM revenue
)
SELECT ca.year, ca.num_acquisitions, cr.cumulative_revenue
FROM cumulative_acquisitions ca
LEFT JOIN cumulative_revenue cr ON ca.year = cr.year
ORDER BY ca.year;
