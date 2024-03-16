-- Creating the Walmart Database
CREATE DATABASE Walmart;


-- Setting default Database
USE Walmart;


-- creatng the table to upload the data from csv file
CREATE TABLE Walmart (
    InvoiceID VARCHAR (20) NOT NULL PRIMARY KEY,
    Branch VARCHAR (2) NOT NULL,
    City VARCHAR (30) NOT NULL,
    Customer_type VARCHAR (20) NOT NULL,
    Gender VARCHAR (10) NOT NULL,
    Product_line VARCHAR (30) NOT NULL,
    Unit_price DECIMAL (7,2) NOT NULL,
    Quantity INT,
    Tax_5_Percent DECIMAL (6,4) NOT NULL,
    Total DECIMAL (15,4) NOT NULL,
    Date DATE NOT NULL,
    Time TIME NOT NULL,
    Payment VARCHAR (15) NOT NULL,
    cogs DECIMAL (10,2) NOT NULL,
    gross_margin_percentage DECIMAL (20,10),
    gross_income DECIMAL (12,4),
    Rating DECIMAL (5,2));

-- Removing the strict sql mode for the session before importing the data to enable mysql to import black spaces in decimal data
SET SESSION sql_mode = '';


-- Loading the database into the Walmart table
LOAD DATA INFILE 'D:/Data Science/MySQL/Walmart Project/WalmartSalesData.csv'
INTO TABLE Walmart
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES;

-- DATA CLEANING
-- Checking the first 5 rows
SELECT * 
FROM walmart
LIMIT 5;

-- checking missing values in gross_margin_percentage, gross_income, and Rating variables since we are sure the other variables do not have missing values.
SELECT * 
FROM Walmart
WHERE gross_margin_percentage = "" OR gross_income = "" OR Rating = 0;


-- CREATING NEW VARIABLE(S)
-- Creating a Month variable
-- using ALTER to create a varible with NULL values
ALTER TABLE Walmart
ADD Month VARCHAR (15);

-- populating the Month variable
UPDATE Walmart
SET Month = MONTHNAME(Date);

-- DATA ANALYSIS
-- PRODUCT


-- i) How many unique product lines does the data have?
SELECT DISTINCT Product_line 
FROM Walmart;

-- ii) What is the most common payment method?
SELECT Payment, COUNT(InvoiceID) AS NoOfPayments
FROM Walmart
GROUP BY Payment
ORDER BY NoOfPayments DESC;

-- iii) What is the most selling product line?
SELECT Product_line, SUM(Quantity) AS TotalQuantity
FROM Walmart
GROUP BY Product_line
ORDER BY TotalQuantity DESC;

-- iv) What is the total revenue by month?
SELECT Month, ROUND(SUM(Total),2) AS TotalMonth
FROM Walmart
GROUP BY Month
ORDER BY TotalMonth DESC;

-- v) What month had the largest COGS?
SELECT Month, SUM(COGS) AS TotalCOGS
FROM Walmart
GROUP BY Month
ORDER BY TotalCOGS DESC;

-- vi) What product line had the largest revenue?
SELECT Product_line, ROUND(SUM(total),2) AS TotalRevenue
FROM Walmart
GROUP BY Product_line
ORDER BY TotalRevenue DESC;

-- vii) What is the city with the largest revenue?
SELECT City, ROUND(SUM(Total),2) AS TotalRevenue
FROM Walmart
GROUP BY City
ORDER BY TotalRevenue DESC;

-- viii) What product line had the largest VAT?
SELECT Product_line, AVG(Tax_5_Percent) AS AVG_VAT
FROM Walmart
GROUP BY Product_line
ORDER BY AVG_VAT DESC;

-- ix) Fetch each product line and add a column to those product lines showing "Good," and "Bad." Good if it is greater than average sales.
SELECT Product_line,  
CASE 
WHEN AVG(Quantity) >= (SELECT AVG(Quantity) FROM Walmart) THEN "Good" ELSE
"bad" END AS Performance
FROM Walmart
GROUP BY Product_line;


-- x) Which branch sold more products than average product sold?
SELECT Branch, BranchQuantity
FROM (SELECT Branch, SUM(Quantity) AS BranchQuantity
FROM Walmart
GROUP BY Branch) B
WHERE BranchQuantity > (SELECT AVG(BranchQuantity)
FROM (SELECT branch, SUM(Quantity) AS BranchQuantity
FROM Walmart
GROUP BY Branch) B)
GROUP BY Branch;

-- xi) What is the most common product line by gender?
SELECT Gender, Product_line, COUNT(InvoiceID) AS No_of_invoices
FROM Walmart
GROUP BY Gender, Product_line
ORDER BY No_of_invoices DESC;


-- xii) What is the average rating of each product line?
SELECT Product_line, ROUND(AVG(Rating), 2) AS AverageRating
	FROM Walmart
	GROUP BY Product_line
	ORDER BY AverageRating DESC;
    
    
    

-- SALES

-- i) Number of sales made in each time of the day per weekday
SELECT DAYNAME(Date) as WeekDay, 
CASE 
WHEN Time < "12:00:00" THEN "Morning"
WHEN Time < "17:00:00" THEN "Afternoon"
ELSE "Evening" END AS TimeOfTheDay, SUM(Quantity) AS QuantityOfSales
FROM Walmart
GROUP BY  WeekDay, TimeOfTheDay
ORDER BY WeekDay,QuantityOfSales DESC;


-- ii) Which of the customer types brings the most revenue?

SELECT Customer_type, ROUND(SUM(Total), 2) AS Revenue
FROM Walmart
GROUP BY Customer_type
ORDER BY Revenue DESC;

-- iii) Which city has the largest tax percentage/ VAT (Value Added Tax)?
SELECT City, ROUND(AVG(Tax_5_Percent),3) AS AverageTax
FROM Walmart
GROUP BY City
ORDER BY AverageTax DESC;

-- iv) Which customer type pays the most in VAT?
SELECT Customer_type, ROUND(AVG(Tax_5_Percent),3) AS AverageTax
FROM Walmart
GROUP BY Customer_type
ORDER BY AverageTax DESC;



-- CUSTOMERS


-- i) How many unique customer types does the data have?
SELECT DISTINCT Customer_type
FROM Walmart;

-- ii) How many unique payment methods does the data have?
SELECT DISTINCT Payment
FROM Walmart;

-- iii) What is the most common customer type?
SELECT Customer_type, COUNT(InvoiceID) AS NumberOfCustomers
FROM Walmart
GROUP BY Customer_type
ORDER BY NumberOfCustomers DESC;

-- iv) What is the gender of most of the customers?
SELECT Gender, COUNT(InvoiceID) AS NumberOfCustomers
FROM Walmart
GROUP BY Gender
ORDER BY  NumberOfCustomers DESC;

-- v) What is the gender distribution per branch?
SELECT Branch, Gender, COUNT(InvoiceID) AS NoOfCustomers
FROM Walmart
GROUP BY Branch, Gender
ORDER BY Branch, NoOfCustomers DESC;

-- vi) Which time of the day do customers give the most Ratings?
SELECT 
CASE 
WHEN Time < "12:00:00" THEN "Morning"
WHEN Time < "17:00:00" THEN "Afternoon"
ELSE "Evening" END AS TimeOfTheDay, AVG(Rating) AS AverageRating
FROM Walmart
GROUP BY  TimeOfTheDay
ORDER BY AverageRating DESC;

-- vii) At what time of the day do customers give the most ratings per branch?
SELECT Branch,
CASE 
WHEN Time < "12:00:00" THEN "Morning"
WHEN Time < "17:00:00" THEN "Afternoon"
ELSE "Evening" END AS TimeOfTheDay, AVG(Rating) AS AverageRating
FROM Walmart
GROUP BY  Branch, TimeOfTheDay
ORDER BY Branch, AverageRating DESC;


-- viii) Which day of the week has the best average ratings?
SELECT DAYNAME(Date) AS DayOfWeek, AVG(Rating) AS AverageRating
FROM Walmart
GROUP BY DayOfWeek
ORDER BY AverageRating DESC;

-- xi) Which day of the week has the best average ratings per branch?
SELECT Branch, DAYNAME(Date) AS DayOfWeek, AVG(Rating) AS AverageRating
FROM Walmart
GROUP BY Branch, DayOfWeek
ORDER BY Branch, AverageRating DESC;
















