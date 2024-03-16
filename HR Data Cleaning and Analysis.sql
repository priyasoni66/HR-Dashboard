CREATE DATABASE humanresources;

USE humanresources;

DESCRIBE hr;

SELECT * FROM hr;

ALTER TABLE hr CHANGE COLUMN ï»¿id emp_id VARCHAR(20) NULL;

UPDATE hr
SET birthdate = CASE
	WHEN birthdate LIKE '%/%' THEN date_format(str_to_date(birthdate, '%m/%d/%Y'), '%Y-%m-%d')
    WHEN birthdate LIKE '%-%' THEN date_format(str_to_date(birthdate, '%m-%d-%Y'), '%Y-%m-%d')
    ELSE NULL
END;

ALTER TABLE hr
MODIFY COLUMN birthdate DATE;

UPDATE hr
SET hire_date = CASE
	WHEN hire_date LIKE '%/%' THEN date_format(str_to_date(hire_date, '%m/%d/%Y'), '%Y-%m-%d')
    WHEN hire_date LIKE '%-%' THEN date_format(str_to_date(hire_date, '%m-%d-%Y'), '%Y-%m-%d')
    ELSE NULL
END;


ALTER TABLE hr
MODIFY COLUMN hire_date DATE;


UPDATE hr
SET termdate = date(str_to_date(termdate, '%Y-%m-%d %H:%i:%s UTC'))
WHERE termdate IS NOT NULL AND termdate != '';

ALTER TABLE hr ADD COLUMN age INT;

UPDATE hr SET age = timestampdiff(YEAR, birthdate, curdate());

UPDATE hr
SET age = timestampdiff(YEAR, birthdate, CURDATE());

SELECT 
    min(age) AS youngest,
    max(age) AS oldest
FROM hr;



-- QUESTIONS

-- 1. What is the gender breakdown of employees in the company?

SELECT gender, COUNT(*) AS count
FROM hr
WHERE termdate IS NULL
GROUP BY gender;

-- 2. What is the race/ethnicity breakdown of employees in the company?

SELECT race, COUNT(*) AS count
FROM hr
WHERE termdate IS NULL
GROUP BY race
ORDER BY count DESC;

-- 3. What is the age distribution of employees in the company?

SELECT 
  CASE 
    WHEN age >= 18 AND age <= 24 THEN '18-24'
    WHEN age >= 25 AND age <= 34 THEN '25-34'
    WHEN age >= 35 AND age <= 44 THEN '35-44'
    WHEN age >= 45 AND age <= 54 THEN '45-54'
    WHEN age >= 55 AND age <= 64 THEN '55-64'
    ELSE '65+' 
  END AS age_group, 
  COUNT(*) AS count
FROM hr
WHERE termdate IS NULL
GROUP BY age_group
ORDER BY age_group;


SELECT 
  CASE 
    WHEN age >= 18 AND age <= 24 THEN '18-24'
    WHEN age >= 25 AND age <= 34 THEN '25-34'
    WHEN age >= 35 AND age <= 44 THEN '35-44'
    WHEN age >= 45 AND age <= 54 THEN '45-54'
    WHEN age >= 55 AND age <= 64 THEN '55-64'
    ELSE '65+' 
  END AS age_group, gender, 
  COUNT(*) AS count
FROM hr
WHERE termdate IS NULL
GROUP BY age_group, gender
ORDER BY age_group, gender;


-- 4. How many employees work at headquarters versus remote locations?

SELECT location, COUNT(*) as count
FROM hr
WHERE termdate IS NULL
GROUP BY location;

-- 5. What is the average length of employment for employees who have been terminated?

SELECT ROUND(AVG(year(termdate) - year(hire_date)),0) AS length_of_emp
FROM hr
WHERE termdate IS NOT NULL AND termdate <=curdate();


-- 6. How does the gender distribution vary across departments?

SELECT department, gender, COUNT(*) as count
FROM hr
WHERE termdate IS NULL
GROUP BY department, gender
ORDER BY department;

-- 7. What is the distribution of job titles across the company?

SELECT jobtitle, COUNT(*) as count
FROM hr
WHERE termdate IS NULL
GROUP BY jobtitle
ORDER BY jobtitle DESC;


-- 8. Which department has the highest turnover rate?
SELECT department, COUNT(*) AS total_count, 
    count(CASE 
			WHEN termdate  IS NOT NULL AND termdate <= CURDATE() THEN 1 END) AS terminated_count, 
    round((count( CASE WHEN termdate  IS NOT NULL AND termdate <= CURDATE() THEN 1 END)/ count(*))*100,2) AS termination_rate 
FROM hr
GROUP BY department
ORDER BY termination_rate DESC;


-- 9. What is the distribution of employees across locations by city and state?
SELECT location_city, COUNT(*) as count
FROM hr
WHERE termdate IS NULL
GROUP BY location_city
ORDER BY count DESC;


SELECT location_state, COUNT(*) as count
FROM hr
WHERE termdate IS NULL
GROUP BY location_state
ORDER BY count DESC;

-- 10. How has the company's employee count changed over time based on hire and term dates?
SELECT year, hires, terminations, hires-terminations AS net_change, (terminations/hires)*100 AS change_percent 
FROM( 
	SELECT YEAR(hire_date) AS year, 
    count(*) AS hires,
	SUM(CASE 
			WHEN termdate IS NOT NULL AND termdate <=curdate() THEN 1 
            END) AS terminations 
            FROM hr 
            GROUP BY YEAR(hire_date)) As subquery 
GROUP BY YEAR 
ORDER BY YEAR;

-- 11. What is the tenure distribution for each department?

SELECT department, round(avg(datediff(termdate, hire_date)/365),0) AS avg_tenure
FROM hr
WHERE termdate IS NOT NULL AND termdate <=curdate()
GROUP BY department;

