-- Basic Range Scope Check

SELECT 
	MIN(date) AS Earliest,
	MAX(date) AS Latest
FROM layoffs_stagging

SELECT 
	MAX(total_laid_off) AS Max_laid_off,
	MAX(percentage_laid_off) AS Max_Perc_laid_off
FROM layoffs_stagging

--Earliest is 11-03-2020 And Latest is 03-09-2026
--Max Laid off is 22000 and Max Percentage Laid off 100%

--Companies that laid off 100% of staff (went under)

SELECT 
	company, total_laid_off, percentage_laid_off, funds_raised
FROM layoffs_stagging
WHERE 
	percentage_laid_off = 1
ORDER BY
	funds_raised DESC

--Biggest single layoff events

SELECT TOP 10
	company, total_laid_off, date
FROM layoffs_stagging
ORDER BY 
	total_laid_off DESC

--Total layoffs by company

SELECT TOP 10
	company, SUM(total_laid_off) AS Total_laid_Off, date
FROM layoffs_stagging
GROUP BY 
	company, date
ORDER BY 
	Total_laid_Off DESC

--By industry / country / stage

SELECT TOP 10
	industry, date, SUM(total_laid_off) AS Total_Laid_off
FROM layoffs_stagging
GROUP BY
	industry, date
ORDER BY
	Total_Laid_off DESC;

SELECT TOP 10
	country, date, SUM(total_laid_off) AS Total_Laid_off
FROM layoffs_stagging
GROUP BY
	country, date
ORDER BY
	Total_Laid_off DESC;

SELECT TOP 10
	stage, date, SUM(total_laid_off) AS Total_Laid_off
FROM layoffs_stagging
GROUP BY
	stage, date
ORDER BY
	Total_Laid_off DESC

--Layoffs by year

SELECT 
	YEAR(date) AS Year,
	SUM(total_laid_off) AS Total_laid_off
FROM layoffs_stagging
GROUP BY
	YEAR(date)
ORDER BY
	Total_laid_off

--Rolling monthly total

WITH Monthly_Runn_Total AS(
SELECT 
	MONTH(date) AS Month,
	SUM(total_laid_off) AS Total_laid_off
FROM layoffs_stagging
WHERE date IS NOT NULL
GROUP BY 
	MONTH(date)
)
SELECT 
	Month, 
	Total_laid_off,
	SUM(Total_laid_off) OVER (ORDER BY Month) AS Running_Total
FROM Monthly_Runn_Total
ORDER BY 
	Month

--Top 3 company per year

WITH Company_Year AS (
SELECT 
	company, YEAR(date) AS Year,
	SUM(total_laid_off) AS Total_laid_off
FROM layoffs_stagging
GROUP BY
	company, YEAR(date)
),
Ranked AS (
SELECT *,
	DENSE_RANK() OVER (PARTITION BY Year ORDER BY Total_laid_off) AS DRN
FROM Company_Year
)
SELECT *
FROM Ranked
WHERE 
	DRN <=3 AND Total_laid_off IS NOT NULL
ORDER BY Year, Total_laid_off DESC

--Month On Month Total Laid off

SELECT 
	MONTH(date) AS Month,
	SUM(total_laid_off) AS Monthly_laid_off
FROM layoffs_stagging
WHERE date IS NOT NULL
GROUP BY 
	MONTH(date)
ORDER BY
	Month

--Rolling (cumulative) total over time — shows the overall trajectory

WITH Monthly AS (
SELECT 
	MONTH(date) AS Month,
	SUM(total_laid_off) AS Monthly_laid_off
FROM layoffs_stagging
WHERE date IS NOT NULL
GROUP BY 
	MONTH(date)
)
SELECT 
	Month,
	Monthly_laid_off,
	SUM(Monthly_laid_off) OVER (ORDER BY Month) AS Runn_Total_laid_off
FROM Monthly
ORDER BY
	Month

--Month on month percentage % 

WITH Monthly_per AS (
SELECT 
	MONTH(date) AS Month,
	SUM(total_laid_off) AS Monthly_laid
FROM layoffs_stagging
WHERE date IS NOT NULL
GROUP BY 
	MONTH(date)
)
SELECT 
	Month,Monthly_laid,
	LAG(Monthly_laid) OVER (ORDER BY Month) AS Previos_Laid,
	(Monthly_laid - LAG(Monthly_laid) OVER (ORDER BY Month))*100.0 /
	NULLIF((LAG(Monthly_laid) OVER (ORDER BY Month),0) AS Monthly_pct
FROM Monthly_per
ORDER BY Month

--Industry trend by year — which industries got worse/better over time

SELECT 
	industry,
	YEAR(date) AS Year,
	SUM(total_laid_off) AS Yearly_laid_off
FROM layoffs_stagging
WHERE date IS NOT NULL
GROUP BY 
	YEAR(date),
	industry
ORDER BY
	industry, Year

--Average % of workforce laid off, by year — severity trend, not just volume

SELECT 
	YEAR(date) AS Year,
	ROUND(AVG(percentage_laid_off) * 100,2) AS Avg_perc_laid_off
FROM layoffs_stagging
WHERE date IS NOT NULL
GROUP BY 
	YEAR(date)
ORDER BY YEAR

--Companies with repeated layoff rounds — signals ongoing instability

SELECT 
	company,
	COUNT(*) AS Number_of_Round,
	SUM(total_laid_off) AS Total_laid_off
FROM layoffs_stagging
GROUP BY company
HAVING COUNT(*) > 1
ORDER BY 
	Number_of_Round DESC,
	Total_laid_off DESC

--Funds raised vs. total laid off — quick correlation check

SELECT 
	company,
	SUM(funds_raised) AS Total_funds_raised,
	SUM(total_laid_off) AS Total_laid_off
FROM layoffs_stagging
GROUP BY 
	company,
	funds_raised
ORDER BY 
	Total_funds_raised DESC

CREATE VIEW Clean_layoffs AS 
	SELECT * FROM layoffs_stagging
	WHERE date IS NOT NULL

