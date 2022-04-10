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
