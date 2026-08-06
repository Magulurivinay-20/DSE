SET SERVEROUTPUT ON;

-- 1. Create a procedure to accept an empno as a input parameter and display the detail like ename, sal and deptno.
CREATE OR REPLACE PROCEDURE get_emp_details (
    p_empno IN emp.empno%TYPE
) IS
    v_ename  emp.ename%TYPE;
    v_sal    emp.sal%TYPE;
    v_deptno emp.deptno%TYPE;
BEGIN
    SELECT ename, sal, deptno 
    INTO v_ename, v_sal, v_deptno
    FROM emp
    WHERE empno = p_empno;

    DBMS_OUTPUT.PUT_LINE('Employee Name : ' || v_ename);
    DBMS_OUTPUT.PUT_LINE('Salary        : ' || v_sal);
    DBMS_OUTPUT.PUT_LINE('Department No : ' || v_deptno);
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Employee ID ' || p_empno || ' not found.');
END;
/

-- 2. Create a function called Add_Num() that accept two parameter of number type and return the addition result in number type.
CREATE OR REPLACE FUNCTION Add_Num (
    p_num1 IN NUMBER,
    p_num2 IN NUMBER
) RETURN NUMBER IS
BEGIN
    RETURN p_num1 + p_num2;
END;
/

-- 3. Create a procedure that will display all the names list of procedures and functions from the current schema by querying user_source table with the help of cursor.
CREATE OR REPLACE PROCEDURE list_procs_and_funcs IS
    CURSOR c_objects IS
        SELECT DISTINCT name, type
        FROM user_source
        WHERE type IN ('PROCEDURE', 'FUNCTION')
        ORDER BY type, name;
BEGIN
    DBMS_OUTPUT.PUT_LINE(RPAD('NAME', 30) || ' | ' || 'TYPE');
    DBMS_OUTPUT.PUT_LINE('---------------------------------------------');
    FOR r IN c_objects LOOP
        DBMS_OUTPUT.PUT_LINE(RPAD(r.name, 30) || ' | ' || r.type);
    END LOOP;
END;
/