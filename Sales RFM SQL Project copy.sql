-- Inspecting the data
SELECT *
FROM sales_data_sample

--Checking for unique values
SELECT DISTINCT status FROM sales_data_sample --Nice one to plot
SELECT DISTINCT year_id FROM sales_data_sample
SELECT DISTINCT Product_line FROM sales_data_sample --Nice to plot
SELECT DISTINCT Country FROM sales_data_sample --Nice to plot
SELECT DISTINCT Deal_size FROM sales_data_sample --Nice to plot
SELECT DISTINCT Territory FROM sales_data_sample
SELECT DISTINCT Customer_name FROM sales_data_sample
SELECT DISTINCT City FROM sales_data_sample

-- Analysis

-- How much Sales did each Product line generated
SELECT
     Product_line,
     ROUND(SUM(Sales), 0) AS Total_Sales
FROM sales_data_sample
GROUP BY Product_line
ORDER BY 2 DESC

-- The Year with most Sales
SELECT
     Year_id,
     ROUND(SUM(Sales), 0) AS Total_Sales
FROM sales_data_sample
GROUP BY Year_id
ORDER BY 2 DESC

-- 2004 had the highest sales generated next to 2003

-- 2005 total Sales was low why? Maybe they didn't operate a full year or maybe something else let's confirm
SELECT
     DISTINCT Month_ID
FROM sales_data_sample
WHERE Year_ID = 2005 -- Change year here to compare

-- Unlike 2003 and 2004 that had a full year 2005 sales metrics was based on just January to May.
-- Just 5 months worth of data

-- Deal_size with most sales
SELECT
     Deal_size,
     ROUND(SUM(Sales), 0) AS Total_Sales
FROM sales_data_sample
GROUP BY Deal_size
ORDER BY 2 DESC

-- Medium size generated most sales followed by small size

-- Top 5 Countries that generated most Sales
SELECT
     TOP 5 Country,
     ROUND(SUM(Sales), 0) AS Total_Sales
FROM sales_data_sample
GROUP BY Country
ORDER BY 2 DESC


-- What was the best month for sales in a specific year? How much was earned that month?
SELECT
     Month_ID,
     ROUND(SUM(Sales), 0) AS Total_Sales,
     COUNT(Order_No) AS Frequency
FROM sales_data_sample
WHERE Year_ID = 2004 -- Change Year to view the rest
GROUP BY Month_ID
ORDER BY 2 DESC

-- November seems to be the month, what product do they sell in November, Classic I believe
SELECT
     Product_line,
     ROUND(SUM(Sales), 0) AS Total_Sales,
     COUNT(Order_No) AS Frequency
FROM sales_data_sample
WHERE Month_ID = 11 AND Year_ID = 2004 -- Change Year to view the rest
GROUP BY Product_line
ORDER BY 2 DESC

-- Classic cars sold most in both year 2003 and 2004

-- Who are our best customer (this could be best answered with RFM)
WITH CTE_SalesD AS (
SELECT *,
         rfm_recency + rfm_frequency + rfm_monetary AS rfm_Cell,
         CAST(rfm_recency AS VARCHAR) + CAST(rfm_frequency AS VARCHAR) + CAST(rfm_monetary  AS VARCHAR)rfm_cell_string
     FROM (
             SELECT *,
		         NTILE(5) OVER (order by DaysSinceLastOrder desc) rfm_recency,
		         NTILE(5) OVER (order by Frequency) rfm_frequency,
		         NTILE(5) OVER (order by MonetaryValue) rfm_monetary
             FROM (
                    SELECT
                         Customer_name,
                         MAX(Order_date) AS Last_order_date,
                         (SELECT MAX(Order_date) FROM sales_data_sample) AS Max_order_date,
	                 DATEDIFF(DD, MAX(Order_date), (SELECT MAX(Order_date) FROM sales_data_sample)) AS DaysSinceLastOrder,
                         COUNT(Order_No) AS Frequency,
	                 ROUND(SUM(Sales), 0) AS MonetaryValue
                    FROM sales_data_sample
                    GROUP BY Customer_name) AS T1) T2)

SELECT
      Customer_name,
      rfm_recency,
      rfm_frequency,
      rfm_monetary,
      CASE
          WHEN rfm_cell_string IN (555, 554, 544, 545, 553) THEN 'Big Ballers'
          WHEN rfm_cell_string IN (543, 533, 444, 443, 433, 434) THEN 'Ballers'
          WHEN rfm_cell_string IN (552, 323, 333,321, 422, 332, 432) THEN 'Active'
          WHEN rfm_cell_string IN (511, 441, 411, 311, 331) THEN 'Active'
          ELSE 'Not Relevant'
          END AS Customer_Segmentation
FROM CTE_SalesD


-- What city has the highest number of sales in a specific country?
SELECT
     City,
     ROUND(SUM(Sales), 0) AS Total_Sales
FROM sales_data_sample
WHERE Country = 'USA'
GROUP BY City
ORDER BY 2 DESC


-- Total Sales by Product status 
SELECT
     Status,
     ROUND(SUM(Sales), 0) AS Total_Sales
FROM sales_data_sample
GROUP BY Status
ORDER BY 2 DESC
