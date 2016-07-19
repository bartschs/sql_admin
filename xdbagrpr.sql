rem NAME
rem     dbagrpr.sql
rem FUNCTION
rem     list system privileges granted to user
rem NOTE
rem     start as DBA
rem MODIFIED
rem     14.01.2013 SBartsch  - made it
rem

set verify off;
set trimspool on;
set feedback off;
set heading off;

clear columns
clear breaks
clear computes

ttitle off
btitle off

column privilege       format a40 


prompt
prompt -----------------------------------------------------------;
prompt Granted System Privileges Report;
prompt -----------------------------------------------------------;
prompt
accept grantee     char prompt 'Grantee: ............ [] ';
accept filename    char prompt 'Spool to <filename> : [] ' default '&TMPDIR.dbagrpr.lst';

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
       'Granted System Privileges Report'|| chr(10) ||
       '------------------------------------------------------'|| chr(10) ||
       'Database Name          :  &&dbname'|| chr(10) ||
       'User Name              :  '||user||' '|| chr(10) ||
       'Run On                 :  '||sysdate||' '|| chr(10) ||
       'Grantee                :  &&grantee'|| chr(10) ||
       'Spool File             :  &&filename'|| chr(10) ||
       '------------------------------------------------------'|| chr(10) from dual
/

set heading on;
set feedback on;

prompt 
prompt --------------------;
prompt System Privileges; 
prompt --------------------;

prompt 
prompt Via Direct Grant -> 
select *
  from dba_sys_privs
 where grantee like upper(nvl('%&&grantee.%', '%')) 
 order by grantee, privilege
/

prompt 

set feedback on;

undefine option
undefine filename

spool off;
