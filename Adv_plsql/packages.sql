SET SERVEROUTPUT ON;

-- 1. Create Package PK1 with 3 procedures (ADD_DEPT, UPDATE_DEPT, DELETE_DEPT), local function CAL_CNT, and a one-time initialization procedure.

-- Package Specification
CREATE OR REPLACE PACKAGE PK1 AS
    PROCEDURE ADD_DEPT (
        p_dno  IN dept.deptno%TYPE,
        p_name IN dept.dname%TYPE,
        p_lo   IN dept.loc%TYPE
    );

    PROCEDURE UPDATE_DEPT (
        p_dno  IN dept.deptno%TYPE,
        p_name IN dept.dname%TYPE,
        p_lo   IN dept.loc%TYPE
    );

    PROCEDURE DELETE_DEPT (
        p_dno IN dept.deptno%TYPE
    );
END PK1;
/

-- Package Body
CREATE OR REPLACE PACKAGE BODY PK1 AS

    -- Local function CAL_CNT (Private)
    FUNCTION CAL_CNT (
        p_dno IN dept.deptno%TYPE
    ) RETURN BOOLEAN IS
        v_count NUMBER;
    BEGIN
        SELECT COUNT(*) INTO v_count
        FROM dept
        WHERE deptno = p_dno;

        RETURN (v_count = 0);
    END CAL_CNT;

    -- Procedure 1: ADD_DEPT
    PROCEDURE ADD_DEPT (
        p_dno  IN dept.deptno%TYPE,
        p_name IN dept.dname%TYPE,
        p_lo   IN dept.loc%TYPE
    ) IS
        e_dup_dept EXCEPTION;
    BEGIN
        IF NOT CAL_CNT(p_dno) THEN
            RAISE e_dup_dept;
        END IF;

        INSERT INTO dept (deptno, dname, loc)
        VALUES (p_dno, p_name, p_lo);

        DBMS_OUTPUT.PUT_LINE('Department ' || p_dno || ' added successfully.');
    EXCEPTION
        WHEN e_dup_dept THEN
            DBMS_OUTPUT.PUT_LINE('Error: Department ' || p_dno || ' already exists.');
    END ADD_DEPT;

    -- Procedure 2: UPDATE_DEPT
    PROCEDURE UPDATE_DEPT (
        p_dno  IN dept.deptno%TYPE,
        p_name IN dept.dname%TYPE,
        p_lo   IN dept.loc%TYPE
    ) IS
        e_no_dept EXCEPTION;
    BEGIN
        IF CAL_CNT(p_dno) THEN
            RAISE e_no_dept;
        END IF;

        UPDATE dept
        SET dname = p_name, loc = p_lo
        WHERE deptno = p_dno;

        DBMS_OUTPUT.PUT_LINE('Department ' || p_dno || ' updated successfully.');
    EXCEPTION
        WHEN e_no_dept THEN
            DBMS_OUTPUT.PUT_LINE('Error: Department ' || p_dno || ' does not exist.');
    END UPDATE_DEPT;

    -- Procedure 3: DELETE_DEPT
    PROCEDURE DELETE_DEPT (
        p_dno IN dept.deptno%TYPE
    ) IS
        e_no_dept EXCEPTION;
    BEGIN
        IF CAL_CNT(p_dno) THEN
            RAISE e_no_dept;
        END IF;

        DELETE FROM dept
        WHERE deptno = p_dno;

        DBMS_OUTPUT.PUT_LINE('Department ' || p_dno || ' deleted successfully.');
    EXCEPTION
        WHEN e_no_dept THEN
            DBMS_OUTPUT.PUT_LINE('Error: Department ' || p_dno || ' does not exist.');
    END DELETE_DEPT;

-- One-Time Initialization Block
BEGIN
    DECLARE
        v_total_rows NUMBER;
    BEGIN
        SELECT COUNT(*) INTO v_total_rows FROM dept;
        DBMS_OUTPUT.PUT_LINE('Package PK1 Initialized. Total DEPT rows: ' || v_total_rows);
    END;
END PK1;
/


-- 2. Create Package PK2 with DISP_FIRST3 and DISP_FIRST6 procedures using a Global Cursor.

-- Package Specification
CREATE OR REPLACE PACKAGE PK2 AS
    CURSOR g_emp_cur IS
        SELECT empno, ename, sal, job 
        FROM emp 
        ORDER BY empno;

    PROCEDURE DISP_FIRST3;
    PROCEDURE DISP_FIRST6;
END PK2;
/

-- Package Body
CREATE OR REPLACE PACKAGE BODY PK2 AS

    PROCEDURE DISP_FIRST3 IS
        v_rec g_emp_cur%ROWTYPE;
    BEGIN
        DBMS_OUTPUT.PUT_LINE('--- FIRST 3 EMPLOYEES ---');
        IF NOT g_emp_cur%ISOPEN THEN
            OPEN g_emp_cur;
        END IF;

        FOR i IN 1..3 LOOP
            FETCH g_emp_cur INTO v_rec;
            EXIT WHEN g_emp_cur%NOTFOUND;
            DBMS_OUTPUT.PUT_LINE(v_rec.empno || ' | ' || RPAD(v_rec.ename, 10) || ' | ' || v_rec.job || ' | ' || v_rec.sal);
        END LOOP;
        
        CLOSE g_emp_cur;
    END DISP_FIRST3;

    PROCEDURE DISP_FIRST6 IS
        v_rec g_emp_cur%ROWTYPE;
    BEGIN
        DBMS_OUTPUT.PUT_LINE('--- FIRST 6 EMPLOYEES ---');
        IF NOT g_emp_cur%ISOPEN THEN
            OPEN g_emp_cur;
        END IF;

        FOR i IN 1..6 LOOP
            FETCH g_emp_cur INTO v_rec;
            EXIT WHEN g_emp_cur%NOTFOUND;
            DBMS_OUTPUT.PUT_LINE(v_rec.empno || ' | ' || RPAD(v_rec.ename, 10) || ' | ' || v_rec.job || ' | ' || v_rec.sal);
        END LOOP;
        
        CLOSE g_emp_cur;
    END DISP_FIRST6;

END PK2;
/


-- 3. Create sequence S2 and Package PK3 with overloaded ADD_EMP procedures.

-- Create Sequence
CREATE SEQUENCE S2 START WITH 1 INCREMENT BY 1;

-- Package Specification
CREATE OR REPLACE PACKAGE PK3 AS
    PROCEDURE ADD_EMP (
        p_empno IN emp.empno%TYPE,
        p_ename IN emp.ename%TYPE DEFAULT 'UNK',
        p_sal   IN emp.sal%TYPE   DEFAULT 1000
    );

    PROCEDURE ADD_EMP (
        p_ename IN emp.ename%TYPE DEFAULT 'UNK',
        p_sal   IN emp.sal%TYPE   DEFAULT 1000
    );
END PK3;
/

-- Package Body
CREATE OR REPLACE PACKAGE BODY PK3 AS

    -- Procedure 1: Accepts 3 arguments with explicit EMPNO
    PROCEDURE ADD_EMP (
        p_empno IN emp.empno%TYPE,
        p_ename IN emp.ename%TYPE DEFAULT 'UNK',
        p_sal   IN emp.sal%TYPE   DEFAULT 1000
    ) IS
    BEGIN
        INSERT INTO emp (empno, ename, sal)
        VALUES (p_empno, p_ename, p_sal);

        DBMS_OUTPUT.PUT_LINE('Employee ' || p_empno || ' added successfully with explicit EMPNO.');
    END ADD_EMP;

    -- Procedure 2: Accepts 2 arguments, generates EMPNO using Sequence S2
    PROCEDURE ADD_EMP (
        p_ename IN emp.ename%TYPE DEFAULT 'UNK',
        p_sal   IN emp.sal%TYPE   DEFAULT 1000
    ) IS
        v_seq_empno NUMBER;
    BEGIN
        v_seq_empno := S2.NEXTVAL;

        INSERT INTO emp (empno, ename, sal)
        VALUES (v_seq_empno, p_ename, p_sal);

        DBMS_OUTPUT.PUT_LINE('Employee ' || v_seq_empno || ' added successfully using Sequence S2.');
    END ADD_EMP;

END PK3;
/