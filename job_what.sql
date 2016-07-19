/* 
** 
**  NAME
**    jobqueue.sql
**  FUNCTION
**    check DB-Jobs queued via DBMS_JOB package
**  NOTE
**    PL/SQL V2.1
**  MODIFIED
**    04.06.99 sb - made it
** 
*/ 


set verify off;
set heading on;

clear columns
clear breaks
clear computes

ttitle off
btitle off

column job             format 999999
column priv_user       format a12
column last_date       format a10 heading 'LAST_DATE'
column last_sec        format a10 heading 'LAST_SEC'
column this_date       format a10 heading 'THIS_DATE'
column this_sec        format a10 heading 'THIS_SEC'
column next_date       format a10 heading 'NEXT_DATE'
column next_sec        format a10 heading 'NEXT_SEC'
column what            format a25
column interval        format a20
column failures        format 9999
column now             format a20 heading 'Now it is ->'

prompt
prompt -----------------------------------------------------------;
prompt Job Action Report
prompt -----------------------------------------------------------;
prompt
accept action   char prompt 'What Action : [] ';
accept filename char prompt 'Spool File:   [] ' default '&TMPDIR.jobwhat.lst';

spool &&filename

set feedback off;

select to_char(sysdate, 'DD.MM.YYYY HH24:MI:SS') now
  from dual;
set feedback on;

select job
      ,priv_user 
      ,last_date 
   -- ,last_sec 
      ,this_date 
   -- ,this_sec 
      ,next_date 
   -- ,next_sec
      ,what
      ,interval
      ,failures 
  from user_jobs
 where what like upper(nvl('%&&action.%','%'))
/

