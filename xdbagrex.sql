rem
rem NAME
rem     sh_gr_ex.sql
rem FUNCTION
rem     gets info about executable procedures/functions within PL/SQL packages
rem NOTE 
rem     start from sqlplus for specified table owner
rem MODIFIED
rem     07.11.99 SBartsch - made it  
rem   

set trimspool on;
set verify off;
rem set heading on;
set heading off;
set feedback off;

set long 20000;
set maxdata 60000;
set pagesize 2000;

clear columns
clear breaks
clear computes

ttitle off
btitle off

column procedures      format a80 heading 'EXECUTABLE PROCEDURES/FUNCTIONS'

prompt
prompt -----------------------------------------------------------;
prompt Executable PL/SQL Procedures/Functions Report
prompt -----------------------------------------------------------;
prompt
accept owner      char prompt 'Owner Name:  [] '
accept grantee    char prompt 'Grantee:     [] '
accept tablename  char prompt 'Object Name: [] '
accept procedure  char prompt 'Proc/Func:   [] '
accept filename   char prompt 'Spool File:  [] ' default '&TMPDIR.plsgrex.lst';
rem prompt ------------------------------------------------------;

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
       'Executable PL/SQL Procedures/Functions Report'|| chr(10) ||
       '------------------------------------------------------'|| chr(10) ||
       'Database Name :  &&dbname'|| chr(10) ||
       'User Name     :  '||user||' '|| chr(10) ||
       'Owner Name    :  &&owner'|| chr(10) ||
       'Grantee       :  &&grantee'|| chr(10) ||
       'Object Name   :  &&tablename'|| chr(10) ||
       'Proc/Func Name:  &&procedure'|| chr(10) ||
       'Spool File    :  &&filename'|| chr(10) ||
       '------------------------------------------------------'|| chr(10) from dual
/

set feedback on;

select distinct owner || '.' || package_name || '.' || object_name procedures
  from all_arguments
 where owner || '.' || package_name IN 
     ( 
      select owner || '.' || table_name
         from role_tab_privs
        where privilege = 'EXECUTE'
          and owner = upper('&&owner')
          and table_name like upper(nvl('%&&tablename.%', '%'))
      union
       select owner || '.' || table_name
         from dba_tab_privs
        where privilege = 'EXECUTE'
          and owner = upper('&&owner')
          and table_name like upper(nvl('%&&tablename.%', '%'))
          and grantee in (upper('&&grantee'), 'PUBLIC')
     )
   and owner like upper(nvl('%&&owner.%', '%'))
   and object_name like upper(nvl('%&&procedure.%', '%'))
 order by 1
/
spool off;

undefine dbname
undefine owner
undefine grantee
undefine tablename
undefine procedure
undefine filename
