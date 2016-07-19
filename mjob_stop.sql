/* 
** 
**  NAME
**    mjob_stop.sql
**  FUNCTION
**    call to PL/SQL packages via DBMS_JOB package
**  NOTE
**    PL/SQL V2.1
**  MODIFIED
**    30.06.99 sb - made it
** 
*/ 

--accept  job_no      char   prompt 'Stop Job No : [] ';

set verify off;
set serveroutput on;

DECLARE
   --job_num   binary_integer := to_number('job_no');
   start_flag  BOOLEAN;
   what_name   VARCHAR2(255);
 
 CURSOR c_job (
   i_what VARCHAR2
 )
 IS
  select job
     from user_jobs
    where what like i_what || ';';

BEGIN
   what_name := UPPER('rpl$pa_replicator%');

   -- FALSE = start JOB 
   -- TRUE  = stop  JOB 

   start_flag := TRUE;

   FOR cloop in c_job(what_name) LOOP

      DBMS_OUTPUT.PUT_LINE('Stop Job_Nummer -> ' || cloop.job);
      DBMS_JOB.BROKEN( cloop.job, start_flag, SYSDATE );

   END LOOP;

EXCEPTION
   WHEN OTHERS THEN
      dbms_output.put_line('ERROR: ' || SQLERRM(SQLCODE) );
END;
/

commit;
