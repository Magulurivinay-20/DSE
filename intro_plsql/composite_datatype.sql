-- Write a program that will display the entire row by passing the empno. (Use %ROWTYPE)
SET SERVEROUTPUT ON;

DECLARE
    v_empno emp.empno%TYPE := &p_empno;
    v_rec   emp%ROWTYPE;
BEGIN
    SELECT * INTO v_rec FROM emp WHERE empno = v_empno;

    DBMS_OUTPUT.PUT_LINE('EMPNO    : ' || v_rec.empno);
    DBMS_OUTPUT.PUT_LINE('ENAME    : ' || v_rec.ename);
    DBMS_OUTPUT.PUT_LINE('JOB      : ' || v_rec.job);
    DBMS_OUTPUT.PUT_LINE('MGR      : ' || v_rec.mgr);
    DBMS_OUTPUT.PUT_LINE('HIREDATE : ' || v_rec.hiredate);
    DBMS_OUTPUT.PUT_LINE('SAL      : ' || v_rec.sal);
    DBMS_OUTPUT.PUT_LINE('COMM     : ' || v_rec.comm);
    DBMS_OUTPUT.PUT_LINE('DEPTNO   : ' || v_rec.deptno);
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Employee ID ' || v_empno || ' not found.');
END;
/