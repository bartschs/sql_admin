rem
rem NAME
rem   sh_sysoenv.sql
rem FUNCTION
rem   lists values of the v$sys_optimizer_env view
rem NOTE 
rem   start from sqlplus/sqldba as DBA
rem MODIFIED
rem   20.06.07 SBartsch - made it
rem   

set trimspool on;
set verify off;
set heading on;
set heading off;
set feedback off;
set trimspool on;

rem set long 20000;
rem set maxdata 60000;
set pagesize 20000;


column id            format 99999 heading "ID";
column name          format a40 heading "Parameter";
column sql_feature   format a20 heading "Parameter";
column isdefault     format a5  heading "Dflt?";
column value         format a15 heading "Value";
column default_value format a15 heading "Default_Value";

prompt -----------------------------------------------------------;
prompt System Optimizer Environment Report;
prompt -----------------------------------------------------------;
accept param     char prompt 'Optimizer Parameter: ';
accept spoolfile char prompt 'Spool to <filename>: ' default '&TMPDIR.sysoenv.lst';


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
       'System Optimizer Environment Report'|| chr(10) ||
       '------------------------------------------------------'|| chr(10) ||
       'Database Name :  &&dbname'|| chr(10) ||
       'User Name     :  '||user||' '|| chr(10) ||
       'Run On        :  '||sysdate||' '|| chr(10) ||
       'Parameter     :  &&param'|| chr(10) ||
       'Spool File    :  &&spoolfile'|| chr(10) ||
       '------------------------------------------------------'|| chr(10) from dual
/

set heading off;

prompt ID     Parameter                           SQL_Feature          Default? Value        Default_Value       
prompt ------ ----------------------------------- -------------------- -------- ------------ ------------;

select 
       id
      ,name
      ,sql_feature
      ,isdefault
      ,value
      ,default_value
  from v$sys_optimizer_env
 where name like '&&param.%'
 order by id, name;

prompt --------------------------------------------------------------------------------------------------;
prompt 

spool off;

undefine param
undefine spoolfile
