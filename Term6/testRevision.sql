--Examples
SET SERVEROUT ON
--Napisz program wyswietlajacy imie i nazwisko pracownika z dzialu 60. 
--Bez kursorow (wykorzystaj select ...into). Obsluz bledy.

declare
 v_imie pracownicy_jw.first_name%TYPE;
 v_nazwisko pracownicy_jw.last_name%TYPE;
begin
 select first_name, last_name into v_imie, v_nazwisko from pracownicy_jw where department_id=4000;
 dbms_output.put_line(v_imie||' '||v_nazwisko);
exception
 when NO_DATA_FOUND then dbms_output.put_line('Brak pracownik�w w dziale.'); --raise_application_error(-20001,'Brak pracownik�w w dziale 60.' );
 when TOO_MANY_ROWS then dbms_output.put_line('Wi�cej ni� jeden pracownik w dziale.');--raise_application_error(-20002,'Wi�cej ni� jeden pracownik w dziale 60.' );
 when OTHERS then dbms_output.put_line('Wystapil inny blad.'); --raise_application_error(-20003,'Wystapil inny blad.' );
end;

--1
declare
    cursor cur_man is
        select employee_id, salary from pracownicykm where job_id like '%MAN' for update;
    v_salary number(10,2);
begin
    for v_man in cur_man loop
        select sum(salary) into v_salary from pracownicykm
        where manager_id=v_man.employee_id;
        if v_salary*0.1+v_man.salary > 15000 then
            raise_application_error(-20009,'Salary too high');
        else
            update pracownicykm set salary=salary+v_salary*0.1 where current of cur_man;
        end if;
    end loop;
end;
--2 bez EXCEPTION
declare
 cursor cur_prac(p_etat varchar2) is   --kursor z parametrem p_etat
 select last_name from pracownicy_jw where job_id=p_etat;
 v_etat pracownicy_jw.job_id%TYPE :='&id_etatu';
 brak_pracownikow boolean :=true;  --sprawdza czy petla for z kursorem sie wykona
begin
 for r_prac in cur_prac(v_etat) 
  loop
    dbms_output.put_line(r_prac.last_name);
    brak_pracownikow :=false;
  end loop; 
if brak_pracownikow then dbms_output.put_line('Brak pracownika na etacie.'); --raise_application_error(-20002,'Brak pracownika na etacie.' );
end if;
end;
--
declare
 cursor cur_prac(p_etat varchar2) is   --kursor z parametrem p_etat
 select last_name from pracownicy_jw where job_id=p_etat;
 v_etat pracownicy_jw.job_id%TYPE :='&id_etatu';

 e_brak_prac EXCEPTION;
 PRAGMA exception_init(e_brak_prac, -20001);
 
 v_ile number;

begin
select count(*) into v_ile from pracownicy_jw where job_id=v_etat;
if v_ile=0 
then raise e_brak_prac;
else
for r_prac in cur_prac(v_etat) 
  loop
    dbms_output.put_line(r_prac.last_name);
  end loop;  
end if;
exception
   when e_brak_prac THEN
        dbms_output.put_line('Brak pracownikow na etacie ' || v_etat);
end;
--4   --kursory niejawne
declare
  e_brak_wynikow EXCEPTION;  --deklaracja wyjatku(bledu) uzytkownika
  v_rok number(4):=2000;
begin
 delete from pracownicy_jw where to_char(hire_date, 'YYYY')< v_rok;
 if SQL%ROWCOUNT=0 then raise e_brak_wynikow;
 end if;
exception
  when e_brak_wynikow then dbms_output.put_line('Brak pracownikow zatrudnionych poni�ej danego roku'); --raise_application_error(-20002,'Brak pracownikow zatrudnionych poni�ej danego roku.' );
end;

--inny sposob
declare
  v_rok number(4):=2000;
begin
 delete from pracownicy_jw where to_char(hire_date, 'YYYY')< v_rok;
 if SQL%FOUND 
 then dbms_output.put_line('Usunietych rekord�w: '||SQL%ROWCOUNT); 
 else raise_application_error(-20002,'Brak rekordow do usuniecia.' ); 
 end if;
end;
/
SET SERVEROUTPUT ON;
DECLARE
    CURSOR prog_cursor IS
        SELECT first_name, last_name, hire_date
        FROM hr.employees
        WHERE job_id = 'IT_PROG';
    
    c_prog prog_cursor%ROWTYPE;
BEGIN
    OPEN prog_cursor;
    
    LOOP
        FETCH prog_cursor INTO c_prog;
        EXIT WHEN prog_cursor%ROWCOUNT > 5 OR prog_cursor%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE(c_prog.first_name || ' ' || c_prog.last_name || ' ' || c_prog.hire_date);
    END LOOP;
    
    CLOSE prog_cursor;
END;
/
Declare
    cursor c_best_paid IS
    Select first_name, last_name, salary from hr.employees 
    order by salary desc;
    
    best_paid c_best_paid%ROWTYPE;
BEGIN
    OPEN c_best_paid;
    LOOP
    FETCH c_best_paid INTO best_paid;
    EXIT WHEN c_best_paid%ROWCOUNT > 5 OR c_best_paid%NOTFOUND;
    DBMS_OUTPUT.PUT_LINE('imie '||best_paid.first_name||' nazwisko '||best_paid.last_name||' pensja '||best_paid.salary);
END LOOP;
close c_best_paid;
END;
/
declare
 n number;
 potega number :=1;
begin
 n:= &n;
 for i in 1..n loop
  potega := potega * 3;
  end loop;
  dbms_output.put_line(potega);
  end;
  /
declare 
cursor cur_p is
select job_id from pracownicy_am;
begin
for v_prac in cur_p
loop
if v_prac.job_id = 'IT_PROG' then
update pracownicy_am set salary = salary + 100;
elsif v_prac.job_id like '%MAN%' then update pracownicy_am 
set salary=salary*1.1;
end if;
end loop;
end;
/
--8
declare
cursor c is
select employee_id, first_name, last_name
from pracownicy_am
where to_char(hire_date,'yyyy')<2003;
r_pracownicy c%ROWTYPE;
v_count number;
begin
select count(*) into v_count
from pracownicy_am 
where to_char(hire_date,'YYYY') <2003;
dbms_output.put_line('usunietych '||v_count);
open c;
loop
fetch c into r_pracownicy;
exit when c%NOTFOUND;
dbms_output.put_line(r_pracownicy.employee_id||r_pracownicy.first_name
||r_pracownicy.last_name);
end loop;
close c;
delete from pracownicy_am where to_char(hire_date,
'YYYY')<2003;
end;
/
--
CREATE TABLE departamenty_am AS
SELECT * 
FROM hr.departments;
drop table pracownicy_am;
CREATE TABLE pracownicy_am AS
SELECT * 
FROM hr.employees;
--7
declare
cursor c is
select count(employee_id) as liczba, department_name
from pracownicy_am join departamenty_am 
using(department_id)
group by department_name;
r_p c%ROWTYPE;
v_c number;
begin
 open c;
 loop
    fetch c into r_p;
    exit when c%NOTFOUND;
    dbms_output.put_line('w dep'||r_p.department_name
    ||' pracuje '||r_p.liczba);
 end loop;
 close c;
end; 
/
select * from pracownicy_am;
/
set serveroutput on;

declare
cursor c is
select count(employee_id) as liczba , department_name 
from pracownicy_am join departamenty_am 
using (department_id)
group by department_name;
r_p c%ROWTYPE;
begin
open c;
loop
fetch c into r_p;
dbms_output.put_line('w depratamencie '||r_p.department_name||' pracuje '
||r_p.liczba);
exit when c%NOTFOUND;
end loop;
close c;
end;
/

declare
cursor c is
select employee_id, first_name, last_name from
pracownicy_am where to_char(hire_date,'yyyy')<2003; 
r_p c%ROWTYPE;
begin
loop
fetch c into r_p;
exit when c%NOTFOUND;
end loop;
close c;
delete from pracownicy_am where to_char(hire_date,'yyyy')<2003;
end;
/

set serveroutput on;
declare
cursor c is
select employee_id, first_name, last_name
from pracownicy_am
where to_char(hire_date,'yyyy')<2003;
r_p c%ROWTYPE;
liczba number;
begin
select count(*) into liczba from pracownicy_am where
to_char(hire_date,'yyyy')<2003;
dbms_output.put_line('usunietych '||liczba);
open c;
loop
fetch c into r_p;
exit when c%NOTFOUND;
dbms_output.put_line(r_p.employee_id||r_p.first_name
||r_p.last_name);
end loop;

close c;
delete from pracownicy_am where to_char(hire_date,
'YYYY')<2003;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('No records found.');
end;
/
select * from pracownicy_am;
DECLARE
v_id pracownicy_am.job_id%TYPE;
    v_bonus NUMBER;
   
BEGIN
     CURSOR c IS
        SELECT first_name, last_name, commission_pct, job_id
        FROM pracownicy_am
        WHERE job_id = v_id;
r_p c%ROWTYPE;
    v_id := UPPER('&job_id');
    open c;
    loop
    fetch c into r_p;
        IF r_p.commission_pct IS NOT NULL THEN
            v_bonus := r_employee.commission_pct * 100;
            DBMS_OUTPUT.PUT_LINE('Pracownik ' || r_employee.first_name || ' ' || r_employee.last_name || ' posiada premi? w wysoko?ci ' || v_bonus || '%');
        ELSE
            DBMS_OUTPUT.PUT_LINE('Pracownik ' || r_employee.first_name || ' ' || r_employee.last_name || ' nie posiada premii');
        END IF;
    END LOOP;
    close c;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Brak pracownik�w dla stanowiska!');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Wyst?pi? inny b??d!');
END;
/
--5
SET SERVEROUTPUT ON
DECLARE
    v_id pracownicy_am.job_id%TYPE;
    v_bonus pracownicy_am.commission_pct%TYPE;    
    CURSOR c IS
        SELECT *
        FROM pracownicy_am
        WHERE job_id = v_id;
    r_p pracownicy_am%ROWTYPE;
BEGIN
    v_id := UPPER('&job_id');
    OPEN c;
    LOOP
        FETCH c INTO r_p;
        EXIT WHEN c%NOTFOUND;
        IF r_p.commission_pct IS NOT NULL THEN
            v_bonus := r_p.commission_pct * 100;
            DBMS_OUTPUT.PUT_LINE('Pracownik ' || r_p.first_name
            || ' ' || r_p.last_name || ' posiada premi? w wysoko?ci ' || v_bonus || '%');
        ELSE
            DBMS_OUTPUT.PUT_LINE('Pracownik ' || r_p.first_name
            || ' ' || r_p.last_name || ' nie posiada premii');
        END IF;
    END LOOP;
    CLOSE c;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Brak pracownik�w dla stanowiska!');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Wyst?pi? inny b??d!');
END;
/
SET SERVEROUTPUT ON;
declare 
cursor c is
select first_name, last_name, hire_date
from pracownicy_am where job_id like 'IT_PROG';
r_p c%ROWTYPE;
begin
open c;
loop
fetch c into r_p;
exit when c%NOTFOUND;
dbms_output.put_line(r_p.first_name||' '||
r_p.last_name||' '||
r_p.hire_date);
end loop;
close c;
end;
/
select * from pracownicy_am;
/
declare
cursor c is
select first_name, last_name, salary from
pracownicy_am order by salary desc;
r_p c%ROWTYPE;
begin
open c;
loop
fetch c into r_p;
dbms_output.put_line(r_p.first_name||' '
||r_p.last_name||' '||r_p.salary);
exit when c%ROWCOUNT > 5;
end loop;
close c;
end;
/
declare 
n number;
potega number := 1;
begin
n := &n;
for i in 1..n loop
potega := potega * 3;
dbms_output.put_line(potega);
end loop;
end;
/
--4
declare 
cursor c is
select first_name, last_name, salary 
from pracownicy_am where job_id = 'IT_PROG';
r_p c%ROWTYPE;
begin
update pracownicy_am 
set salary = salary+100 
where job_id = 'IT_PROG';
open c;
loop
fetch c into r_p;
exit when c%NOTFOUND;
dbms_output.put_line('Po zmianie :' ||r_p.first_name||
' '||r_p.last_name||' '|| r_p.salary);
end loop;
close c;
end;
/
--5
declare 
v_l char(1);
cursor c is
select FIRST_name, last_name, job_id
from pracownicy_am WHERE 
UPPER(SUBSTR(last_name, 1, 1)) = UPPER(v_l);
r_p c%ROWTYPE;
begin
 v_l := UPPER(SUBSTR('&Podaj_litere_nazwiska_pracownika', 1, 1));
 open c;
 loop
 fetch c into r_p;
DBMS_OUTPUT.PUT_LINE(r_p.last_name || ' ' ||
                     r_p.first_name || ' ' ||
                     r_p.job_id);
exit when c%NOTFOUND;
end loop;
close c;
end;
/
create table pracownicy_am as 
select * from hr.employees;
set serveroutput on;
drop table pracownicy_am;
select * from pracownicy_am;
select * from hr.departments;
--4
declare
cursor c is
select employee_id, first_name, last_name, job_id
from pracownicy_am where to_char(hire_date,'yyyy')<2003;
r_p c%ROWTYPE;
v_l number;
begin
select count(*)
into v_l
from pracownicy_am 
where to_char(hire_date,'yyyy')<2003;
dbms_output.put_line('usunietych '||v_l);
open c;
loop
fetch c into r_p;
exit when c%NOTFOUND;
dbms_output.put_line('Usunieci: '||r_p.first_name||' '||r_p.last_name||' '
||r_p.job_id);
end loop;
close c;
delete from pracownicy_am where to_char(hire_date,'yyyy')<2003;
EXCEPTION
When NO_DATA_FOUND
then dbms_output.put_line('Brak pracownik�w ');
end;
/
--5
declare
v_job pracownicy_am.job_id%TYPE;
cursor c is
select first_name, last_name, commission_pct
from pracownicy_am where job_id = v_job;
r_p c%ROWTYPE;
begin
v_job := UPPER('&job_id');
open c;
loop
fetch c into r_p;
exit when c%NOTFOUND;
if r_p.commission_pct is not null then 
dbms_output.put_line('pracownik '||r_p.first_name||' '||r_p.last_name||
' posiada premie '||r_p.commission_pct);
else
dbms_output.put_line('pracownik '||r_p.first_name||' '||r_p.last_name||
' nie posiada premii '||r_p.commission_pct);
end if;
end loop;
close c;
end;
/
--6
declare 
v_d number;
cursor c is
select first_name, last_name, salary, department_id 
from pracownicy_am where department_id = v_d;
r_p c%ROWTYPE;
begin
v_d := TO_NUMBER('&department_id');
open c;
loop
fetch c into r_p;
exit when c%NOTFOUND;
dbms_output.put_line('Przed podywzka '||r_p.first_name||' '||r_p.last_name||
' '||r_p.salary||' '||r_p.department_id);
update pracownicy_am 
set commission_pct = commission_pct + 0.5
where department_id = v_d;
dbms_output.put_line('Po podwyzce '||r_p.first_name||' '||r_p.last_name||
' '||r_p.salary||' '||r_p.department_id);
end loop;
close c;
EXCEPTION
    WHEN VALUE_ERROR THEN
        DBMS_OUTPUT.PUT_LINE('Bledny numer departamentu!');

    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Wystapil inny blad!');
end;
/
select * from pracownicy_am where department_id = 60;










