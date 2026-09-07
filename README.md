# 📉 Tech Layoffs Analysis (2020–2026)

An end-to-end data analytics project analyzing real-world tech industry layoffs — from raw messy data to a fully interactive Power BI dashboard.

**Pipeline:** Raw Data → SQL Data Cleaning → SQL Exploratory Data Analysis → Power BI Dashboard

---

## 📌 Project Overview

This project explores tech industry layoffs data (2020–2026) to answer key business questions:
- Which companies, industries, and countries were hit hardest?
- How did layoffs trend over time, and when did they peak?
- Did well-funded companies still collapse?
- Which companies had repeated rounds of layoffs?

---

## 🗂️ Dataset

- **File:** [`data/layoffs.csv`](./data/layoffs.csv)
- **Fields:** company, location, total_laid_off, date, percentage_laid_off, industry, stage, funds_raised, country, date_added
- **Raw rows:** 4,594 → **Cleaned rows:** 3,850

---

## 🧹 1. Data Cleaning (SQL)

Performed in T-SQL / SQL Server. Key steps:
- Copied raw data into a staging table to preserve the original source
- Removed exact duplicate rows using `ROW_NUMBER()` over a CTE
- Trimmed whitespace across all text columns (company, location, industry, stage, country)
- Standardized inconsistent industry naming (e.g. "Crypto", "crypto" → unified to "Crypto") — 179 records corrected
- Standardized inconsistent date formats into a single clean `DATE` column
- Converted blank strings to proper NULLs (distinct from missing data)
- Removed rows where both `total_laid_off` and `percentage_laid_off` were NULL
- Corrected column data types (`funds_raised`, `percentage_laid_off` → DECIMAL)
- Validated no impossible values remained (negative layoffs, percentages outside 0–1)

📄 Script: [`sql/cleaning.sql`](./sql/cleaning.sql)

---

## 🔍 2. Exploratory Data Analysis (SQL)

Used window functions and aggregations to uncover patterns:
- Total layoffs by company, industry, country, and stage
- Companies that laid off 100% of staff (shut down) — **370 companies**
- Year-over-year and month-over-month layoff trends
- **Rolling cumulative total** of layoffs over time (`SUM() OVER`)
- **Top 3 companies per year** by layoffs (`DENSE_RANK() OVER (PARTITION BY year ...)`)
- Companies with multiple layoff rounds (recurring instability)
- Funds raised vs. total layoffs (correlation check)

📄 Script: [`sql/eda.sql`](./sql/eda.sql)

---

## 📊 3. Power BI Dashboard

A 2-page interactive dashboard:

**Page 1 — Overview**
- KPI cards: Total Layoffs, Companies Affected, Avg % Laid Off, Companies Fully Shut Down
- Layoffs trend over time (with rolling total)
- Top 10 companies by total layoffs
- Layoffs by industry

**Page 2 — Deep Dive**
- Layoffs by country (map)
- Funds raised vs. total layoffs (scatter plot)
- Top 3 companies per year (matrix)

Built with a custom Date table, DAX time-intelligence measures (YoY growth, rolling totals), and interactive slicers (Year, Industry, Country, Stage).

🖼️ Preview: see [`/screenshots`](./screenshots)

📝 Full write-up with charts: [`reports/Layoffs_Findings_Report.docx`](./reports/Layoffs_Findings_Report.docx)

---

## 💡 Key Insights

- **932,766 total layoffs** recorded across **2,602 distinct companies** (avg. 29.6% of workforce per event)
- **2023 was the worst year on record** — 265,660 layoffs, more than any other year
- **Amazon had the highest cumulative layoffs** of any company (59,560) across **17 separate rounds** — more than any other company
- **370 companies (~1 in 7) recorded 100% layoffs**, effectively shutting down
- **Funding didn't guarantee survival** — funds raised vs. total layoffs showed only a weak correlation (0.124); several companies that raised $1B+ (Britishvolt, Quibi, Fisker, Katerra, Lilium) still went to 100% layoffs
- **2021 had the highest average severity** (61% of workforce cut per event) despite the lowest total volume — deep, concentrated cuts rather than broad-based ones
- The **United States accounted for the large majority of layoffs** (660,310), followed by India and Germany

---

## 🛠️ Tools Used

- **SQL Server (T-SQL)** — data cleaning, EDA, CTEs, window functions (ROW_NUMBER, DENSE_RANK, LAG, SUM OVER)
- **Power BI** — data modeling, DAX, interactive dashboarding
- **Python (pandas)** — validation and chart generation for the findings report

---

## 📁 Repository Structure

```
layoffs-2020-analysis/
├── data/
│   └── layoffs.csv
├── sql/
│   ├── cleaning.sql
│   └── eda.sql
├── reports/
│   └── Layoffs_Findings_Report.docx
├── powerbi/
│   └── layoffs_dashboard.pbix
├── screenshots/
│   ├── page1_overview.png
│   └── page2_deepdive.png
└── README.md
```

---

## 🔗 Connect

**Sumit Kohli** — Data Analyst | [GitHub](https://github.com/sumitkohli592) | [LinkedIn](#)
