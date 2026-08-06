SET SERVEROUTPUT ON;

-- 1. Create a MESSAGES table and write a program to prompt for SAL and log results/exceptions using named exception handlers.
CREATE TABLE MESSAGES (
    Result VARCHAR2(1000)
);

DECLARE
    v_sal   emp.sal%TYPE := &p_sal;
    v_ename emp.ename%TYPE;
BEGIN
    SELECT ename INTO v_ename
    FROM emp
    WHERE sal = v_sal;

    INSERT INTO MESSAGES VALUES (v_ename || ' ' || v_sal);
    DBMS_OUTPUT.PUT_LINE('Inserted: ' || v_ename || ' ' || v_sal);
EXCEPTION
    WHEN TOO_MANY_ROWS THEN
        INSERT INTO MESSAGES VALUES ('More than one employee with a salary ' || v_sal);
        DBMS_OUTPUT.PUT_LINE('Handled TOO_MANY_ROWS exception.');
    WHEN NO_DATA_FOUND THEN
        INSERT INTO MESSAGES VALUES ('No Employee with that salary ' || v_sal);
        DBMS_OUTPUT.PUT_LINE('Handled NO_DATA_FOUND exception.');
    WHEN OTHERS THEN
        INSERT INTO MESSAGES VALUES ('Other Error');
        DBMS_OUTPUT.PUT_LINE('Handled OTHERS exception.');
END;
/

-- 2. Prompt for Empno, ename, sal and insert into Emp table using an unnamed system-defined exception handler (e.g., primary key violation ORA-00001).
DECLARE
    v_empno emp.empno%TYPE := &p_empno;
    v_ename emp.ename%TYPE := '&p_ename';
    v_sal   emp.sal%TYPE   := &p_sal;

    e_dup_pk EXCEPTION;
    PRAGMA EXCEPTION_INIT(e_dup_pk, -00001);
BEGIN
    INSERT INTO emp (empno, ename, sal)
    VALUES (v_empno, v_ename, v_sal);

    DBMS_OUTPUT.PUT_LINE('Employee inserted successfully.');
EXCEPTION
    WHEN e_dup_pk THEN
        DBMS_OUTPUT.PUT_LINE('Error: Employee ID ' || v_empno || ' already exists (Duplicate Key Violation).');
END;
/

-- 3. Prompt for EMPNO and delete the employee from EMP table. Handle with User-Defined Exceptions.
DECLARE
    v_empno          emp.empno%TYPE := &p_empno;
    e_no_emp_deleted EXCEPTION;
BEGIN
    DELETE FROM emp WHERE empno = v_empno;

    IF SQL%NOTFOUND THEN
        RAISE e_no_emp_deleted;
    ELSE
        DBMS_OUTPUT.PUT_LINE('Employee ID ' || v_empno || ' deleted successfully.');
    END IF;
EXCEPTION
    WHEN e_no_emp_deleted THEN
        DBMS_OUTPUT.PUT_LINE('Error: No employee found with ID ' || v_empno || ' to delete.');
END;
/

-- 4. Stock table transaction update program with User-Defined Exceptions.
CREATE TABLE STOCK (
    PNO    NUMBER PRIMARY KEY,
    PNAME  VARCHAR2(50),
    RATE   NUMBER(10, 2),
    TR_QTY NUMBER
);

-- Sample Data Insertion
INSERT INTO STOCK VALUES (101, 'Monitor', 15000, 50);
INSERT INTO STOCK VALUES (102, 'Keyboard', 800, 100);
COMMIT;

DECLARE
    v_pno     STOCK.PNO%TYPE     := &p_pno;
    v_tr_type VARCHAR2(1)        := UPPER('&p_tr_type_R_or_I');
    v_tr_qty  STOCK.TR_QTY%TYPE  := &p_tr_qty;
    v_old_qty STOCK.TR_QTY%TYPE;

    e_invalid_type EXCEPTION;
    e_insufficient_stock EXCEPTION;
BEGIN
    SELECT TR_QTY INTO v_old_qty FROM STOCK WHERE PNO = v_pno;

    IF v_tr_type = 'R' THEN
        UPDATE STOCK SET TR_QTY = TR_QTY + v_tr_qty WHERE PNO = v_pno;
        DBMS_OUTPUT.PUT_LINE('Stock received. Updated Quantity: ' || (v_old_qty + v_tr_qty));
    ELSIF v_tr_type = 'I' THEN
        IF v_tr_qty > v_old_qty THEN
            RAISE e_insufficient_stock;
        END IF;
        UPDATE STOCK SET TR_QTY = TR_QTY - v_tr_qty WHERE PNO = v_pno;
        DBMS_OUTPUT.PUT_LINE('Stock issued. Remaining Quantity: ' || (v_old_qty - v_tr_qty));
    ELSE
        RAISE e_invalid_type;
    END IF;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Error: Product Number ' || v_pno || ' does not exist in stock.');
    WHEN e_invalid_type THEN
        DBMS_OUTPUT.PUT_LINE('Error: Invalid transaction type! Use ''R'' for Receipt or ''I'' for Issue.');
    WHEN e_insufficient_stock THEN
        DBMS_OUTPUT.PUT_LINE('Error: Insufficient stock available to fulfill issue request.');
END;
/