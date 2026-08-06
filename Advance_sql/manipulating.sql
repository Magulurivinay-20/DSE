-- 1. Create EmpTest from Emp table by copying structure and data.
CREATE TABLE EmpTest AS 
SELECT * FROM emp;

-- 2. Add a new row into the EmpTest table for Empno, Ename, Sal columns. Ename should have the Current User.
INSERT INTO EmpTest (empno, ename, sal) 
VALUES (9999, USER, 5000);

-- 3. Update EmpTest by increasing the Salary of TURNER by 15%. Confirm your changes.
UPDATE EmpTest 
SET sal = sal * 1.15 
WHERE ename = 'TURNER';

SELECT * FROM EmpTest WHERE ename = 'TURNER';

-- 4. Update the salary of Smith with salary of Scott using EmpTest table.
UPDATE EmpTest 
SET sal = (SELECT sal FROM EmpTest WHERE ename = 'SCOTT') 
WHERE ename = 'SMITH';

-- 5. Increase all the employees salary by 10% in EmpTest table who are working in NEW YORK.
UPDATE EmpTest 
SET sal = sal * 1.10 
WHERE deptno = (SELECT deptno FROM dept WHERE loc = 'NEW YORK');

-- 6. Delete all the Comm data from EmpTest Table.
UPDATE EmpTest 
SET comm = NULL;

-- 7. Delete all the employees from EmpTest table who are working in SALES dept.
DELETE FROM EmpTest 
WHERE deptno = (SELECT deptno FROM dept WHERE dname = 'SALES');

-- 8. Delete all who are working with that employee, except that Employee (Prompt for ENAME).
DELETE FROM EmpTest 
WHERE deptno = (SELECT deptno FROM EmpTest WHERE ename = '&employee_name') 
  AND ename != '&employee_name';

-- 9. Create Emp2 from Emp by only copying Empno, Ename, sal without copying data.
CREATE TABLE Emp2 AS 
SELECT empno, ename, sal FROM emp WHERE 1 = 2;

-- 10. Create Emp3 from Emp by only copying Empno, Job without copying data.
CREATE TABLE Emp3 AS 
SELECT empno, job FROM emp WHERE 1 = 2;

-- 11. Using multitable insert, insert Emp data into Emp2 and Emp3 Tables.
INSERT ALL 
  INTO Emp2 (empno, ename, sal) VALUES (empno, ename, sal) 
  INTO Emp3 (empno, job) VALUES (empno, job) 
SELECT empno, ename, sal, job FROM emp;

-- 12. Truncate Emp2 Table and insert following two rows: 7788, SMITH, 4500 / 7654, JACK, 3500.
TRUNCATE TABLE Emp2;

INSERT INTO Emp2 VALUES (7788, 'SMITH', 4500);
INSERT INTO Emp2 VALUES (7654, 'JACK', 3500);

-- 13. Commit the Data.
COMMIT;

-- 14. Using Merge statement insert and update Emp2 using Emp.
MERGE INTO Emp2 e2
USING emp e
ON (e2.empno = e.empno)
WHEN MATCHED THEN
  UPDATE SET e2.ename = e.ename, e2.sal = e.sal
WHEN NOT MATCHED THEN
  INSERT (empno, ename, sal) VALUES (e.empno, e.ename, e.sal);

-- 15. Verify your changes.
SELECT * FROM Emp2;

-- 16. Rollback the Data.
ROLLBACK;

-- 17. Using Merge statements update Emp2 table for only Empno=7788 and Insert only those employees whose salary is more than 3000.
MERGE INTO Emp2 e2
USING emp e
ON (e2.empno = e.empno)
WHEN MATCHED THEN
  UPDATE SET e2.ename = e.ename, e2.sal = e.sal
  WHERE e2.empno = 7788
WHEN NOT MATCHED THEN
  INSERT (empno, ename, sal) VALUES (e.empno, e.ename, e.sal)
  WHERE e.sal > 3000;

-- 18. Verify your changes.
SELECT * FROM Emp2;

-- 19. Create a User WIPRO.
CREATE USER WIPRO IDENTIFIED BY password;
GRANT CREATE SESSION TO WIPRO;

-- 20. Grant ALL permission on EMP table from SCOTT to WIPRO user.
GRANT ALL ON emp TO WIPRO;

-- 21. Delete all the employees in deptno 10 and do not issue a Commit.
DELETE FROM emp WHERE deptno = 10;

-- 22. From WIPRO user delete all the employees from SCOTT.EMP table in DEPTNO=10. What happens and Why?
-- Execute in WIPRO session:
DELETE FROM SCOTT.emp WHERE deptno = 10;
-- Explanation: The query will lock/hang because SCOTT holds an uncommitted row/table lock on DEPTNO 10 records.

-- 23. Issue a Rollback in SCOTT user and Check the WIPRO user.
-- Execute in SCOTT session:
ROLLBACK;
-- Explanation: Once SCOTT rolls back, WIPRO's blocked transaction proceeds and deletes the rows.

-- 24. In SCOTT user give a query on EMP using FOR UPDATE clause with WAIT 20 seconds. What happens?
SELECT * FROM emp WHERE deptno = 10 FOR UPDATE WAIT 20;
-- Explanation: SCOTT attempts to acquire an exclusive lock on the rows. If locked by another session, it waits up to 20 seconds before timing out with an ORA-30006 error.

-- 25. In WIPRO User issue a ROLLBACK and now check in SCOTT user.
-- Execute in WIPRO session:
ROLLBACK;
-- Explanation: Releasing locks in WIPRO allows SCOTT's lock request to immediately succeed.

-- 26. ROLLBACK all the transactions in SCOTT and WIPRO Users.
ROLLBACK;