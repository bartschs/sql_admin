/* 
** 
**  NAME
**    jobrun.sql
**  FUNCTION
**    call to PL/SQL packages via DBMS_JOB package
**  NOTE
**    PL/SQL V2.1
**  MODIFIED
**    04.06.99 sb - made it
** 
*/ 

--accept  job_no        char   prompt 'Job No ......................... : [] ';
--accept  job_what      char   prompt 'Job What ....................... : [] ';
--accept  job_next      char   prompt 'Job Next (dd.mm.yyyy hh24:mi:ss) : [] ';
--accept  job_interval  char   prompt 'Job Interval ....................: [] ';

set verify off;
set serveroutput on;

declare
-- job_num        binary_integer := to_number('job_no');
-- job_what       varchar2(60) := 'job_what';
-- job_date       date := to_date('job_what', 'dd.mm.yyyy hh24:mi:ss');
-- job_interval   varchar2(60) := 'job_interval';
   job_num        binary_integer := to_number('86');
   job_what       varchar2(60) := 'RPL$PA_REPLICATOR.REFRESH_GROUP(''REFRESH_STATIC'');';
-- job_date       date := to_date('29.11.2007 16:58:28', 'dd.mm.yyyy hh24:mi:ss');
   job_date       date := to_date('04.12.2007 01:00:00', 'dd.mm.yyyy hh24:mi:ss');
-- job_interval   varchar2(60) := 'SYSDATE+(5/1440)';
   job_interval   varchar2(60) := 'TRUNC(SYSDATE+1)+(1.0000/24)';
begin
   dbms_job.change( job => job_num, what => job_what, next_date => job_date, interval => job_interval);
end;
/

commit;
