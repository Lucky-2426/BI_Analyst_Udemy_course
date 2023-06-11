--CASE statement
--Exercise 1
SELECT
    e.emp_no,
    e.first_name,
    e.last_name,
    CASE
        WHEN dm.emp_no IS NOT NULL THEN 'Manager'
        ELSE 'Employee'
    END AS is_manager
FROM
    employees e
        LEFT JOIN
    dept_manager dm ON dm.emp_no = e.emp_no
WHERE
    e.emp_no > 109990;

-- Exercise 2
SELECT
    dm.emp_no,
    e.first_name,
    e.last_name,
    MAX(s.salary) - MIN(s.salary) AS salary_difference,
    CASE
        WHEN MAX(s.salary) - MIN(s.salary) > 30000 THEN 'Salary was raised by more then $30,000'
        ELSE 'Salary was NOT raised by more then $30,000'
    END AS salary_raise
FROM
    dept_manager dm
        JOIN
    employees e ON e.emp_no = dm.emp_no
        JOIN
    salaries s ON s.emp_no = dm.emp_no
GROUP BY s.emp_no;



SELECT
    dm.emp_no,
    e.first_name,
    e.last_name,
    MAX(s.salary) - MIN(s.salary) AS salary_difference,
    IF(MAX(s.salary) - MIN(s.salary) > 30000,
        'Salary was raised by more then $30,000',
        'Salary was NOT raised by more then $30,000') AS salary_increase
FROM
    dept_manager dm
        JOIN
    employees e ON e.emp_no = dm.emp_no
        JOIN
    salaries s ON s.emp_no = dm.emp_no
GROUP BY s.emp_no;

-- Exercise 3
SELECT
    e.emp_no,
    e.first_name,
    e.last_name,
    CASE
        WHEN MAX(de.to_date) > SYSDATE() THEN 'Is still employed'
        ELSE 'Not an employee anymore'
    END AS current_employee
FROM
    employees e
        JOIN
    dept_emp de ON de.emp_no = e.emp_no
GROUP BY de.emp_no
LIMIT 100;


-- ROW_NUMBER()
-- Exercise 1
/* Write a query that upon execution, assigns a row number to all managers we have information for in the "employees" database (regardless of their department).
Let the numbering disregard the department the managers have worked in.
Also, let it start from the value of 1. Assign that value to the manager with the lowest employee number.
*/
SELECT 
    *,
    ROW_NUMBER()OVER(ORDER BY emp_no) AS row_num
FROM dept_manager;

-- Exercise 2
/* Write a query that upon execution, assigns a sequential number for each employee number registered in the "employees" table.
Partition the data by the employee's first name and order it by their last name in ascending order (for each partition).*/
SELECT 
    *, ROW_NUMBER() OVER(PARTITION BY first_name ORDER BY last_name) AS row_num
FROM
    employees;

-- Exercise 3
/*
Write a query that provides row numbers for all workers from the "employees" table, partitioning the data by their first names and ordering each partition by their employee number in ascending order.
NB! While writing the desired query, do *not* use an ORDER BY clause in the relevant SELECT statement.
At the same time, do use a WINDOW clause to provide the required window specification.
*/
	SELECT emp_no, first_name,
    ROW_NUMBER() OVER w AS row_num
    FROM employees
    WINDOW w AS (PARTITION BY first_name ORDER BY emp_no);
    
-- Exercise 4
/*
Find out the lowest salary value each employee has ever signed a contract for. 
To obtain the desired output, use a subquery containing a window function, as well as a window specification introduced with the help of the WINDOW keyword.
Also, to obtain the desired result set, refer only to data from the “salaries” table.
*/
SELECT 
    a.emp_no, MIN(salary) AS min_salary FROM (
		SELECT emp_no, salary, ROW_NUMBER() OVER(w) as row_num
		FROM salaries
        WINDOW w AS (PARTITION BY emp_no ORDER BY salary)) as a
    GROUP BY emp_no;

-- Exercise 5
/*Again, find out the lowest salary value each employee has ever signed a contract for. Once again, to obtain the desired output, use a subquery containing a window function. 
This time, however, introduce the window specification in the field list of the given subquery.
To obtain the desired result set, refer only to data from the “salaries” table.
*/
	SELECT 
    a.emp_no, MIN(salary) AS min_salary FROM (
		SELECT emp_no, salary, ROW_NUMBER() OVER(PARTITION BY emp_no ORDER BY salary) as row_num
		FROM salaries) as a
    GROUP BY emp_no;

-- Exercise 6
/*Once again, find out the lowest salary value each employee has ever signed a contract for.
This time, to obtain the desired output, avoid using a window function. Just use an aggregate function and a subquery.
To obtain the desired result set, refer only to data from the “salaries” table.*/
	SELECT emp_no, MIN(salary) AS min_salary
    FROM salaries
    GROUP BY emp_no;


-- Exercise 7
/* Once more, find out the lowest salary value each employee has ever signed a contract for.
To obtain the desired output, use a subquery containing a window function, as well as a window specification introduced with the help of the WINDOW keyword.
Moreover, obtain the output without using a GROUP BY clause in the outer query.
To obtain the desired result set, refer only to data from the “salaries” table.
*/

	SELECT 
    a.emp_no, a.salary AS min_salary FROM (
		SELECT emp_no, salary, ROW_NUMBER() OVER(w) as row_num
		FROM salaries
        WINDOW w AS (PARTITION BY emp_no ORDER BY salary)) as a
    WHERE row_num = 1;

-- Exercise 8
/* Once more, find out the second-lowest salary value each employee has ever signed a contract for.
To obtain the desired output, use a subquery containing a window function, as well as a window specification introduced with the help of the WINDOW keyword.
Moreover, obtain the output without using a GROUP BY clause in the outer query.
To obtain the desired result set, refer only to data from the “salaries” table.
*/

	SELECT 
    a.emp_no, a.salary AS min_salary FROM (
		SELECT emp_no, salary, ROW_NUMBER() OVER(w) as row_num
		FROM salaries
        WINDOW w AS (PARTITION BY emp_no ORDER BY salary)) as a
    WHERE row_num = 2;
    
-- RANK() & DENSE_RANK
-- Exercise 1
/*
	Write a query containing a window function to obtain all salary values that employee number 10560 has ever signed a contract for.
    Order and display the obtained salary values from highest to lowest.
*/
	SELECT emp_no, salary, ROW_NUMBER() OVER(PARTITION BY emp_no ORDER BY salary DESC) as row_num
    FROM salaries
    WHERE emp_no = 10560;
    
-- Exercise 2 : Write a query that upon execution, displays the number of salary contracts that each manager has ever signed while working in the company.
SELECT s.emp_no, COUNT(s.salary) as contracts
FROM salaries as s
JOIN dept_manager as d
ON d.emp_no = s.emp_no
GROUP BY s.emp_no
ORDER BY s.emp_no;

-- Exercise 3
/* Write a query that upon execution retrieves a result set containing all salary values that employee 10560 has ever signed a contract for.
Use a window function to rank all salary values from highest to lowest in a way that equal salary values bear the same rank and that gaps in 
the obtained ranks for subsequent rows are allowed.*/
	SELECT emp_no, salary, RANK() OVER(w) as rank_num 
    FROM salaries
    WHERE emp_no = 10560
    WINDOW w as (PARTITION BY emp_no ORDER BY salary desc);
    
    SELECT emp_no, salary, DENSE_RANK() OVER(w) as rank_num 
    FROM salaries
    WHERE emp_no = 10560
    WINDOW w as (PARTITION BY emp_no ORDER BY salary desc);

-- WINDOW FUNCTIONS + JOINS
-- Exercise 1
/*
	
*/
SELECT 
    d.dept_no,
    d.dept_name,
    dm.emp_no,
    RANK() OVER w as dept_salary_ranking,
    s.salary,
    s.from_date as salary_from_date,
    s.to_date as salary_to_date,
    dm.from_date as dept_manager_from_date,
    dm.to_date as dept_manager_to_date
FROM dept_manager as dm
JOIN 
	salaries as s ON s.emp_no = dm.emp_no
    AND s.from_date BETWEEN dm.from_date AND dm.to_date
	AND s.to_date BETWEEN dm.from_date AND dm.to_date
JOIN 
	departments as d on d.dept_no = dm.dept_no
WINDOW w as (PARTITION BY dm.dept_no ORDER BY s.salary);    

-- Exercise 2
/* Write a query that ranks the salary values in descending order of all contracts signed by employees numbered between 10500 and 10600 inclusive.
Let equal salary values for one and the same employee bear the same rank. Also, allow gaps in the ranks obtained for their subsequent rows.
Use a join on the “employees” and “salaries” tables to obtain the desired result.
*/
-- Solution A 
SELECT e.emp_no, s.salary, RANK() OVER(PARTITION BY s.emp_no ORDER BY s.salary DESC) as salary_ranking
FROM employees as e
JOIN salaries as s ON s.emp_no = e.emp_no
AND s.emp_no BETWEEN 10500 and 10600;

-- Solution B
SELECT
    e.emp_no,
    RANK() OVER w as salary_ranking,
    s.salary
FROM employees e
JOIN
    salaries s ON s.emp_no = e.emp_no
WHERE e.emp_no BETWEEN 10500 AND 10600
WINDOW w as (PARTITION BY e.emp_no ORDER BY s.salary DESC);

-- Exercise 3
/* Write a query that ranks the salary values in descending order of the following contracts from the "employees" database:
- contracts that have been signed by employees numbered between 10500 and 10600 inclusive.
- contracts that have been signed at least 4 full-years after the date when the given employee was hired in the company for the first time.
In addition, let equal salary values of a certain employee bear the same rank. Do not allow gaps in the ranks obtained for their subsequent rows.
Use a join on the “employees” and “salaries” tables to obtain the desired result.
*/

SELECT 
    e.emp_no, 
    RANK() OVER(PARTITION BY e.emp_no ORDER BY s.salary DESC) as salary_ranking,
    s.salary, 
    e.hire_date,
    s.from_date,
    (YEAR(s.from_date)-YEAR(e.hire_date)) as years_from_start
FROM employees as e
JOIN 
	salaries as s ON s.emp_no = e.emp_no
	AND (YEAR(s.from_date) - YEAR(e.hire_date) >= 5)
WHERE e.emp_no BETWEEN 10500 and 10600;

-- VALUE WINDOW FUNCTIONS
-- Example
SELECT 
	emp_no, 
    salary, 
    LAG(salary) OVER w as previous_salary,
    LEAD(salary) OVER w as next_salary,
    salary - LAG(salary) OVER w AS diff_current_previous,
    LEAD(salary) OVER w - salary AS diff_next_current
FROM salaries
WHERE emp_no = 10001
WINDOW w as (ORDER BY salary);

-- Exercise 1
/* Write a query that can extract the following information from the "employees" database:
- the salary values (in ascending order) of the contracts signed by all employees numbered between 10500 and 10600 inclusive
- a column showing the previous salary from the given ordered list
- a column showing the subsequent salary from the given ordered list
- a column displaying the difference between the current salary of a certain employee and their previous salary
- a column displaying the difference between the next salary of a certain employee and their current salary

Limit the output to salary values higher than $80,000 only.
Also, to obtain a meaningful result, partition the data by employee number.*/

SELECT 
	emp_no,
	salary, 
	RANK() OVER w as salary_ranking,
    LAG(salary) OVER w as previous_salary,
    LEAD(salary) OVER w as next_salary,
    salary - LAG(salary) OVER w AS diff_current_previous,
    LEAD(salary) OVER w - salary AS diff_next_current
FROM salaries
WHERE emp_no BETWEEN 10500 and 10600
AND salary > 80000
WINDOW w as (PARTITION BY emp_no ORDER BY salary);

-- Exercise 2
/*The MySQL LAG() and LEAD() value window functions can have a second argument, designating how many rows/steps back (for LAG()) or forth (for LEAD()) we'd like to refer to with respect to a given record.

With that in mind, create a query whose result set contains data arranged by the salary values associated to each employee number (in ascending order). Let the output contain the following six columns:
- the employee number
- the salary value of an employee's contract (i.e. which we’ll consider as the employee's current salary)
- the employee's previous salary
- the employee's contract salary value preceding their previous salary
- the employee's next salary
- the employee's contract salary value subsequent to their next salary

Restrict the output to the first 1000 records you can obtain.*/

SELECT 
	emp_no, 
	salary,
	LAG(salary) OVER w as previous_salary,
    LAG(salary, 2) OVER w as before_previous_salary,
    LEAD(salary) OVER w as next_salary,
    LEAD(salary) OVER w as after_next_salary
FROM salaries
WINDOW w as (PARTITION BY emp_no ORDER BY salary)
LIMIT 1000;

-- AGGREGATE FUNCTIONS IN THE CONTEXT OF WINDOW FUNCTIONS
SELECT SYSDATE();

-- Exercise 1
/*
Create a query that upon execution returns a result set containing the employee numbers, 
contract salary values, start, and end dates of the first ever contracts that each employee signed for the company.
To obtain the desired output, refer to the data stored in the "salaries" table.
*/
SELECT s1.emp_no, s.salary, s.from_date, s.to_date
FROM salaries as s
JOIN
	(SELECT emp_no, MAX(from_date) as from_date
    FROM salaries
    GROUP BY emp_no) s1 ON s.emp_no = s1.emp_no
WHERE s.to_date > SYSDATE()
AND s.from_date = s1.from_date;
    
-- Exercice 2
/* Consider the employees' contracts that have been signed after the 1st of January 2000 and terminated before the 1st of January 2002 (as registered in the "dept_emp" table).
Create a MySQL query that will extract the following information about these employees:
- Their employee number
- The salary values of the latest contracts they have signed during the suggested time period
- The department they have been working in (as specified in the latest contract they've signed during the suggested time period)
- Use a window function to create a fourth field containing the average salary paid in the department the employee was last working in during the suggested time period.
Name that field "average_salary_per_department".
Note1: This exercise is not related neither to the query you created nor to the output you obtained while solving the exercises after the previous lecture.
Note2: Now we are asking you to practically create the same query as the one we worked on during the video lecture; the only difference being to refer to contracts that have been valid within the period between the 1st of January 2000 and the 1st of January 2002.
Note3: We invite you solve this task after assuming that the "to_date" values stored in the "salaries" and "dept_emp" tables are greater than the "from_date" values stored in these same tables. If you doubt that, you could include a couple of lines in your code to ensure that this is the case anyway!
Hint: If you've worked correctly, you should obtain an output containing 200 rows.*/

SELECT
    de2.emp_no, d.dept_name, s2.salary, AVG(s2.salary) OVER w AS average_salary_per_department
FROM
    (SELECT de.emp_no, de.dept_no, de.from_date, de.to_date
	FROM dept_emp de
        JOIN
			(SELECT
			emp_no, MAX(from_date) AS from_date
			FROM dept_emp
			GROUP BY emp_no) de1 ON de1.emp_no = de.emp_no
			WHERE de.to_date < '2002-01-01'
			AND de.from_date > '2000-01-01'
			AND de.from_date = de1.from_date) de2
JOIN
    (SELECT s1.emp_no, s.salary, s.from_date, s.to_date
	FROM salaries s
    JOIN
		(SELECT emp_no, MAX(from_date) AS from_date
		FROM salaries
		GROUP BY emp_no) s1 ON s.emp_no = s1.emp_no
		WHERE s.to_date < '2002-01-01'
		AND s.from_date > '2000-01-01'
		AND s.from_date = s1.from_date) s2 ON s2.emp_no = de2.emp_no
JOIN departments d ON d.dept_no = de2.dept_no
GROUP BY de2.emp_no, d.dept_name
WINDOW w AS (PARTITION BY de2.dept_no)
ORDER BY de2.emp_no, salary;

-- CTE expressions
-- Exercise 1
/* Use a CTE (a Common Table Expression) and a SUM() function in the SELECT statement in a query to find out how many male employees
have never signed a contract with a salary value higher than or equal to the all-time company salary average.
*/
WITH cte AS (SELECT AVG(salary) AS avg_salary FROM salaries)

SELECT SUM(CASE WHEN s.salary >= c.avg_salary THEN 1 ELSE 0 END) AS no_salaries_above_avg,
COUNT(s.salary) AS no_of_salary_contracts
FROM salaries s 
JOIN employees e 
ON s.emp_no = e.emp_no AND e.gender = 'M' JOIN cte c;

-- Exercise 2
/* Use a CTE (a Common Table Expression) and (at least one) COUNT() function in the SELECT statement of a query to find out how many male employees
have never signed a contract with a salary value higher than or equal to the all-time company salary average.*/
WITH cte AS (SELECT AVG(salary) AS avg_salary FROM salaries)
SELECT
COUNT(CASE WHEN s.salary >= c.avg_salary THEN s.salary ELSE NULL END) AS no_salaries_above_avg_w_count,
COUNT(s.salary) AS no_of_salary_contracts
FROM salaries s
JOIN employees e 
ON s.emp_no = e.emp_no 
AND e.gender = 'M' 
JOIN cte c;

-- Exercise 3
/*Use MySQL joins (and don’t use a Common Table Expression) in a query to find out how many male employees have never signed a contract with a salary
value higher than or equal to the all-time company salary average (i.e. to obtain the same result as in the previous exercise).*/
SELECT 
    SUM(CASE WHEN s.salary >= a.avg_salary THEN 1 ELSE 0 END) AS salaries_above_avg,
    COUNT(s.salary) AS total_salary_contracts
FROM (SELECT AVG(salary) AS avg_salary FROM salaries s) a
JOIN salaries s
JOIN employees e ON e.emp_no = s.emp_no AND e.gender = 'M';

-- Exercise 4
/* Use a cross join in a query to find out how many male employees have never signed a contract with a salary value higher than or equal
 to the all-time company salary average (i.e. to obtain the same result as in the previous exercise).*/
 WITH cte AS (SELECT AVG(salary) AS avg_salary FROM salaries)
SELECT SUM(CASE WHEN s.salary >= c.avg_salary THEN 1 ELSE 0 END) AS salaries_above_avg_w_sum,
# COUNT(CASE WHEN s.salary < c.avg_salary THEN s.salary ELSE NULL END) AS no_salaries_below_avg_w_count,
COUNT(s.salary) AS total_salary_contracts
FROM salaries s 
JOIN employees e 
ON s.emp_no = e.emp_no AND e.gender = 'M' 
CROSS JOIN cte c;
 
-- Exercise 5
-- Use two common table expressions and a SUM() function in the SELECT statement of a query to obtain the number of male employees whose highest salaries have been below the all-time average.
WITH overall_avg AS (SELECT AVG(salary) AS avg_salary FROM salaries),
max_men_salary AS (
	SELECT s.emp_no, MAX(s.salary) AS max_salary
	FROM salaries s
	JOIN employees e ON e.emp_no = s.emp_no AND e.gender = 'M'
	GROUP BY s.emp_no)
    
SELECT SUM(CASE WHEN m.max_salary < o.avg_salary THEN 1 ELSE 0 END) AS highest_salaries_below_avg
FROM employees e
JOIN max_men_salary m ON m.emp_no = e.emp_no
JOIN overall_avg o;

-- Exercise 6
-- Use two common table expressions and a COUNT() function in the SELECT statement of a query to obtain the number of male employees whose highest salaries have been below the all-time average.
WITH overall_avg AS (SELECT AVG(salary) AS avg_salary FROM salaries),
max_men_salary AS (
	SELECT s.emp_no, MAX(s.salary) AS max_salary
	FROM salaries s
	JOIN employees e ON e.emp_no = s.emp_no AND e.gender = 'M'
	GROUP BY s.emp_no)
    
SELECT COUNT(CASE WHEN m.max_salary < o.avg_salary THEN 1 ELSE NULL END) AS highest_salaries_below_avg
FROM employees e
JOIN max_men_salary m ON m.emp_no = e.emp_no
JOIN overall_avg o;

-- Exercise 7
-- Does the result from the previous exercise change if you used the Common Table Expression (CTE) for the male employees' highest salaries in a FROM clause, as opposed to in a join?
WITH cte_avg_salary AS (SELECT AVG(salary) AS avg_salary FROM salaries),
cte_m_highest_salary AS (
	SELECT s.emp_no, MAX(s.salary) AS max_salary
	FROM salaries s JOIN employees e ON e.emp_no = s.emp_no AND e.gender = 'M'
	GROUP BY s.emp_no
	)

SELECT
COUNT(CASE WHEN c2.max_salary < c1.avg_salary THEN c2.max_salary ELSE NULL END) AS max_salary
FROM cte_m_highest_salary c2
JOIN cte_avg_salary c1;




























