rem NAME
rem   sqlidtxt.sql
rem FUNCTION
rem   gets info about SQL Texts related to SQL IDs
rem NOTE
rem   start from specified user
rem MODIFIED
rem   31.05.99 SBartsch - made it  
rem

set verify off;
set heading off;
set feedback off;
set trimspool on;

set long 40000;
set maxdata 60000;
set pagesize 2000;
--set linesize 100;
--set pagesize 0;
set line 32000;

clear columns
clear breaks
clear computes

ttitle off
btitle off

column OWNER        format a12
column VIEW_NAME    format a30 
column VIEW_NAME    format 99999 
 
rem spool &TMPDIR.sqlidtxt
prompt
prompt -----------------------------------------------------------;
prompt User SQL View Report
prompt -----------------------------------------------------------;
prompt
accept sqltext  char prompt 'SQL Text like: [] ';
accept filename char prompt 'Spool File:    [] ' default '&TMPDIR.sqlidtxt.lst' ;
prompt
prompt ------------------------------------------------------;
prompt

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
       'User SQL View Report'|| chr(10) ||
       '------------------------------------------------------'|| chr(10) ||
       'Database Name :  &&dbname'|| chr(10) ||
       'User Name     :  '||user||' '|| chr(10) ||
       'Run On        :  '||sysdate||' '|| chr(10) ||
       'SQL Text      :  &&sqltext'|| chr(10) ||
       'Spool File    :  &&filename'|| chr(10) ||
       '------------------------------------------------------'|| chr(10) from dual
/

set feedback on;

column sql_id             new_value var_sql_id       noprint
column last_active_time   new_value var_last_active_time   noprint
column child_number       new_value var_child_number   noprint

column var_sql_id            format a20
column var_last_active_time  format a20
column var_child_number      format 9999

break on sql_id skip 1 -
      on last_active_time skip page on last_active_time 

ttitle left '--------------------------------------' skip 1 -
            'SQL_ID       :  ' var_sql_id            skip 1 -
            'Last Active  :  ' var_last_active_time  skip 1 -
            'Child Number :  ' var_child_number      skip 1 -
            '--------------------------------------' skip 1 -
            '                                      '

select sql_id, child_number, disk_reads, buffer_gets, last_active_time, hash_value, sql_text 
  from v$sql
 where upper(sql_text) like upper('%&&sqltext.%')
   and sql_text not like '%v$sql%'
 order by last_active_time
/
 
spool off;

undefine dbname
undefine sqltext
undefine filename

set heading on;
set long 80;
set maxdata 60000;
set pagesize 22;

clear columns
clear breaks
clear computes

ttitle off
btitle off

rem pause Press <Return> to continue;

rem exit
  
