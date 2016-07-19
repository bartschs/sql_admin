rem NAME
rem   sqlid.sql
rem FUNCTION
rem   gets info about SQL statement IDs
rem NOTE
rem   start from specified user with Admin priviledge
rem MODIFIED
rem   16.04.10 SBartsch - made it  
rem

set verify off;
set heading off;
set trimspool on;
set feedback off;
set pagesize 2000
set linesize 200 

clear columns
clear breaks
clear computes

ttitle off
btitle off

column SID              format 99999 heading "SID"
column CHILD_NUMBER     format 99999 heading "CHILD"
column SQL_TEXT         format a15   heading "SQL_TEXT"

prompt
prompt -----------------------------------------------------------;
prompt SQL ID Report;
prompt -----------------------------------------------------------;
prompt
accept sid           char prompt 'Oracle SID............... : ' ;
accept sql_text      char prompt 'SQL Text ................ : ' ;
accept filename      char prompt 'Spool to <filename>. .... : ' default '&TMPDIR.sqlid.lst';

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
       'SQL ID Report'|| chr(10) ||
       '------------------------------------------------------'|| chr(10) ||
       'Database Name :  &&dbname'|| chr(10) ||
       'User Name     :  '||user||' '|| chr(10) ||
       'Oracle SID    :  &&sid'|| chr(10) ||
       'Spool File    :  &&filename'|| chr(10) ||
       '------------------------------------------------------'|| chr(10) from dual
/

set heading on;
set feedback on;

select b.sid, a.sql_id, a.child_number, a.disk_reads, a.buffer_gets, a.last_active_time, a.hash_value, a.sql_text
 from v$sql a, v$session b
where a.hash_value = b.sql_hash_value
  and b.sid = nvl('&&sid', b.sid)
  and a.sql_text like '%&&sql_text%' and a.sql_text not like '%v$sql%'
/

spool off;

undefine sid
undefine sql_text
undefine filename

set pagesize 22
set linesize 120

rem pause Press <Return> to continue;

rem exit
