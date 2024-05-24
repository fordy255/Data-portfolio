SELECT *
FROM PortfolioDatabase.dbo.SalaryData
ORDER BY Earnings DESC;

-- Cleaning data

-- Finding null Earnings

SELECT COUNT(School) AS 'Total Null Entries', Earnings
FROM PortfolioDatabase.dbo.SalaryData
WHERE Earnings IS NULL
GROUP BY Earnings;
-- 9675 Null entries with employment

-- Remove the null entries

DELETE
FROM PortfolioDatabase.dbo.SalaryData
WHERE Earnings IS NULL;

-- Split up names into first and last names

-- Select first and last names as test
SELECT
    LEFT(Name, CHARINDEX(' ', Name) - 1) AS 'First Name',
    RIGHT(Name, LEN(Name) - CHARINDEX(' ', Name)) AS 'Last Names'
FROM PortfolioDatabase.dbo.SalaryData
ORDER BY 'First Name';

-- Insert first names into table as separate column

ALTER TABLE PortfolioDatabase.dbo.SalaryData
ADD FirstName VARCHAR(201);

UPDATE PortfolioDatabase.dbo.SalaryData
SET FirstName = LEFT(Name, CHARINDEX(' ', Name) - 1);

-- Insert last names into table as separate column

ALTER TABLE PortfolioDatabase.dbo.SalaryData
ADD LastName VARCHAR(201);

UPDATE PortfolioDatabase.dbo.SalaryData
SET LastName = RIGHT(Name, LEN(Name) - CHARINDEX(' ', Name));

SELECT *
FROM PortfolioDatabase.dbo.SalaryData;

-- Investigation*******************

-- Which school has the highest average earnings?

SELECT School, AVG(Earnings) AS 'Average Earnings'
FROM PortfolioDatabase.dbo.SalaryData
GROUP BY School
ORDER BY 'Average Earnings' DESC;
-- University Of Cincinnati has the highest earnings 

-- By what factor does the University Of Cincinnati have the highest earnings compared to the average?

SELECT AVG(Earnings) AS 'Average Earnings'
FROM PortfolioDatabase.dbo.SalaryData;
-- Gives average earnings across all schools as 54659.1259447156

SELECT School, (AVG(Earnings) / 54659.1259447156) AS 'Average Earnings'
FROM PortfolioDatabase.dbo.SalaryData
GROUP BY School
ORDER BY 'Average Earnings' DESC;
-- Shows how all schools compare to the average earnings
-- University Of Cincinnati and Ohio State University are significantly above the average by 15.65 and 12.18 percent. This might suggest they have significantly more entries than other schools

-- Figure out the amount of entries per school
SELECT School, COUNT(*) AS SchoolEntries
FROM PortfolioDatabase.dbo.SalaryData
GROUP BY School
ORDER BY SchoolEntries DESC;
-- Ohio State has 423k entries and the next most popular has 80k. So Ohio State alone was bringing up the average

-- Which department has the highest average earnings?
SELECT Department, AVG(Earnings) AS AverageEarnings
FROM PortfolioDatabase.dbo.SalaryData
GROUP BY Department
ORDER BY AverageEarnings DESC;

-- Which department has the most entries

SELECT Department, COUNT(*) AS DepartmentEntries
FROM PortfolioDatabase.dbo.SalaryData
GROUP BY Department
ORDER BY DepartmentEntries DESC;

-- Find the department with the highest average earnings with a cross-reference to the number of entries

SELECT s1.Department, s1.AverageEarnings, s2.DepartmentEntries
FROM (
    SELECT Department, AVG(Earnings) AS AverageEarnings
    FROM PortfolioDatabase.dbo.SalaryData
    GROUP BY Department
) AS s1
INNER JOIN (
    SELECT Department, COUNT(*) AS DepartmentEntries
    FROM PortfolioDatabase.dbo.SalaryData
    GROUP BY Department
) AS s2 ON s1.Department = s2.Department
WHERE s2.DepartmentEntries >= 6
ORDER BY s1.AverageEarnings DESC;
-- Omitting departments with less than 6 entries to prevent outliers due to small sample sizes, just for personal clarity
-- FGP surgery has the highest average earnings by a considerable amount

-- How much does the year factor into the average earnings?

SELECT Year, ROUND(AVG(Earnings), 1) AS AverageEarnings
FROM PortfolioDatabase.dbo.SalaryData
GROUP BY Year
ORDER BY AverageEarnings DESC;
-- Shapiro-Wilk p-value: 0.77128407 indicates the data is normally distributed
-- Pearson R-value of 0.9717, which indicates a very strong positive mathematical correlation 
-- Direct correlation between the year and the average earnings. The later the year, the more money is being earned. 
-- This could be due to inflation, meaning the later you graduate, the less money is worth and the more you will be paid for the same job
-- or that every year jobs are paying more, so you should always be looking for a new job

-- Does the length of your first name affect your earnings?

SELECT LEN(FirstName) AS NameLen, AVG(Earnings) AS AverageEarnings
FROM PortfolioDatabase.dbo.SalaryData
GROUP BY LEN(FirstName)
ORDER BY AverageEarnings DESC;
-- The value of R is 0.3858.
-- Pearson r-value of 0.3858
-- Although technically a positive correlation, the relationship between your variables is weak and insignificant
-- No apparent correlation

-- Does the length of your last name affect your earnings?

SELECT LEN(LastName) AS NameLen, AVG(Earnings) AS AverageEarnings
FROM PortfolioDatabase.dbo.SalaryData
GROUP BY LEN(LastName)
ORDER BY AverageEarnings DESC;
-- This data has an R-value of -0.6627 in the Pearson Correlation Coefficient
-- This means the data has a relatively strong negative correlation, so the longer the name, the more likely you are to have lower average income
-- However, this could be due to cultures with shorter names having higher GDPs or better cultural job availability, rather than just the name being a factor





--How to optimise your earnings?
-- work in the health sciences or surgery department. change jobs as often as you can as found by the year study. go to University of Cincinnati or Ohio State University. have a short last name, although you could argue it to be from a culture that promotes career success