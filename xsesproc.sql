rem
rem NAME
rem   sh_sesoenv.sql
rem FUNCTION
rem   lists values of the v$ses_optimizer_env view
rem NOTE 
rem   start from sqlplus/sqldba as DBA
rem MODIFIED
rem   20.06.07 SBartsch - made it
rem   

set trimspool on;
set verify off;
--set heading on;
set heading off;
set feedback off;
set trimspool on;

rem set long 20000;
rem set maxdata 60000;
rem set pagesize 20000;


column sid       format 99999 heading "SID";
column id        format 99999 heading "ID";
column name      format a40 heading "Parameter";

prompt -----------------------------------------------------------;
prompt Session PL/SQL-Procedure Hierarchy Report;
prompt -----------------------------------------------------------;
accept sid       char prompt 'Oracle SID ........: ';
accept oid       char prompt 'Object ID  ........: ';
accept spoolfile char prompt 'Spool to <filename>: ' default '&TMPDIR.sesoenv.lst';


rem
rem get current DB Name
rem

set termout off
define dbname=xxx
column currname new_value dbname
select global_name currname from global_name;
set termout on

spool &&spoolfile;

select '------------------------------------------------------'|| chr(10) ||
       'Session PL/SQL-Procedure Hierarchy Report'|| chr(10) ||
       '------------------------------------------------------'|| chr(10) ||
       'Database Name :  &&dbname'|| chr(10) ||
       'User Name     :  '||user||' '|| chr(10) ||
       'Run On        :  '||sysdate||' '|| chr(10) ||
       'Oracle SID    :  &&sid'|| chr(10) ||
       'Object ID     :  &&oid'|| chr(10) ||
       'Spool File    :  &&spoolfile'|| chr(10) ||
       '------------------------------------------------------'|| chr(10) from dual
/

set heading off;

prompt SID (plsql_entry_object_id/plsql_entry_subprogram_id/plsql_object_id/plsql_subprogram_id)  
prompt -----------------------------------------------------------------------------------------;

select sid
      ,plsql_entry_object_id 
      ,plsql_entry_subprogram_id
      ,plsql_object_id         
      ,plsql_subprogram_id
  from v$session
 where sid = nvl('&&sid', sid)
   and (plsql_entry_object_id = nvl('&&oid', plsql_entry_object_id) or
        plsql_object_id = nvl('&&oid', plsql_object_id)) 
 order by sid
/

prompt -----------------------------------------------------------------------------------------;
prompt 

spool off;

undefine sid
undefine spoolfile
