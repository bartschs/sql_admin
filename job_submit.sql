/* 
** 
**  NAME
**    jobsubmit.sql
**  FUNCTION
**    call to PL/SQL packages via DBMS_JOB package
**  NOTE
**    PL/SQL V2.1
**  MODIFIED
**    04.06.99 sb - made it
** 
*/ 


set verify off;
set serveroutput on;

declare
   job_num   binary_integer;
begin
   dbms_job.submit(job_num, 'rpl$PA_replicator.job;', 
   		   sysdate + (15*60)/(60*60*24), 'sysdate + (15*60)/(60*60*24)', false);
end;
/

commit;
