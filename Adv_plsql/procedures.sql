SET SERVEROUTPUT ON;

-- 1. Create a procedure ADD_DEPT taking DEPTNO, DNAME, LOC. Handle duplicate row insertion using User-Defined Exception Handler.
CREATE OR REPLACE PROCEDURE ADD_DEPT (
    p_deptno IN dept.deptno%TYPE,
    p_dname  IN dept.dname%TYPE,
    p_loc    IN dept.loc%TYPE
) IS
    e_dup_dept EXCEPTION;
    PRAGMA EXCEPTION_INIT(e_dup_dept, -00001);
BEGIN
    INSERT INTO dept (deptno, dname, loc)
    VALUES (p_deptno, p_dname, p_loc);
    
    DBMS_OUTPUT.PUT_LINE('Department added successfully.');
EXCEPTION
    WHEN e_dup_dept THEN
        DBMS_OUTPUT.PUT_LINE('Error: Department ID ' || p_deptno || ' already exists.');
END;
/

-- 2. Create a procedure UPDATE_DEPT taking DEPTNO, DNAME, LOC. Handle non-existent DEPTNO exception.
CREATE OR REPLACE PROCEDURE UPDATE_DEPT (
    p_deptno IN dept.deptno%TYPE,
    p_dname  IN dept.dname%TYPE,
    p_loc    IN dept.loc%TYPE
) IS
    e_dept_not_found EXCEPTION;
BEGIN
    UPDATE dept
    SET dname = p_dname, loc = p_loc
    WHERE deptno = p_deptno;

    IF SQL%NOTFOUND THEN
        RAISE e_dept_not_found;
    ELSE
        DBMS_OUTPUT.PUT_LINE('Department updated successfully.');
    END IF;
EXCEPTION
    WHEN e_dept_not_found THEN
        DBMS_OUTPUT.PUT_LINE('Error: Department ID ' || p_deptno || ' does not exist.');
END;
/

-- 3. Create a procedure DELETE_DEPT taking DEPTNO. Handle non-existent DEPTNO exception.
CREATE OR REPLACE PROCEDURE DELETE_DEPT (
    p_deptno IN dept.deptno%TYPE
) IS
    e_dept_not_found EXCEPTION;
BEGIN
    DELETE FROM dept
    WHERE deptno = p_deptno;

    IF SQL%NOTFOUND THEN
        RAISE e_dept_not_found;
    ELSE
        DBMS_OUTPUT.PUT_LINE('Department deleted successfully.');
    END IF;
EXCEPTION
    WHEN e_dept_not_found THEN
        DBMS_OUTPUT.PUT_LINE('Error: Department ID ' || p_deptno || ' does not exist.');
END;
/

-- 4. Create user WIPRO, modify ADD_DEPT to use AUTHID CURRENT_USER, grant EXECUTE, and test call from WIPRO user.
-- Create WIPRO user (Execute as SYS/DBA)
CREATE USER WIPRO IDENTIFIED BY password;
GRANT CREATE SESSION, CREATE TABLE TO WIPRO;

-- Modify ADD_DEPT with AUTHID CURRENT_USER (Execute as SCOTT)
CREATE OR REPLACE PROCEDURE ADD_DEPT (
    p_deptno IN dept.deptno%TYPE,
    p_dname  IN dept.dname%TYPE,
    p_loc    IN dept.loc%TYPE
) AUTHID CURRENT_USER IS
    e_dup_dept EXCEPTION;
    PRAGMA EXCEPTION_INIT(e_dup_dept, -00001);
BEGIN
    INSERT INTO dept (deptno, dname, loc)
    VALUES (p_deptno, p_dname, p_loc);
    
    DBMS_OUTPUT.PUT_LINE('Department added successfully in current user schema.');
EXCEPTION
    WHEN e_dup_dept THEN
        DBMS_OUTPUT.PUT_LINE('Error: Department ID ' || p_deptno || ' already exists.');
END;
/

GRANT EXECUTE ON ADD_DEPT TO WIPRO;

-- Create DEPT table in WIPRO schema & test execution (Execute as WIPRO)
-- CREATE TABLE dept AS SELECT * FROM scott.dept WHERE 1=2;
-- EXEC scott.ADD_DEPT(50, 'TEST', 'HYD');

-- 5. Modify DEPT table by adding column X, check status, recompile, check status, drop column X.
ALTER TABLE dept ADD (x VARCHAR2(10));

-- Check status of dependent procedures
SELECT object_name, status 
FROM user_objects 
WHERE object_name IN ('ADD_DEPT', 'UPDATE_DEPT', 'DELETE_DEPT');

-- Recompile procedures to make them VALID
ALTER PROCEDURE ADD_DEPT COMPILE;
ALTER PROCEDURE UPDATE_DEPT COMPILE;
ALTER PROCEDURE DELETE_DEPT COMPILE;

-- Check status again
SELECT object_name, status 
FROM user_objects 
WHERE object_name IN ('ADD_DEPT', 'UPDATE_DEPT', 'DELETE_DEPT');

-- Drop Column X
ALTER TABLE dept DROP COLUMN x;

-- 6. Wrap ADD_DEPT procedure using PL/SQL Wrapper CLI.
-- Command Prompt Execution:
-- wrap iname=add_dept.sql oname=add_dept.plb
-- @add_dept.plb

-- 7. Insert into EMP_TEST for given deptno and update EMP table salary by 20% using Parameter Cursor, FOR LOOP Cursor, and UPDATE clause Cursor.
CREATE OR REPLACE PROCEDURE PROCESS_EMP_DEPT (
    p_deptno IN emp.deptno%TYPE
) IS
    CURSOR c_emp (p_dno NUMBER) IS
        SELECT empno, ename, job, mgr, hiredate, sal, comm, deptno
        FROM emp
        WHERE deptno = p_dno
        FOR UPDATE OF sal;
BEGIN
    FOR r IN c_emp(p_deptno) LOOP
        -- Insert into EMP_TEST table
        INSERT INTO emp_test (empno, ename, job, mgr, hiredate, sal, comm, deptno)
        VALUES (r.empno, r.ename, r.job, r.mgr, r.hiredate, r.sal, r.comm, r.deptno);

        -- Update salary in EMP table by 20%
        UPDATE emp
        SET sal = sal * 1.20
        WHERE CURRENT OF c_emp;
    END LOOP;
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Employees processed and salaries updated.');
END;
/

-- 8. Delete employees from EMP for a given deptno and insert into TEST table using Parameter Cursor, UPDATE Clause Cursor, FOR LOOP Cursor.
CREATE OR REPLACE PROCEDURE MOVE_EMP_DEPT (
    p_deptno IN emp.deptno%TYPE
) IS
    CURSOR c_emp_del (p_dno NUMBER) IS
        SELECT empno, ename, sal, deptno
        FROM emp
        WHERE deptno = p_dno
        FOR UPDATE;
BEGIN
    FOR r IN c_emp_del(p_deptno) LOOP
        -- Insert into TEST table
        INSERT INTO test (empno, ename, sal, deptno)
        VALUES (r.empno, r.ename, r.sal, r.deptno);

        -- Delete from EMP table
        DELETE FROM emp
        WHERE CURRENT OF c_emp_del;
    END LOOP;
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Employees moved to TEST table successfully.');
END;
/

-- 9. Create GET_EMP procedure (EMPNO IN, ENAME OUT, SAL OUT) and execute from SQL Prompt using 2 session variables for EMPNO 7788.
CREATE OR REPLACE PROCEDURE GET_EMP (
    p_empno IN  emp.empno%TYPE,
    p_ename OUT emp.ename%TYPE,
    p_sal   OUT emp.sal%TYPE
) IS
BEGIN
    SELECT ename, sal
    INTO p_ename, p_sal
    FROM emp
    WHERE empno = p_empno;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Employee ID ' || p_empno || ' not found.');
END;
/

-- Calling from SQL Prompt:
VARIABLE g_ename VARCHAR2(20);
VARIABLE g_sal NUMBER;

EXECUTE GET_EMP(7788, :g_ename, :g_sal);

PRINT g_ename g_sal;

-- 10. Procedure with IN OUT argument for Mobile Number. Converts 9999999999 to (999)999-9999.
CREATE OR REPLACE PROCEDURE FORMAT_MOBILE_NO (
    p_mobile_no IN OUT VARCHAR2
) IS
BEGIN
    IF LENGTH(p_mobile_no) = 10 THEN
        p_mobile_no := '(' || SUBSTR(p_mobile_no, 1, 3) || ')' || 
                              SUBSTR(p_mobile_no, 4, 3) || '-' || 
                              SUBSTR(p_mobile_no, 7, 4);
    ELSE
        DBMS_OUTPUT.PUT_LINE('Invalid mobile number length.');
    END IF;
END;
/

-- Test Execution:
DECLARE
    v_mobile VARCHAR2(20) := '9999999999';
BEGIN
    FORMAT_MOBILE_NO(v_mobile);
    DBMS_OUTPUT.PUT_LINE('Formatted Mobile Number: ' || v_mobile);
END;
/