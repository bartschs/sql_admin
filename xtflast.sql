rem NAME
rem    snlast.sql
rem FUNCTION
rem    This script fetches all "snapshot" max last refresh dates 
rem    and  spools it to an operating system file.
rem    This version runs against the ALL_* views:
rem    for use by application developers.
rem    -- Usage:    sqlplus -s un/pw @snlast.sql
rem NOTE
rem    call from sqlplus as specified user
rem MODIFIED
rem    25.02.2000 SBartsch  - made it
rem

prompt
prompt ------------------------------------------------------;
prompt TF-Table Max Last Refresh Report
prompt ------------------------------------------------------;
prompt
accept snapname  char prompt 'Snapshot Name .....: [] ';
accept spoolfile char prompt 'Spool to <filename>: [] ' default '&TMPDIR.tmp_last.lst';
prompt ------------------------------------------------------;
prompt

set heading off
set pause off
set termout off
set feedback off
set concat on
set verify off
#set trimspool on 

set pagesize 2000;
set linesize 200;

clear columns
clear breaks
clear computes

ttitle off
btitle off

column command_line format a90

rem
rem get current DB Name
rem

rem set termout off
define dbname=xxx
column currname new_value dbname
select global_name currname from global_name;
rem set termout on

spool &TMPDIR.tmp_head.sql

select 'prompt'|| chr(10) ||
       'prompt ------------------------------------------------------;'|| chr(10) ||
       'prompt TF-Table Max Last Refresh Report;'|| chr(10) ||
       'prompt ------------------------------------------------------;'|| chr(10) ||
       'prompt Database Name :  &&dbname'|| chr(10) ||
       'prompt User Name     :  '||user||' '|| chr(10) ||
       'prompt Run On        :  '||sysdate||' '|| chr(10) ||
       'prompt TF-Table Name :  &&snapname'|| chr(10) ||
       'prompt Spool File    :  &&spoolfile'|| chr(10) ||
       'prompt ------------------------------------------------------;'|| chr(10) from dual
/

spool off

spool &TMPDIR.tmp_last.sql

select 'prompt ------------------------------------------------------;'|| chr(10) ||
       'prompt TF-Table Name: '|| table_name || chr(10) ||
       'prompt ------------------------------------------------------;'|| chr(10) ||
       'SELECT '|| chr(10) ||
       '       NVL(MAX_LAST_REFRESH, TO_DATE(''02.01.1970 00:00:00'',''DD.MM.YYYY HH24:MI:SS''))'|| chr(10) ||
       '       MAX_LAST_REFRESH '|| chr(10) ||
       '  FROM '|| chr(10) ||
       '( '|| chr(10) ||
       'SELECT '|| chr(10) ||
       '       MAX(REFRESH_DATE$) MAX_LAST_REFRESH'|| chr(10) ||
       '  FROM '||table_name|| chr(10) ||
       ' WHERE '|| chr(10) ||
       '       REFRESH_DATE$ < TO_DATE(''31.12.4712 23:59:59'',''DD.MM.YYYY HH24:MI:SS'') '|| chr(10) ||
       ') '|| chr(10) ||
       ' ;' command_line
  from all_tables
 where table_name like upper(nvl('%&&snapname.%','%'))
 order by table_name
/

spool off

set heading on
set feedback 6
set termout on
set pause off
set verify off
spool &&spoolfile
start &TMPDIR.tmp_head.sql
start &TMPDIR.tmp_last.sql
host rm &TMPDIR.tmp_head.sql
rem host rm &TMPDIR.tmp_last.sql
spool off

undefine snapname
undefine spoolfile

