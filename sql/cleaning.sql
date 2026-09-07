SELECT COUNT(*) AS Total_Row
FROM layoffs_messy;

SELECT COLUMN_NAME, DATA_TYPE, CHARACTER_MAXIMUM_LENGTH, IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'layoffs_messy'
ORDER BY ORDINAL_POSITION;

--Now Copying the Data From Orignal Table to a Temprory Table

SELECT * INTO
layoffs_stagging 
FROM layoffs_messy;

--Step 1 Cleaning the Duplicates With CTE And Window Function

WITH Del_Duplicate AS (
SELECT *,
	ROW_NUMBER() OVER (PARTITION BY company, location, total_laid_off,
		date, percentage_laid_off, industry, stage, funds_raised, country, date_added
			ORDER BY (SELECT NULL)) AS RN
FROM layoffs_stagging
)
DELETE FROM Del_Duplicate
WHERE RN > 1;

--Standardize the Text Columns to Trim the Leading Spaces

UPDATE layoffs_stagging
SET 
	company = TRIM(company),
	location = TRIM(location),
	industry = TRIM(industry),
	stage = TRIM(stage),
	country = TRIM(country)

UPDATE layoffs_stagging
SET 
	industry = 'Crypto'
WHERE industry LIKE 'Crypto%' OR industry LIKE 'crypto%'

--179 Records Cleaned

SELECT DISTINCT industry 
FROM layoffs_stagging
ORDER BY industry

-- 31 Distinct Industry Presents

SELECT DISTINCT country
FROM layoffs_stagging
ORDER BY country

-- 67 Distinct Country Presents

SELECT DISTINCT stage
FROM layoffs_stagging
ORDER BY stage

--17 Distinct Stage Presents

--Cheking Date Column Format

SELECT date 
FROM layoffs_stagging

--Changing the Format of Date Column to Day-Month-year

ALTER TABLE layoffs_stagging
ADD clean_date DATE;

ALTER TABLE layoffs_stagging ALTER COLUMN clean_date VARCHAR(20);

UPDATE layoffs_stagging
SET clean_date = CONVERT(VARCHAR, clean_date, 103);

SELECT date, clean_date
FROM layoffs_stagging
WHERE clean_date IS NULL AND date IS NOT NULL

--Delete the Column date and Rename the Clean Date Column Date

ALTER TABLE layoffs_stagging
DROP COLUMN [date];
	
EXEC sp_rename 'layoffs_stagging.clean_date', 'date', 'COLUMN'

--Handling Nulls and Blanks

UPDATE layoffs_stagging
SET industry = NULL 
WHERE 
	industry = ''

UPDATE layoffs_stagging
SET country = NULL
WHERE 
	country = ''

SELECT COUNT(*) AS Still_Null_Industry
FROM layoffs_stagging
WHERE
	industry = NULL

DELETE FROM layoffs_stagging
WHERE
	total_laid_off IS NULL AND
	percentage_laid_off IS NULL

--Final Validation Check list 
--No Duplicates Remains Entry Remains

SELECT company, location, total_laid_off, percentage_laid_off, industry,
	stage, funds_raised, country, date_added, date, COUNT(*)
FROM layoffs_stagging
GROUP BY 
	company, location, total_laid_off, percentage_laid_off, industry,
	stage, funds_raised, country, date_added, date
HAVING COUNT(*) > 1;

-- Checking for Empty Strings Hiding as Non Null

SELECT * FROM layoffs_stagging
WHERE 
	industry = '' OR country = '' OR stage = ''


--Checking Data Types are Correct or Not
SELECT COLUMN_NAME, DATA_TYPE 
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'layoffs_stagging'
ORDER BY ORDINAL_POSITION;

--Changing the Column Data Type From Float to Decimal

ALTER TABLE layoffs_stagging
ALTER COLUMN funds_raised DECIMAL(10,2)

ALTER TABLE layoffs_stagging
ALTER COLUMN percentage_laid_off DECIMAL(10,2)

--Checking for No impossible values (negative layoffs, percentage > 1)

SELECT * FROM layoffs_stagging
WHERE total_laid_off < 0 OR
percentage_laid_off > 1 OR
percentage_laid_off < 0

--Checking Row Counts for Before Cleaning And After Cleaning

SELECT 
	(SELECT COUNT(*) FROM layoffs_messy) AS Rows_Before,
	(SELECT COUNT(*) FROM layoffs_stagging) AS Rows_After

-- Cleaned Data Having 3850 Rows --
