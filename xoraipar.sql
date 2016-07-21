rem
rem NAME
rem   sh_param.sql
rem FUNCTION
rem   lists values of the v$parameter table
rem NOTE 
rem   start from sqlplus/sqldba as DBA
rem MODIFIED
rem   27.06.97 SBartsch - made it
rem   

set trimspool on;
set verify off;
rem set heading on;
set heading off;
set feedback off;
set trimspool on;

set long 20000;
set maxdata 60000;
set pagesize 20000;


column name       format a35 heading "Parameter";
column value      format a15 heading "Value";
column isdefault  format a8  heading "Default?";
column ismodified format a10 heading "Modified?";
column isadjusted format a10 heading "Adjusted?";

prompt -----------------------------------------------------------;
prompt V$Parameter Report;
prompt -----------------------------------------------------------;
accept param     char prompt 'INIT.ORA Parameter:  ';
accept spoolfile char prompt 'Spool to <filename>: ' default '&TMPDIR.tmpiparm.lst';


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
       'V$Parameter Report'|| chr(10) ||
       '------------------------------------------------------'|| chr(10) ||
       'Database Name :  &&dbname'|| chr(10) ||
       'User Name     :  '||user||' '|| chr(10) ||
       'Run On        :  '||sysdate||' '|| chr(10) ||
       'Parameter     :  &&param'|| chr(10) ||
       'Spool File    :  &&spoolfile'|| chr(10) ||
       '------------------------------------------------------'|| chr(10) from dual
/

set heading off;

prompt Parameter                           Value           Default? Modified?  Adjusted?
prompt ----------------------------------- --------------- -------- ---------- ----------;

select name
      ,value
      ,isdefault
      ,ismodified
      ,isadjusted
  from v$parameter
 where name like '&&param.%'
 order by name;

prompt ----------------------------------------------------------------------------------;
prompt 

spool off;

undefine param
undefine spoolfile
