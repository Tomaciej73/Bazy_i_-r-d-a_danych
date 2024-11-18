DECLARE
    -- Zmienna przechowująca maksymalny numer departamentu
    numer_max departments.department_id%TYPE;
    -- Zmienna przechowująca nazwę nowego departamentu
    nowy_departament departments.department_name%TYPE := 'EDUCATION';
BEGIN
    -- Część 1: Wyszukiwanie maksymalnego numeru departamentu
    SELECT MAX(department_id) INTO numer_max FROM departments;

    -- Dodanie nowego departamentu z numerem o 10 większym
    INSERT INTO departments (department_id, department_name, location_id)
    VALUES (numer_max + 10, nowy_departament, NULL);  -- location_id będzie ustawione później

    -- Część 2: Zmiana location_id na 3000 dla nowo dodanego departamentu
    UPDATE departments
    SET location_id = 3000
    WHERE department_id = numer_max + 10;

    -- Część 3: Tworzenie tabeli 'nowa'
    EXECUTE IMMEDIATE 'CREATE TABLE nowa (liczba VARCHAR2(10))';

    -- Pętla do wstawiania liczb od 1 do 10, z wyjątkiem 4 i 6
    FOR i IN 1..10 LOOP
        IF i != 4 AND i != 6 THEN
            INSERT INTO nowa (liczba) VALUES (TO_CHAR(i));
        END IF;
    END LOOP;

    -- Zatwierdzenie transakcji
    COMMIT;
END;
/
DECLARE
    -- Zmienna do przechowywania informacji o kraju
    country_info countries%ROWTYPE;
BEGIN
    -- Pobranie informacji o kraju o identyfikatorze 'CA' z tabeli 'countries'
    SELECT * INTO country_info FROM countries WHERE country_id = 'CA';
    
    -- Wypisanie nazwy i region_id na ekran
    DBMS_OUTPUT.PUT_LINE('Nazwa kraju: ' || country_info.country_name);
    DBMS_OUTPUT.PUT_LINE('Region ID: ' || country_info.region_id);
END;
/
DECLARE
    -- Kursor dla wynagrodzenia i nazwiska dla departamentu 50
    CURSOR salary_cursor IS
        SELECT last_name, salary
        FROM employees
        WHERE department_id = 50;
    
    -- Zmienna do przechowywania danych z kursora
    emp_record salary_cursor%ROWTYPE;
BEGIN
    -- Otwarcie kursora
    OPEN salary_cursor;
    
    -- Pętla do przetwarzania wyników kursora
    LOOP
        FETCH salary_cursor INTO emp_record;
        EXIT WHEN salary_cursor%NOTFOUND;  -- Zakończenie pętli po przetworzeniu wszystkich wierszy
        
        -- Sprawdzanie warunku wynagrodzenia
        IF emp_record.salary > 3100 THEN
            DBMS_OUTPUT.PUT_LINE(emp_record.last_name || ' - nie dawać podwyżki');
        ELSE
            DBMS_OUTPUT.PUT_LINE(emp_record.last_name || ' - dać podwyżkę');
        END IF;
    END LOOP;
    
    -- Zamknięcie kursora
    CLOSE salary_cursor;
END;
/
DECLARE
    -- Kursor z parametrami
    CURSOR salary_name_cursor(p_min_salary IN NUMBER, p_max_salary IN NUMBER, p_name_part IN VARCHAR2) IS
        SELECT first_name, last_name, salary
        FROM employees
        WHERE salary BETWEEN p_min_salary AND p_max_salary
        AND UPPER(first_name) LIKE UPPER(p_name_part || '%');
    
    -- Zmienna do przechowywania danych z kursora
    emp_record salary_name_cursor%ROWTYPE;
BEGIN
    -- Przykład 1: Pracownicy z widełkami 1000 - 5000 i częścią imienia 'a' (lub 'A')
    OPEN salary_name_cursor(1000, 5000, 'a');
    LOOP
        FETCH salary_name_cursor INTO emp_record;
        EXIT WHEN salary_name_cursor%NOTFOUND;
        
        DBMS_OUTPUT.PUT_LINE(emp_record.first_name || ' ' || emp_record.last_name || ' - Salary: ' || emp_record.salary);
    END LOOP;
    CLOSE salary_name_cursor;
    
    -- Przykład 2: Pracownicy z widełkami 5000 - 20000 i częścią imienia 'u' (lub 'U')
    OPEN salary_name_cursor(5000, 20000, 'u');
    LOOP
        FETCH salary_name_cursor INTO emp_record;
        EXIT WHEN salary_name_cursor%NOTFOUND;
        
        DBMS_OUTPUT.PUT_LINE(emp_record.first_name || ' ' || emp_record.last_name || ' - Salary: ' || emp_record.salary);
    END LOOP;
    CLOSE salary_name_cursor;
END;
/
CREATE OR REPLACE PROCEDURE add_job(
    p_job_id IN VARCHAR2, 
    p_job_title IN VARCHAR2
) AS
BEGIN
    -- Dodanie nowego wiersza do tabeli Jobs
    INSERT INTO jobs (job_id, job_title)
    VALUES (p_job_id, p_job_title);

    -- Potwierdzenie operacji
    COMMIT;
    
    DBMS_OUTPUT.PUT_LINE('Job added successfully: ' || p_job_id || ' - ' || p_job_title);
    
EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN
        DBMS_OUTPUT.PUT_LINE('Error: Duplicate Job_id, job already exists.');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
        ROLLBACK;
END add_job;
/
CREATE OR REPLACE PROCEDURE update_job_title(
    p_job_id IN VARCHAR2, 
    p_new_job_title IN VARCHAR2
) AS
    rows_updated INTEGER;
BEGIN
    -- Modyfikacja Job_title dla podanego Job_id
    UPDATE jobs
    SET job_title = p_new_job_title
    WHERE job_id = p_job_id;

    -- Sprawdzanie liczby zaktualizowanych wierszy
    rows_updated := SQL%ROWCOUNT;

    IF rows_updated = 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'No Jobs updated for Job_id ' || p_job_id);
    ELSE
        COMMIT;
        DBMS_OUTPUT.PUT_LINE('Job updated successfully: ' || p_job_id || ' - ' || p_new_job_title);
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
        ROLLBACK;
END update_job_title;
/
CREATE OR REPLACE PROCEDURE delete_job(
    p_job_id IN VARCHAR2
) AS
    rows_deleted INTEGER;
BEGIN
    -- Usuwanie wiersza z tabeli Jobs
    DELETE FROM jobs
    WHERE job_id = p_job_id;

    -- Sprawdzanie liczby usuniętych wierszy
    rows_deleted := SQL%ROWCOUNT;

    IF rows_deleted = 0 THEN
        RAISE_APPLICATION_ERROR(-20002, 'No Jobs deleted for Job_id ' || p_job_id);
    ELSE
        COMMIT;
        DBMS_OUTPUT.PUT_LINE('Job deleted successfully: ' || p_job_id);
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
        ROLLBACK;
END delete_job;
/
CREATE OR REPLACE PROCEDURE get_employee_salary(
    p_employee_id IN NUMBER, 
    p_salary OUT NUMBER, 
    p_last_name OUT VARCHAR2
) AS
BEGIN
    -- Pobieranie wynagrodzenia i nazwiska z tabeli employees
    SELECT salary, last_name
    INTO p_salary, p_last_name
    FROM employees
    WHERE employee_id = p_employee_id;

    DBMS_OUTPUT.PUT_LINE('Employee: ' || p_last_name || ', Salary: ' || p_salary);

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Error: No employee found with ID ' || p_employee_id);
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
END get_employee_salary;
/
CREATE OR REPLACE PROCEDURE add_employee(
    p_first_name IN VARCHAR2, 
    p_last_name IN VARCHAR2, 
    p_salary IN NUMBER
) AS
    v_employee_id NUMBER;
BEGIN
    -- Sprawdzanie, czy wynagrodzenie jest wyższe niż 20000
    IF p_salary > 20000 THEN
        RAISE_APPLICATION_ERROR(-20003, 'Salary cannot exceed 20000.');
    END IF;

    -- Dodanie nowego pracownika do tabeli employees
    INSERT INTO employees (employee_id, first_name, last_name, salary, hire_date, job_id)
    VALUES (employees_seq.NEXTVAL, p_first_name, p_last_name, p_salary, SYSDATE, 'IT_PROG');  -- Przykład z domyślnym job_id

    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Employee added successfully: ' || p_first_name || ' ' || p_last_name || ', Salary: ' || p_salary);

EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
        ROLLBACK;
END add_employee;
/
EXEC add_job('SA_REP', 'Sales Representative');
EXEC update_job_title('SA_REP', 'Senior Sales Representative');
EXEC delete_job('SA_REP');
DECLARE
    v_salary NUMBER;
    v_last_name VARCHAR2(100);
BEGIN
    EXEC get_employee_salary(100, v_salary, v_last_name);
    DBMS_OUTPUT.PUT_LINE('Salary: ' || v_salary || ', Last Name: ' || v_last_name);
END;
EXEC add_employee('John', 'Doe', 15000);
