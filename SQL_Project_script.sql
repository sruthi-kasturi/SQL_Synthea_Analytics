--Question 1: What are the most common conditions among patients? 
SELECT DESCRIPTION, COUNT(*) AS frequency
FROM conditions
GROUP BY DESCRIPTION
ORDER BY frequency DESC LIMIT 10;


--Question 2: What are the most common immunizations administered to patients in the dataset?
SELECT DESCRIPTION, COUNT(*) AS frequency
FROM immunizations
GROUP BY DESCRIPTION
ORDER BY frequency DESC LIMIT 10;


--Question 3: What are the most common conditions for different age groups
-- Add new columns
ALTER TABLE conditions
ADD age_at_condition integer, 
ADD age_group varchar(30);

-- Update age at condition
UPDATE conditions AS t1
SET age_at_condition = EXTRACT(YEAR FROM age(t1.start, t2.birthdate))
FROM patients AS t2
WHERE t2.id = t1.patient;

-- Categorize age groups
UPDATE conditions
SET age_group = CASE
    WHEN age_at_condition <= 18 THEN '0-18'
    WHEN age_at_condition BETWEEN 19 AND 35 THEN '19-35'
    WHEN age_at_condition BETWEEN 36 AND 50 THEN '36-50'
    WHEN age_at_condition BETWEEN 51 AND 65 THEN '51-65'
    ELSE '66+'
END;

-- Create a CTE for ranking and filter top 5 conditions
WITH rank_conditions AS (
    SELECT t2.age_group,
           t2.description,
           COUNT(*) AS frequency,
           ROW_NUMBER() OVER (PARTITION BY t2.age_group ORDER BY COUNT(*) DESC) AS rank
    FROM conditions AS t2
    JOIN patients AS t1 ON t1.id = t2.patient
    GROUP BY t2.description, t2.age_group
)
SELECT age_group, description, frequency
FROM rank_conditions
WHERE rank <= 5
ORDER BY age_group, rank;


--Question 4: What are the most common health conditions in different geographical regions?
WITH ranked_condition AS (
    SELECT t1.city, t2.description, COUNT(*) AS frequency,
           ROW_NUMBER() OVER(PARTITION BY t1.city ORDER BY COUNT(*) DESC) AS rank
    FROM patients AS t1
    JOIN conditions AS t2 ON t1.id = t2.patient
    GROUP BY t1.city, t2.description
)
SELECT city, description, frequency
FROM ranked_condition
WHERE rank = 1
ORDER BY city;


--Question 5: Which Health Conditions Are Most Common in Different Cities?
SELECT description, COUNT(*) AS city_count
FROM (SELECT 
            t1.city, 
            t2.description, 
            COUNT(*) AS frequency
        FROM patients AS t1
        JOIN conditions AS t2 ON t1.id = t2.patient
        GROUP BY t1.city, t2.description
	   ORDER BY t1.city, count(*)
    ) AS top_conditions
GROUP BY description
ORDER BY city_count DESC LIMIT 10;


--Question 6: How has the frequency of  'Body Mass Index 30.0-30.9, adult' changed over the years (2000 to 2020)?
SELECT extract(year FROM start) AS start_year, COUNT(*) 
FROM conditions AS c
WHERE c.start BETWEEN '2000-01-01' AND '2020-01-01' AND
    c.description = 'Body Mass Index 30.0-30.9, adult'
GROUP BY start_year
ORDER BY start_year;


--Question 7: What is the cost of different immunizations.
Query:

SELECT
    t1.description AS Immunization_Description,
    AVG(t2.base_encounter_cost) AS Average_Base_Cost,
    AVG(t2.total_claim_cost) AS Average_Claim_Cost
FROM
    immunizations AS t1
JOIN
    encounters AS t2
ON
    t2.id = t1.encounter
GROUP BY
    t1.description
ORDER BY 
	AVG(t2.total_claim_cost)


--Question 8: Finding out average length of stay as per age groups
-- Alter table to add columns
ALTER TABLE encounters
ADD COLUMN age_at_encounter INT,
ADD COLUMN age_group VARCHAR(10);

-- Update age_at_encounter based on patient's birthdate
UPDATE encounters
SET age_at_encounter = EXTRACT(YEAR FROM AGE(encounters.start, patients.birthdate))
FROM patients
WHERE encounters.patient = patients.id;

-- Update age_group based on age_at_encounter
UPDATE encounters
SET age_group = CASE
    WHEN age_at_encounter < 19 THEN '0-18'
    WHEN age_at_encounter BETWEEN 19 AND 35 THEN '19-35'
    WHEN age_at_encounter BETWEEN 36 AND 50 THEN '36-50'
    WHEN age_at_encounter BETWEEN 51 AND 65 THEN '51-65'
    ELSE '66+'
END;

-- Calculate average length of stay by age_group
SELECT AVG(EXTRACT(EPOCH FROM (stop - start)) / 86400) AS Avg_len_of_stay, age_group
FROM encounters
GROUP BY age_group
ORDER BY Avg_len_of_stay DESC;


--Question 9. Average hospital stay as per different conditions.
SELECT AVG(EXTRACT(EPOCH FROM (e.stop - e.start)) / 86400) AS avg_len_of_stay, c.description
FROM encounters AS e
JOIN conditions AS c ON e.patient = c.patient
GROUP BY c.description
ORDER BY avg_len_of_stay DESC LIMIT 15;







