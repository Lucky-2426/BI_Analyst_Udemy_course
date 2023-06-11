-- Exercise 1
SELECT
    YEAR(d.from_date) AS Calendar_year,
    e.gender AS Gender,
    COUNT(e.emp_no) AS Number_of_employees
FROM
    t_dept_emp d
        JOIN
    t_employees e ON d.emp_no = e.emp_no
GROUP BY Calendar_year , Gender
HAVING Calendar_year >= '1990'
ORDER BY Calendar_year;

--Exercise 2
SELECT
    d.dept_name,
    ee.gender,
    dm.emp_no,
    dm.from_date,
    dm.to_date,
    e.calendar_year,
	CASE
		WHEN YEAR(dm.to_date) >= e.calendar_year AND YEAR(dm.from_date) <= e.calendar_year THEN 1
		ELSE 0
	END AS active
FROM
	(SELECT
		YEAR(hire_date) AS calendar_year
	FROM
		t_employees
	GROUP BY calendar_year) e
		CROSS JOIN
	t_dept_manager dm
		JOIN
	t_departments d ON dm.dept_no = d.dept_no
		JOIN
	t_employees ee ON dm.emp_no = ee.emp_no
ORDER BY calendar_year, dm.emp_no ;