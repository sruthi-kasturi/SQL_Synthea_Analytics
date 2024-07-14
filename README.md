# synthea_sql_project

## Introduction
This project analyzes healthcare data to extract meaningful insights using SQL. It aims to identify common conditions, patient demographics, and other vital statistics to help healthcare providers improve patient care and resource allocation.

## Queries and Insights

### Question 1: What are the most common conditions among patients?
**Why is this important?**
Knowing the most common conditions helps healthcare providers focus on the most pressing health issues and allocate resources effectively.

**SQL Query:**
SELECT DESCRIPTION, COUNT(*) AS frequency
FROM conditions
GROUP BY DESCRIPTION
ORDER BY frequency DESC
LIMIT 10;
