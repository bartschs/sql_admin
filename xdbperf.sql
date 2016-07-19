rem NAME
rem   dbperf.sql
rem FUNCTION
rem   Check DB Performance
rem NOTE
rem   start from user with execute grant 
rem MODIFIED
rem   28.10.99 SBartsch - made it
rem

set serveroutput on size 1000000 format wrapped;
set verify off; 
set feedback off; 
set trimspool on;
set heading off;

set long 20000;
set maxdata 60000;
set pagesize 2000;

clear columns
clear breaks
clear computes

ttitle off
btitle off

prompt -----------------------------------------------------------;
prompt DB Performance Check Report
prompt -----------------------------------------------------------;
accept filename char prompt 'Spool to <File> [] : ' default '&TMPDIR.dbperf.lst';

rem
rem get current DB Name
rem

set termout off
define dbname=xxx
column currname new_value dbname
select global_name currname from global_name;
set termout on

spool &&filename

select '------------------------------------------------------'|| chr(10) ||
       'DB Performance Check Report'|| chr(10) ||
       '------------------------------------------------------'|| chr(10) ||
       'Database Name      : &&dbname'|| chr(10) ||
       'User Name          : '||user||' '|| chr(10) ||
       'Run At             : '||sysdate||' '|| chr(10) ||
       'Spool File         : &&filename'|| chr(10) ||
       '------------------------------------------------------'|| chr(10) from dual
/

DECLARE

   TYPE db_result IS RECORD (
            elapsed  NUMBER,
            warning  VARCHAR2(1998)   
        );

   l_run_time DB_RESULT;
 
   l_cycle number := 0;
 
   ------------------------------------
   PROCEDURE init (
      io_result  IN OUT db_result
   )
   IS
   BEGIN
      io_result.elapsed := DBMS_UTILITY.GET_TIME;
   END; -- init
 
   ------------------------------------
   PROCEDURE done (
      io_result  IN OUT db_result
   )
   IS
   BEGIN
      -- io_result.elapsed := ROUND((DBMS_UTILITY.GET_TIME - io_result.elapsed)/100, 2);
      --------
      -- ELAPSED wird ab Carmen 7.0 nicht mehr als Anzahl Sekunden mit 2 Nachkommastellen
      -- zurueckgegeben, sondern als ganzzahliger Wert in Hunderdstel Sekunden. Der ROUND
      -- wird ueberfluessig, weil DBMS_UTILITY.GET_TIME 1/100 sec Genauigkeit hat.
      -- (2004-02-09 M.Friemel)
      --------
      io_result.elapsed := DBMS_UTILITY.GET_TIME - io_result.elapsed;
   END; -- done

BEGIN
   dbms_output.put_line('--------------------------');
   dbms_output.put_line('DB Performance Check');
   init(l_run_time);
   --
   WHILE l_cycle < 2000000 LOOP
      l_cycle := l_cycle + 1;
   END LOOP;
   --
   done(l_run_time);
   l_run_time.elapsed   := ROUND(l_run_time.elapsed/100, 2);
   --
   dbms_output.put_line('--------------------------');
   dbms_output.put_line('Run Time: ' || to_char(l_run_time.elapsed) || ' sec');
   dbms_output.put_line('--------- ================');
END;
/

prompt;

undefine filename

spool off;
