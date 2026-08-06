SET SERVEROUTPUT ON;

-- 1. Create a BEFORE trigger that will restrict the user from performing DML statements between 9 to 17 on EMP Table.
CREATE OR REPLACE TRIGGER trg_restrict_dml_time
BEFORE INSERT OR UPDATE OR DELETE ON emp
BEGIN
    IF TO_NUMBER(TO_CHAR(SYSDATE, 'HH24')) BETWEEN 9 AND 16 THEN
        RAISE_APPLICATION_ERROR(-20001, 'DML operations on EMP table are restricted between 09:00 and 17:00.');
    END IF;
END;
/


-- 2. Create Audit_Emp table and a DML trigger with Autonomous Transaction using INSERTING, UPDATING, DELETING.
CREATE TABLE AUDIT_EMP (
    EMPNO    NUMBER(4),
    USERNAME VARCHAR2(30),
    TRDATE   DATE,
    TRTYPE   VARCHAR2(1)
);

CREATE OR REPLACE TRIGGER trg_audit_emp_dml
AFTER INSERT OR UPDATE OR DELETE ON emp
FOR EACH ROW
DECLARE
    PRAGMA AUTONOMOUS_TRANSACTION;
    v_trtype VARCHAR2(1);
    v_empno  emp.empno%TYPE;
BEGIN
    IF INSERTING THEN
        v_trtype := 'I';
        v_empno  := :NEW.empno;
    ELSIF UPDATING THEN
        v_trtype := 'U';
        v_empno  := :OLD.empno;
    ELSIF DELETING THEN
        v_trtype := 'D';
        v_empno  := :OLD.empno;
    END IF;

    INSERT INTO AUDIT_EMP (empno, username, trdate, trtype)
    VALUES (v_empno, USER, SYSDATE, v_trtype);

    COMMIT;
END;
/


-- 3. Create a complex view V3 and an INSTEAD OF TRIGGER for INSERT OR UPDATE.
CREATE OR REPLACE VIEW V3 AS
SELECT e.empno, e.ename, e.job, e.sal, e.deptno, d.dname, d.loc
FROM emp e
JOIN dept d ON e.deptno = d.deptno;

CREATE OR REPLACE TRIGGER trg_v3_instead_of
INSTEAD OF INSERT OR UPDATE ON V3
FOR EACH ROW
DECLARE
    v_dept_cnt NUMBER;
    v_emp_cnt  NUMBER;
BEGIN
    -- Check if DEPTNO exists in DEPT table
    SELECT COUNT(*) INTO v_dept_cnt FROM dept WHERE deptno = :NEW.deptno;

    IF v_dept_cnt = 0 THEN
        INSERT INTO dept (deptno, dname, loc)
        VALUES (:NEW.deptno, :NEW.dname, :NEW.loc);
    ELSE
        UPDATE dept
        SET dname = :NEW.dname, loc = :NEW.loc
        WHERE deptno = :NEW.deptno;
    END IF;

    -- Check if EMPNO exists in EMP table
    SELECT COUNT(*) INTO v_emp_cnt FROM emp WHERE empno = :NEW.empno;

    IF v_emp_cnt = 0 THEN
        INSERT INTO emp (empno, ename, sal, job, deptno)
        VALUES (:NEW.empno, :NEW.ename, :NEW.sal, :NEW.job, :NEW.deptno);
    ELSE
        UPDATE emp
        SET ename  = :NEW.ename,
            sal    = :NEW.sal,
            job    = :NEW.job,
            deptno = :NEW.deptno
        WHERE empno = :NEW.empno;
    END IF;
END;
/


-- 4. Write a SYSTEM trigger to restrict SCOTT user from creating non-TABLE objects using ORA_DICT_OBJ_TYPE.
CREATE OR REPLACE TRIGGER trg_restrict_create_type
BEFORE CREATE ON SCHEMA
BEGIN
    IF ORA_DICT_OBJ_TYPE != 'TABLE' THEN
        RAISE_APPLICATION_ERROR(-20002, 'User is restricted to creating TABLES only.');
    END IF;
END;
/


-- 5. Create a LOGON trigger that changes default date format to DL format.
CREATE OR REPLACE TRIGGER trg_logon_dl_format
AFTER LOGON ON SCHEMA
BEGIN
    EXECUTE IMMEDIATE 'ALTER SESSION SET NLS_DATE_FORMAT = ''DL''';
END;
/