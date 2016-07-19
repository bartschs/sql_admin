/* 
** 
**  NAME
**    job_start.sql
**  FUNCTION
**    call to PL/SQL packages via DBMS_JOB package
**  NOTE
**    PL/SQL V2.1
**  MODIFIED
**    30.06.99 sb - made it
** 
*/ 

accept  job_no      char   prompt 'Start Job No : [] ';

set verify off;
set serveroutput on;

DECLARE
   job_num   binary_integer := to_number('&&job_no');
   start_flag  BOOLEAN;
BEGIN
   -- FALSE = start JOB 
   -- TRUE  = stop  JOB 

   start_flag := FALSE;

   DBMS_JOB.BROKEN( job_num, start_flag, SYSDATE );

EXCEPTION
   WHEN OTHERS THEN
      dbms_output.put_line('ERROR: ' || SQLERRM(SQLCODE) );
END;
/

commit;
