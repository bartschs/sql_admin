rem NAME
rem   allproc.sql
rem FUNCTION
rem   gets info about  user's procedures
rem NOTE
rem   start from specified user
rem MODIFIED
rem   97.09.2007 SBartsch - made it  
rem

set trimspool on;
set verify off;
set feedback off;
set heading off;

clear columns
clear breaks
clear computes

ttitle off
btitle off

column OWNER           format a12
column object_name     format a20
column object_type     format a10 heading 'TYPE' 
column object_id       format 99999999
column subprogram_id   format 99999999
column procedure_name  format a20 

prompt
prompt -----------------------------------------------------------;
prompt User DB-Objects Report
prompt -----------------------------------------------------------;
prompt
accept ownname  char prompt 'Owner Name:    [] ';
accept objname  char prompt 'Object Name:   [] ';
accept objtype  char prompt 'Object Type:   [] ';
accept filename char prompt 'Spool File:    [] ' default '&TMPDIR.sqlobj.lst';

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
       'User DB-Procedures Report'|| chr(10) ||
       '------------------------------------------------------'|| chr(10) ||
       'Database Name :  &&dbname'|| chr(10) ||
       'User Name     :  '||user||' '|| chr(10) ||
       'Run On        :  '||sysdate||' '|| chr(10) ||
       'Object Name   :  &&objname'|| chr(10) ||
       'Object Type   :  &&objtype'|| chr(10) ||
       'Spool File    :  &&filename'|| chr(10) ||
       '------------------------------------------------------'|| chr(10) from dual
/

set heading on;
set feedback on;

select owner, object_name, object_type, object_id, subprogram_id, procedure_name
  from all_procedures 
 where owner like upper(nvl('%&&ownname.%','%'))
   and object_name like upper(nvl('%&&objname.%','%'))
   and object_type like upper(nvl('%&&objtype.%','%'))      
 order by object_name, subprogram_id
/

spool off;

undefine dbname
undefine ownname
undefine objname
undefine objtype
undefine filename

rem pause Press <Return> to continue;

rem exit
