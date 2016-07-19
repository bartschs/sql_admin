rem NAME
rem     sh_rol_gr.sql
rem FUNCTION
rem     list roles granted to users or roles 
rem NOTE
rem     start as DBA
rem MODIFIED
rem     12.07.95 SBartsch  - made it
rem

set verify off;
set heading off;
set feedback off;

clear columns
clear breaks
clear computes

ttitle off
btitle off

column username        format a14  heading 'GRANTEE'
column table_name      format a22 heading 'OBJECT_NAME'
column grantee         format a20 
column privilege       format a20 


prompt
prompt -----------------------------------------------------------;
prompt Granted Roles Report
prompt -----------------------------------------------------------;
prompt
accept grantee     char prompt 'Grantee: ............ [] ';
accept rolename    char prompt 'Granted Role: ....... [] ';
accept filename    char prompt 'Spool to <filename> : [] ' default '&TMPDIR.sqlgrro.lst';

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
       'Granted Roles Report'|| chr(10) ||
       '------------------------------------------------------'|| chr(10) ||
       'Database Name      :  &&dbname'|| chr(10) ||
       'User Name          :  '||user||' '|| chr(10) ||
       'Run On             :  '||sysdate||' '|| chr(10) ||
       'Grantee            :  &&grantee'|| chr(10) ||
       'Granted Role       :  &&rolename'|| chr(10) ||
       'Spool File         :  &&filename'|| chr(10) ||
       '------------------------------------------------------'|| chr(10) from dual
/

set heading on;
set feedback on;

select *
  from dba_role_privs
 where grantee like upper(nvl('%&&grantee.%', '%'))
   and granted_role like upper(nvl('%&&rolename.%','%'))
 order by grantee, granted_role
/

undefine grantee
undefine rolename
undefine filename

spool off;
