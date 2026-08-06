SET SERVEROUTPUT ON;

-- 1. Write an implicit cursor that will prompt for a JOB and delete the employees working in that Job. Store the number of records deleted in a session variable.
VARIABLE g_deleted_count NUMBER;

DECLARE
    v_job emp.job%TYPE := UPPER('&p_job');
BEGIN
    DELETE FROM emp WHERE job = v_job;
    :g_deleted_count := SQL%ROWCOUNT;
    DBMS_OUTPUT.PUT_LINE(:g_deleted_count || ' employee(s) deleted.');
END;
/

-- 2. Rollback the previous Delete Statement.
ROLLBACK;

-- 3. Write a program that displays the Top N salaries using simple Explicit Cursors.
DECLARE
    v_n NUMBER := &p_n;
    v_count NUMBER := 0;
    
    CURSOR c_top_sal IS
        SELECT ename, sal
        FROM emp
        ORDER BY sal DESC;
        
    v_emp c_top_sal%ROWTYPE;
BEGIN
    OPEN c_top_sal;
    LOOP
        FETCH c_top_sal INTO v_emp;
        EXIT WHEN c_top_sal%NOTFOUND OR v_count = v_n;
        
        v_count := v_count + 1;
        DBMS_OUTPUT.PUT_LINE(v_count || '. ' || v_emp.ename || ' - ' || v_emp.sal);
    END LOOP;
    CLOSE c_top_sal;
END;
/

-- 4. Create a Simple Explicit Cursor that displays all the employees who are earning more than the average salary of the Emp Table.
DECLARE
    CURSOR c_above_avg IS
        SELECT ename, sal
        FROM emp
        WHERE sal > (SELECT AVG(sal) FROM emp);
        
    v_emp c_above_avg%ROWTYPE;
BEGIN
    OPEN c_above_avg;
    LOOP
        FETCH c_above_avg INTO v_emp;
        EXIT WHEN c_above_avg%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE('Employee: ' || v_emp.ename || ' | Salary: ' || v_emp.sal);
    END LOOP;
    CLOSE c_above_avg;
END;
/

-- 5. Create a Simple Explicit cursor that displays the employees who earn more than 2000 and have joined the company after 15-Jun-1981.
-- Print the output : <ename> earns <sal> and joined the organization on <hiredate>.
DECLARE
    CURSOR c_emp IS
        SELECT ename, sal, TO_CHAR(hiredate, 'DD-Mon-YYYY') AS formatted_hiredate
        FROM emp
        WHERE sal > 2000 
          AND hiredate > TO_DATE('15-06-1981', 'DD-MM-YYYY');
          
    v_rec c_emp%ROWTYPE;
BEGIN
    OPEN c_emp;
    LOOP
        FETCH c_emp INTO v_rec;
        EXIT WHEN c_emp%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE(v_rec.ename || ' earns ' || v_rec.sal || ' and joined the organization on ' || v_rec.formatted_hiredate || '.');
    END LOOP;
    CLOSE c_emp;
END;
/

-- 6. Create a Simple Explicit cursor that displays the hiredate in the format DD-MM-RRRR and Day. Sort the records on DAY starting from Saturday.
DECLARE
    CURSOR c_hire_day IS
        SELECT ename, 
               TO_CHAR(hiredate, 'DD-MM-RRRR') AS formatted_date, 
               TO_CHAR(hiredate, 'Day') AS day_name
        FROM emp
        ORDER BY MOD(TO_CHAR(hiredate, 'D') + 1, 7);
BEGIN
    FOR r IN c_hire_day LOOP
        DBMS_OUTPUT.PUT_LINE(RPAD(r.ename, 10) || ' | ' || r.formatted_date || ' | ' || TRIM(r.day_name));
    END LOOP;
END;
/

-- 7. Create a simple explicit cursor that displays the employees names and commission amounts. If an employee does not earn commission, show "No Commission". Label the column COMM.
DECLARE
    CURSOR c_comm IS
        SELECT ename, NVL(TO_CHAR(comm), 'No Commission') AS COMM
        FROM emp;
BEGIN
    FOR r IN c_comm LOOP
        DBMS_OUTPUT.PUT_LINE(RPAD(r.ename, 10) || ' | COMM: ' || r.COMM);
    END LOOP;
END;
/

-- 8. Create a parameter cursor that takes DEPTNO as a parameter and update the star column with '*'.
-- Every '*' represent a 1000. Use Parameter Cursor, CURSOR WITH FOR LOOP and WHERE CURRENT OF OPTION.
DECLARE
    CURSOR c_dept_sal (p_deptno NUMBER) IS
        SELECT sal, star
        FROM emp
        WHERE deptno = p_deptno
        FOR UPDATE OF star;
BEGIN
    FOR r IN c_dept_sal(&p_deptno) LOOP
        UPDATE emp
        SET star = RPAD('*', TRUNC(r.sal / 1000), '*')
        WHERE CURRENT OF c_dept_sal;
    END LOOP;
END;
/

-- 9. Write a Parameter Cursor program that promotes CLERK who earn more than 1000 to SR CLERK and increase the salary by 10%. Pass CLERK as a parameter to the Cursor.
-- Use Parameter Cursor, CURSOR WITH FOR LOOP and CURSOR WITH UPDATE CLAUSE.
DECLARE
    CURSOR c_promote (p_job VARCHAR2) IS
        SELECT job, sal
        FROM emp
        WHERE job = p_job AND sal > 1000
        FOR UPDATE OF job, sal;
BEGIN
    FOR r IN c_promote('CLERK') LOOP
        UPDATE emp
        SET job = 'SR CLERK',
            sal = sal * 1.10
        WHERE CURRENT OF c_promote;
    END LOOP;
END;
/

-- 10. Display entire record from the Dept table by passing a DEPTNO.
-- Increase the Salary of employees working in deptno 10 by 15%, Deptno 20 by 15% and others by 5%. Also display the corresponding employees working in that Dept.
-- Use a parameter Cursor, For Loop Cursor and Cursor with Update clause.
DECLARE
    v_deptno dept.deptno%TYPE := &p_deptno;
    v_drec   dept%ROWTYPE;
    
    CURSOR c_emp_update (p_deptno NUMBER) IS
        SELECT ename, sal, deptno
        FROM emp
        WHERE deptno = p_deptno
        FOR UPDATE OF sal;
BEGIN
    SELECT * INTO v_drec FROM dept WHERE deptno = v_deptno;
    DBMS_OUTPUT.PUT_LINE('DEPTNO: ' || v_drec.deptno || ' | DNAME: ' || v_drec.dname || ' | LOC: ' || v_drec.loc);
    DBMS_OUTPUT.PUT_LINE('--------------------------------------------------');

    FOR r IN c_emp_update(v_deptno) LOOP
        IF r.deptno IN (10, 20) THEN
            UPDATE emp SET sal = sal * 1.15 WHERE CURRENT OF c_emp_update;
        ELSE
            UPDATE emp SET sal = sal * 1.05 WHERE CURRENT OF c_emp_update;
        END IF;
        DBMS_OUTPUT.PUT_LINE('Updated Employee: ' || r.ename || ' | Old Sal: ' || r.sal);
    END LOOP;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Department ID not found.');
END;
/

-- 11. Write a program that will prompt the user for a CHOICE. IF CHOICE is 1 then display all the employees who earn more than 2000 from EMP table else display all the Employees who earn less than 2000. Use REF CURSORS.
DECLARE
    TYPE emp_ref_cur IS REF CURSOR;
    c_emp     emp_ref_cur;
    v_choice  NUMBER := &p_choice_1_or_2;
    v_emp_rec emp%ROWTYPE;
BEGIN
    IF v_choice = 1 THEN
        OPEN c_emp FOR SELECT * FROM emp WHERE sal > 2000;
    ELSE
        OPEN c_emp FOR SELECT * FROM emp WHERE sal < 2000;
    END IF;

    LOOP
        FETCH c_emp INTO v_emp_rec;
        EXIT WHEN c_emp%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE(RPAD(v_emp_rec.ename, 10) || ' | Salary: ' || v_emp_rec.sal);
    END LOOP;
    
    CLOSE c_emp;
END;
/