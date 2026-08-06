SET SERVEROUTPUT ON;

-- 1. Create a Function GET_JOB that will return JOB of an Employee. Define a session variable TITLE allowing a length of 35 characters. Invoke the function to return the value in the session variable and print.
CREATE OR REPLACE FUNCTION GET_JOB (
    p_empno IN emp.empno%TYPE
) RETURN VARCHAR2 IS
    v_job emp.job%TYPE;
BEGIN
    SELECT job INTO v_job
    FROM emp
    WHERE empno = p_empno;
    
    RETURN v_job;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN 'NOT FOUND';
END;
/

-- Execution using Session Variable:
VARIABLE TITLE VARCHAR2(35);
EXECUTE :TITLE := GET_JOB(7788);
PRINT TITLE;


-- 2. Create a function GET_ANNUAL_SAL that will calculate the annual salary of an Employee. Call the function from a SELECT statement against the EMP table for employees in DEPTNO 30.
CREATE OR REPLACE FUNCTION GET_ANNUAL_SAL (
    p_empno IN emp.empno%TYPE
) RETURN NUMBER IS
    v_annual_sal NUMBER;
BEGIN
    SELECT (sal * 12) + NVL(comm, 0)
    INTO v_annual_sal
    FROM emp
    WHERE empno = p_empno;
    
    RETURN v_annual_sal;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN 0;
END;
/

-- Calling from SELECT statement:
SELECT empno, ename, sal, comm, GET_ANNUAL_SAL(empno) AS "ANNUAL_SALARY"
FROM emp
WHERE deptno = 30;


-- 3. Assuming no relationship in DEPT and EMP tables.
-- Create a function VALID_DEPTNO for a specific DEPTNO returning BOOLEAN.
-- Create a procedure ADD_EMP that inserts into EMP table only if VALID_DEPTNO returns TRUE.
CREATE OR REPLACE FUNCTION VALID_DEPTNO (
    p_deptno IN dept.deptno%TYPE
) RETURN BOOLEAN IS
    v_count NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_count
    FROM dept
    WHERE deptno = p_deptno;
    
    RETURN (v_count > 0);
END;
/

CREATE OR REPLACE PROCEDURE ADD_EMP (
    p_empno  IN emp.empno%TYPE,
    p_ename  IN emp.ename%TYPE,
    p_sal    IN emp.sal%TYPE,
    p_deptno IN emp.deptno%TYPE
) IS
BEGIN
    IF VALID_DEPTNO(p_deptno) THEN
        INSERT INTO emp (empno, ename, sal, deptno)
        VALUES (p_empno, p_ename, p_sal, p_deptno);
        DBMS_OUTPUT.PUT_LINE('Employee added successfully.');
    ELSE
        DBMS_OUTPUT.PUT_LINE('Alert: Invalid Department Number ' || p_deptno || '. Employee not added.');
    END IF;
END;
/


-- 4. Create a PLSQL function CAL_REVERSE taking a string and returning its reverse without using built-in REVERSE function.
CREATE OR REPLACE FUNCTION CAL_REVERSE (
    p_str IN VARCHAR2
) RETURN VARCHAR2 IS
    v_reversed VARCHAR2(4000) := '';
BEGIN
    FOR i IN REVERSE 1..LENGTH(p_str) LOOP
        v_reversed := v_reversed || SUBSTR(p_str, i, 1);
    END LOOP;
    
    RETURN v_reversed;
END;
/

-- Test:
SELECT CAL_REVERSE('ORACLE') AS "REVERSED_STRING" FROM DUAL;


-- 5. Create a function CAL_PCT calculating percentage of salary. Use 16% as default parameter for percentage.
CREATE OR REPLACE FUNCTION CAL_PCT (
    p_empno IN emp.empno%TYPE,
    p_pct   IN NUMBER DEFAULT 16
) RETURN NUMBER IS
    v_sal emp.sal%TYPE;
BEGIN
    SELECT sal INTO v_sal
    FROM emp
    WHERE empno = p_empno;
    
    RETURN v_sal * (p_pct / 100);
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN 0;
END;
/

-- Calling using EMP table:
SELECT empno, ename, sal, CAL_PCT(empno) AS "16_PCT_SAL"
FROM emp;


-- 6. Function returning TRUE if SAL is less than Average salary else FALSE.
-- Procedure REC_INSUPD that inserts or updates rows only if new salary is less than avgsal.
CREATE OR REPLACE FUNCTION IS_SAL_BELOW_AVG (
    p_sal IN NUMBER
) RETURN BOOLEAN IS
    v_avg_sal NUMBER;
BEGIN
    SELECT AVG(sal) INTO v_avg_sal FROM emp;
    RETURN (p_sal < v_avg_sal);
END;
/

CREATE OR REPLACE PROCEDURE REC_INSUPD (
    p_empno IN emp.empno%TYPE,
    p_ename IN emp.ename%TYPE,
    p_sal   IN emp.sal%TYPE
) IS
    v_count NUMBER;
BEGIN
    IF IS_SAL_BELOW_AVG(p_sal) THEN
        SELECT COUNT(*) INTO v_count FROM emp WHERE empno = p_empno;
        
        IF v_count = 0 THEN
            INSERT INTO emp (empno, ename, sal)
            VALUES (p_empno, p_ename, p_sal);
            DBMS_OUTPUT.PUT_LINE('Record inserted successfully.');
        ELSE
            UPDATE emp
            SET ename = p_ename, sal = p_sal
            WHERE empno = p_empno;
            DBMS_OUTPUT.PUT_LINE('Record updated successfully.');
        END IF;
    ELSE
        DBMS_OUTPUT.PUT_LINE('Operation denied: Salary ' || p_sal || ' is not less than average salary.');
    END IF;
END;
/


-- 7. Create a function CAL_LDATE returning DAY, MONTH DD, YYYY in GERMAN for employee hiredate.
CREATE OR REPLACE FUNCTION CAL_LDATE (
    p_empno IN emp.empno%TYPE
) RETURN VARCHAR2 IS
    v_hiredate emp.hiredate%TYPE;
    v_formatted_date VARCHAR2(100);
BEGIN
    SELECT hiredate INTO v_hiredate
    FROM emp
    WHERE empno = p_empno;
    
    SELECT TO_CHAR(v_hiredate, 'Day, Month DD, YYYY', 'NLS_DATE_LANGUAGE = GERMAN')
    INTO v_formatted_date
    FROM DUAL;
    
    RETURN v_formatted_date;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN 'NOT FOUND';
END;
/


-- 8. Create a function CAL_WORDS that returns a numeric value in Words.
CREATE OR REPLACE FUNCTION CAL_WORDS (
    p_num IN NUMBER
) RETURN VARCHAR2 IS
    v_words VARCHAR2(4000);
BEGIN
    SELECT TO_CHAR(TO_DATE(p_num, 'J'), 'JSP')
    INTO v_words
    FROM DUAL;
    
    RETURN v_words;
EXCEPTION
    WHEN OTHERS THEN
        RETURN 'NUMBER OUT OF RANGE';
END;
/

-- Test:
SELECT CAL_WORDS(1234) AS "IN_WORDS" FROM DUAL;


-- 9. Wrap the function GET_JOB and then test using USER_SOURCE.
-- Command Prompt Execution:
-- wrap iname=get_job.sql oname=get_job.plb
-- @get_job.plb

-- Querying encrypted source code in USER_SOURCE:
SELECT text 
FROM user_source 
WHERE name = 'GET_JOB' 
ORDER BY line;