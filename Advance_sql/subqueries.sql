-- 1. Create a report that displays EMPNO, ENAME, DEPTNO of employees who work with that Employee (in the same department).
SELECT empno, ename, deptno 
FROM emp 
WHERE deptno IN (
    SELECT deptno 
    FROM emp 
    WHERE ename = &employee_name
)
AND ename != &employee_name;

-- 2. Display the employees who earn more than the avg salary of EMP table.
SELECT empno, ename, sal 
FROM emp 
WHERE sal > (
    SELECT AVG(sal) 
    FROM emp
);

-- 3. Display the ENAME, JOB who are Managers (Use EXISTS Operator).
SELECT ename, job 
FROM emp e 
WHERE EXISTS (
    SELECT 1 
    FROM emp m 
    WHERE m.mgr = e.empno
);

-- 4. Display the employees who earn less than the least salary of DEPTNO 10 (Use ALL operator).
SELECT ename, sal 
FROM emp 
WHERE sal < ALL (
    SELECT sal 
    FROM emp 
    WHERE deptno = 10
);

-- 5. Display the employees who have the same DEPTNO and MGR of a given employee, excluding that employee.
SELECT ename, deptno, mgr 
FROM emp 
WHERE (deptno, mgr) = (
    SELECT deptno, mgr 
    FROM emp 
    WHERE ename = &employee_name
)
AND ename != &employee_name;

-- 6. Write a query that displays the employee number and name of all employees who work in a department with any employee whose name contains an 'R'.
SELECT empno, ename 
FROM emp 
WHERE deptno IN (
    SELECT DISTINCT deptno 
    FROM emp 
    WHERE ename LIKE '%R%'
);

-- 7. Display the ename, deptno, job of all employees who work in NEW YORK.
SELECT ename, deptno, job 
FROM emp 
WHERE deptno = (
    SELECT deptno 
    FROM dept 
    WHERE loc = 'NEW YORK'
);

-- 8. Modify the query so that the user is prompted for a LOC.
SELECT ename, deptno, job 
FROM emp 
WHERE deptno = (
    SELECT deptno 
    FROM dept 
    WHERE loc = '&location_name'
);

-- 9. Create a report that displays the name and salary of every employee who reports to King.
SELECT ename, sal 
FROM emp 
WHERE mgr = (
    SELECT empno 
    FROM emp 
    WHERE ename = 'KING'
);

-- 10. Write a query to display all the employees working with JAMES (same department).
SELECT empno, ename, deptno 
FROM emp 
WHERE deptno = (
    SELECT deptno 
    FROM emp 
    WHERE ename = 'JAMES'
)
AND ename != 'JAMES';

-- 11. Display all the employees who earn less than the average salaries of their respective departments (Correlated Subquery).
SELECT e.ename, e.sal, e.deptno 
FROM emp e 
WHERE e.sal < (
    SELECT AVG(sal) 
    FROM emp 
    WHERE deptno = e.deptno
);

-- 12. Write a query to display the LOC and average salary of Each location (Scalar Subquery).
SELECT d.loc, 
       (SELECT AVG(sal) 
        FROM emp e 
        WHERE e.deptno = d.deptno) AS "Avg Salary" 
FROM dept d;

-- 13. Write a query to display the least N salaries (Use In-Line Views / ROWNUM).
SELECT ename, sal 
FROM (
    SELECT ename, sal 
    FROM emp 
    ORDER BY sal ASC
) 
WHERE ROWNUM <= &N;

-- 14. Display the Last N rows from the employees table (Use Correlated Subqueries / ROWNUM).
SELECT empno, ename, sal 
FROM emp e 
WHERE &N >= (
    SELECT COUNT(*) 
    FROM emp 
    WHERE empno >= e.empno
)
ORDER BY empno ASC;

-- 15. Display the employees from employees table and sort only employees working in DALLAS (Scalar Subquery in ORDER BY).
SELECT e.ename, e.sal, e.deptno 
FROM emp e 
ORDER BY CASE 
    WHEN e.deptno = (SELECT deptno FROM dept WHERE loc = 'DALLAS') THEN 1 
    ELSE 2 
END, e.ename;

-- 16. Display the employees who earn a salary less than avgsal of their respective department. Also display the avgsal (Use Inline Views).
SELECT e.ename, e.sal, e.deptno, d.avg_sal 
FROM emp e 
JOIN (
    SELECT deptno, AVG(sal) AS avg_sal 
    FROM emp 
    GROUP BY deptno
) d ON e.deptno = d.deptno 
WHERE e.sal < d.avg_sal;

-- 17. Write a query that displays the LOC of those DEPTS that have a sum of sal less than the avgsal of all the employees in DEPT table (Use WITH Clause).
WITH DeptSum AS (
    SELECT deptno, SUM(sal) AS total_sal 
    FROM emp 
    GROUP BY deptno
),
OverallAvg AS (
    SELECT AVG(sal) AS avg_sal 
    FROM emp
)
SELECT d.loc 
FROM dept d 
JOIN DeptSum ds ON d.deptno = ds.deptno 
CROSS JOIN OverallAvg oa 
WHERE ds.total_sal < oa.avg_sal;