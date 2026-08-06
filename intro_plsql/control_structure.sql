SET SERVEROUTPUT ON;

-- 1. Prompt for EMPNO, ENAME, SAL. Insert if EMPNO does not exist, else update ENAME and SAL.
DECLARE
    v_empno emp.empno%TYPE := &p_empno;
    v_ename emp.ename%TYPE := '&p_ename';
    v_sal   emp.sal%TYPE   := &p_sal;
    v_count NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_count FROM emp WHERE empno = v_empno;
    
    IF v_count = 0 THEN
        INSERT INTO emp (empno, ename, sal) VALUES (v_empno, v_ename, v_sal);
        DBMS_OUTPUT.PUT_LINE('Record inserted successfully.');
    ELSE
        UPDATE emp SET ename = v_ename, sal = v_sal WHERE empno = v_empno;
        DBMS_OUTPUT.PUT_LINE('Record updated successfully.');
    END IF;
END;
/

-- 2. Prompt for a number and display whether it is ODD or EVEN.
DECLARE
    v_num NUMBER := &p_num;
BEGIN
    IF MOD(v_num, 2) = 0 THEN
        DBMS_OUTPUT.PUT_LINE(v_num || ' is an EVEN number.');
    ELSE
        DBMS_OUTPUT.PUT_LINE(v_num || ' is an ODD number.');
    END IF;
END;
/

-- 3. Prompt for EMPNO and update salary based on DEPTNO (10 -> +10%, 20 -> +15%, Others -> SAL + NVL(COMM, 0)).
DECLARE
    v_empno  emp.empno%TYPE := &p_empno;
    v_deptno emp.deptno%TYPE;
BEGIN
    SELECT deptno INTO v_deptno FROM emp WHERE empno = v_empno;

    IF v_deptno = 10 THEN
        UPDATE emp SET sal = sal * 1.10 WHERE empno = v_empno;
    ELSIF v_deptno = 20 THEN
        UPDATE emp SET sal = sal * 1.15 WHERE empno = v_empno;
    ELSE
        UPDATE emp SET sal = sal + NVL(comm, 0) WHERE empno = v_empno;
    END IF;

    DBMS_OUTPUT.PUT_LINE('Salary updated successfully.');
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Employee ID not found.');
END;
/

-- 4. Create table MYTABLE1 and insert numbers 1 to 10 excluding 6 and 8.
CREATE TABLE MYTABLE1 (
    RESULT NUMBER
);

BEGIN
    FOR i IN 1..10 LOOP
        IF i IN (6, 8) THEN
            CONTINUE;
        END IF;
        INSERT INTO MYTABLE1 VALUES (i);
    END LOOP;
    COMMIT;
END;
/