-- Write a program that displays the Netsal (Sal+comm) of an employee entered at run time from EMP table. (Use NVL Function).
SET SERVEROUTPUT ON;

DECLARE
    v_empno   emp.empno%TYPE := &p_empno;
    v_ename   emp.ename%TYPE;
    v_netsal  NUMBER(10, 2);
BEGIN
    SELECT ename, sal + NVL(comm, 0)
    INTO v_ename, v_netsal
    FROM emp
    WHERE empno = v_empno;

    DBMS_OUTPUT.PUT_LINE('Employee Name: ' || v_ename);
    DBMS_OUTPUT.PUT_LINE('Net Salary: ' || v_netsal);
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Employee ID ' || v_empno || ' not found.');
END;
/