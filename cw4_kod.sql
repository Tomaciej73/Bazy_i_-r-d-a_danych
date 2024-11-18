CREATE OR REPLACE FUNCTION get_job_name(p_job_id IN VARCHAR2) 
RETURN VARCHAR2 IS
    v_job_title VARCHAR2(255);
BEGIN
    SELECT job_title
    INTO v_job_title
    FROM jobs
    WHERE job_id = p_job_id;
    
    RETURN v_job_title;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20001, 'Job with ID ' || p_job_id || ' does not exist.');
    WHEN OTHERS THEN
        RAISE;
END get_job_name;
/
CREATE OR REPLACE FUNCTION get_annual_salary(p_employee_id IN NUMBER) 
RETURN NUMBER IS
    v_salary NUMBER;
    v_commission_pct NUMBER;
    v_annual_salary NUMBER;
BEGIN
    SELECT salary, commission_pct
    INTO v_salary, v_commission_pct
    FROM employees
    WHERE employee_id = p_employee_id;

    IF v_commission_pct IS NULL THEN
        v_commission_pct := 0;
    END IF;

    v_annual_salary := (v_salary * 12) + (v_salary * v_commission_pct);
    
    RETURN v_annual_salary;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20002, 'Employee with ID ' || p_employee_id || ' not found.');
    WHEN OTHERS THEN
        RAISE;
END get_annual_salary;
/
CREATE OR REPLACE FUNCTION get_country_code(p_phone_number IN VARCHAR2) 
RETURN VARCHAR2 IS
    v_country_code VARCHAR2(10);
BEGIN
    v_country_code := REGEXP_SUBSTR(p_phone_number, '^\+(\d+)');

    IF v_country_code IS NULL THEN
        RAISE_APPLICATION_ERROR(-20003, 'Invalid phone number format');
    END IF;

    RETURN v_country_code;
EXCEPTION
    WHEN OTHERS THEN
        RAISE;
END get_country_code;
/
CREATE OR REPLACE FUNCTION format_case(p_input_string IN VARCHAR2) 
RETURN VARCHAR2 IS
    v_result VARCHAR2(255);
BEGIN
    IF LENGTH(p_input_string) > 1 THEN
        v_result := UPPER(SUBSTR(p_input_string, 1, 1)) || 
                    LOWER(SUBSTR(p_input_string, 2, LENGTH(p_input_string) - 2)) ||
                    UPPER(SUBSTR(p_input_string, LENGTH(p_input_string), 1));
    ELSE
        v_result := UPPER(p_input_string);
    END IF;

    RETURN v_result;
EXCEPTION
    WHEN OTHERS THEN
        RAISE;
END format_case;
/
CREATE OR REPLACE FUNCTION get_birthdate_from_pesel(p_pesel IN VARCHAR2) 
RETURN DATE IS
    v_birthdate DATE;
BEGIN
    v_birthdate := TO_DATE('19' || SUBSTR(p_pesel, 1, 2) || '-' || 
                            SUBSTR(p_pesel, 3, 2) || '-' || 
                            SUBSTR(p_pesel, 5, 2), 'YYYY-MM-DD');
    
    RETURN v_birthdate;
EXCEPTION
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20004, 'Invalid PESEL format');
END get_birthdate_from_pesel;
/
CREATE OR REPLACE FUNCTION get_employee_and_department_count(p_country_name IN VARCHAR2) 
RETURN VARCHAR2 IS
    v_employee_count NUMBER;
    v_department_count NUMBER;
BEGIN
    SELECT COUNT(*)
    INTO v_employee_count
    FROM employees e
    JOIN departments d ON e.department_id = d.department_id
    JOIN locations l ON d.location_id = l.location_id
    JOIN countries c ON l.country_id = c.country_id
    WHERE c.country_name = p_country_name;

    SELECT COUNT(*)
    INTO v_department_count
    FROM departments d
    JOIN locations l ON d.location_id = l.location_id
    JOIN countries c ON l.country_id = c.country_id
    WHERE c.country_name = p_country_name;

    RETURN 'Employees: ' || v_employee_count || ', Departments: ' || v_department_count;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20005, 'Country not found: ' || p_country_name);
    WHEN OTHERS THEN
        RAISE;
END get_employee_and_department_count;
/
-- WYZWALACZE
CREATE OR REPLACE TRIGGER trg_archive_department
AFTER DELETE ON departments
FOR EACH ROW
BEGIN
    INSERT INTO archive_departments (id, department_name, closure_date, last_manager)
    VALUES (:OLD.department_id, :OLD.department_name, SYSDATE, 
            (SELECT first_name || ' ' || last_name 
             FROM employees 
             WHERE employee_id = :OLD.manager_id));
END;
/
CREATE OR REPLACE TRIGGER trg_check_salary
BEFORE INSERT OR UPDATE ON employees
FOR EACH ROW
BEGIN
    IF :NEW.salary < 2000 OR :NEW.salary > 26000 THEN
        RAISE_APPLICATION_ERROR(-20006, 'Salary must be between 2000 and 26000.');
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        INSERT INTO złodziej (id, user, czas_zmiany)
        VALUES (:NEW.employee_id, USER, SYSDATE);
END;
/
CREATE SEQUENCE employee_seq START WITH 1 INCREMENT BY 1;

CREATE OR REPLACE TRIGGER trg_auto_increment_employee
BEFORE INSERT ON employees
FOR EACH ROW
BEGIN
    SELECT employee_seq.NEXTVAL INTO :NEW.employee_id FROM dual;
END;
/
CREATE OR REPLACE TRIGGER trg_block_job_grades_operations
BEFORE INSERT OR UPDATE OR DELETE ON job_grades
FOR EACH ROW
BEGIN
    RAISE_APPLICATION_ERROR(-20007, 'Operations on JOB_GRADES are not allowed.');
END;
/
CREATE OR REPLACE TRIGGER trg_block_salary_changes
BEFORE UPDATE ON jobs
FOR EACH ROW
BEGIN
    IF :NEW.min_salary <> :OLD.min_salary OR :NEW.max_salary <> :OLD.max_salary THEN
        :NEW.min_salary := :OLD.min_salary;
        :NEW.max_salary := :OLD.max_salary;
    END IF;
END;
/
-- PAKIETY
CREATE OR REPLACE PACKAGE regions_pkg AS
    PROCEDURE add_region(p_region_name IN VARCHAR2);
    PROCEDURE update_region(p_region_id IN NUMBER, p_new_region_name IN VARCHAR2);
    PROCEDURE delete_region(p_region_id IN NUMBER);
    FUNCTION get_region_name(p_region_id IN NUMBER) RETURN VARCHAR2;
    FUNCTION get_all_regions RETURN SYS_REFCURSOR;
END regions_pkg;
/

CREATE OR REPLACE PACKAGE BODY regions_pkg AS
    PROCEDURE add_region(p_region_name IN VARCHAR2) IS
    BEGIN
        IF EXISTS (SELECT 1 FROM regions WHERE region_name = p_region_name) THEN
            RAISE_APPLICATION_ERROR(-20001, 'Region ' || p_region_name || ' already exists.');
        ELSE
            INSERT INTO regions (region_name) VALUES (p_region_name);
            COMMIT;
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            RAISE;
    END add_region;
    PROCEDURE update_region(p_region_id IN NUMBER, p_new_region_name IN VARCHAR2) IS
    BEGIN
        UPDATE regions
        SET region_name = p_new_region_name
        WHERE region_id = p_region_id;

        IF SQL%ROWCOUNT = 0 THEN
            RAISE_APPLICATION_ERROR(-20002, 'Region with ID ' || p_region_id || ' not found.');
        ELSE
            COMMIT;
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            RAISE;
    END update_region;
    PROCEDURE delete_region(p_region_id IN NUMBER) IS
    BEGIN
        DELETE FROM regions WHERE region_id = p_region_id;

        IF SQL%ROWCOUNT = 0 THEN
            RAISE_APPLICATION_ERROR(-20003, 'Region with ID ' || p_region_id || ' not found.');
        ELSE
            COMMIT;
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            RAISE;
    END delete_region;
    FUNCTION get_region_name(p_region_id IN NUMBER) RETURN VARCHAR2 IS
        v_region_name VARCHAR2(255);
    BEGIN
        SELECT region_name
        INTO v_region_name
        FROM regions
        WHERE region_id = p_region_id;

        RETURN v_region_name;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(-20004, 'Region with ID ' || p_region_id || ' not found.');
        WHEN OTHERS THEN
            RAISE;
    END get_region_name;
    FUNCTION get_all_regions RETURN SYS_REFCURSOR IS
        v_cursor SYS_REFCURSOR;
    BEGIN
        OPEN v_cursor FOR
            SELECT region_id, region_name
            FROM regions;
        RETURN v_cursor;
    END get_all_regions;

END regions_pkg;
/

CREATE OR REPLACE PACKAGE BODY regions_pkg AS
    PROCEDURE add_region(p_region_name IN VARCHAR2, p_region_id IN NUMBER) AS
    BEGIN
        INSERT INTO regions (region_id, region_name) VALUES (p_region_id, p_region_name);
        COMMIT;
    END add_region;

   
