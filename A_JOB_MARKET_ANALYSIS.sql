USE `sql data analysis`;
-- no. of rows
SELECT COUNT(*) 
FROM ai_job_dataset;
-- preview first 5 rows
SELECT * FROM ai_job_dataset
LIMIT 5;
-- checking for any distinct salaries
SELECT distinct salary_currency
FROM ai_job_dataset;
-- add a new column with salaries converted in USD
ALTER TABLE ai_job_dataset
ADD COLUMN salary_usd_CONVERTED FLOAT;

SET SQL_SAFE_UPDATES = 0;

UPDATE ai_job_dataset
SET salary_usd_CONVERTED = 
  CASE salary_currency
    WHEN 'USD' THEN salary_usd
    WHEN 'EUR' THEN salary_usd * 1.17
    WHEN 'GBP' THEN salary_usd * 1.35
  END
WHERE salary_currency IN ('USD', 'EUR', 'GBP');

-- checking the first 10 rows
SELECT * FROM ai_job_dataset
LIMIT 10;

-- total no.of rows
SELECT COUNT(*) AS TOTAL_NO_OF_ROWS
 FROM ai_job_dataset;
 
 -- checking for missing values
 SELECT COUNT(salary_usd_CONVERTED), COUNT(job_title),COUNT(experience_level), 
  SUM(CASE WHEN salary_usd_CONVERTED IS NULL THEN 1 ELSE 0 END) AS salary_missing,
  SUM(CASE WHEN job_title IS NULL THEN 1 ELSE 0 END) AS job_title_missing,
  SUM(CASE WHEN experience_level IS NULL THEN 1 ELSE 0 END) AS experience_level_missing
FROM ai_job_dataset;

-- salary summary
SELECT job_title, 
  MIN(salary_usd_CONVERTED) AS min_salary, 
  MAX(salary_usd_CONVERTED) AS max_salary, 
  ROUND(AVG(salary_usd_CONVERTED), 0) AS avg_salary, 
  COUNT(*) AS job_count
FROM ai_job_dataset
GROUP BY job_title
ORDER BY avg_salary DESC
LIMIT 5;

SELECT job_title, 
  ROUND(AVG(salary_usd_CONVERTED), 0) AS avg_salary,
  COUNT(*) AS job_count
FROM ai_job_dataset
GROUP BY job_title
ORDER BY avg_salary DESC
LIMIT 5;

-- average salary by experience level

SELECT experience_level, 
  ROUND(AVG(salary_usd_CONVERTED), 0) AS avg_salary, 
  COUNT(*) AS total_jobs
FROM ai_job_dataset
GROUP BY experience_level
ORDER BY avg_salary DESC;

-- average salary by company
SELECT company_name, 
  ROUND(AVG(salary_usd_CONVERTED), 0) AS avg_salary, 
  COUNT(*) AS job_count
FROM ai_job_dataset
GROUP BY company_name
HAVING COUNT(*) > 5
ORDER BY avg_salary DESC
LIMIT 5;


-- remote ratio by jobs
SELECT remote_ratio, 
  COUNT(*) AS number_of_jobs
FROM ai_job_dataset
GROUP BY remote_ratio
ORDER BY remote_ratio DESC;

-- avg salary by education

SELECT education_required, 
  ROUND(AVG(salary_usd_CONVERTED), 0) AS avg_salary
FROM ai_job_dataset
GROUP BY education_required
ORDER BY avg_salary DESC;


-- average salary by years of experience

SELECT years_experience, 
  ROUND(AVG(salary_usd_CONVERTED), 0) AS avg_salary
FROM ai_job_dataset
GROUP BY years_experience
ORDER BY years_experience;

-- median salary by job title
WITH RankedSalaries AS (
  SELECT job_title, salary_usd_CONVERTED,
         ROW_NUMBER() OVER (PARTITION BY job_title ORDER BY salary_usd_CONVERTED) AS rn,
         COUNT(*) OVER (PARTITION BY job_title) AS total_count
  FROM ai_job_dataset
)
SELECT job_title, 
       ROUND(AVG(salary_usd_CONVERTED), 0) AS median_salary
FROM RankedSalaries
WHERE rn IN (FLOOR((total_count + 1) / 2), CEIL((total_count + 1) / 2))
GROUP BY job_title
ORDER BY median_salary DESC
LIMIT 5;














