Rem 
Rem NAME
Rem   plsexec.sql 
Rem FUNCTION 
rem NAME
rem    plsexec.sql
rem FUNCTION
rem    execute PL/SQL Package procedure of specified user
rem NOTE
rem    call from sqlplus as specified user 
rem MODIFIED
rem    09.04.98 SBartsch  - made it
rem

prompt
prompt ----------------------------------------------------------------------;
prompt Execute Stored Objects Reports
prompt ----------------------------------------------------------------------;
prompt
rem accept owner char prompt 'Owner Name:       [USER] ';
accept objname   char prompt 'PL/SQL Package Name: [] ';
accept procname  char prompt 'PL/SQL Proc: [CONTRACT] ';
rem accept filename char prompt 'Spool to <filename>: [] ';

set heading off
set linesize 80
set pause off
set termout off
set feedback off
set concat on
set verify off

clear columns
clear breaks
clear computes

ttitle off
btitle off

column command_line1 format a75
column command_line2 format a75

spool &TMPDIR.tmpexec.sql

select 'prompt '|| chr(10) ||
       'prompt Executing '|| object_name || '.'|| nvl('&&procname', 'contract') ||'...;' || chr(10) ||
       'execute '|| object_name || '.' || nvl('&&procname', 'contract') ||';' command_line1
  from user_objects
 where object_type = 'PACKAGE'
   and object_name like upper(nvl('%&&objname.%','%'))
/

spool off
set heading on
set feedback 6
set termout on
set verify on

spool &TMPDIR.tmpexec.lst;
start &TMPDIR.tmpexec.sql
rem host rm &TMPDIR.tmpexec.sql
spool off

set verify off
set linesize 100

set heading on; 

undefine objname
undefine objtype
undefine procname

rem pause Press <Return> to continue;

rem exit
