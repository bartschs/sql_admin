rem
rem NAME
rem   sh_nls_param.sql
rem FUNCTION
rem   lists values of the v$nls_parameters table
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


column parameter format a35 heading "Parameter";
column value     format a30 heading "Value";

prompt -----------------------------------------------------------;
prompt V$Parameter Report;
prompt -----------------------------------------------------------;
accept param     char prompt 'NLS Parameter .... :  ';
accept spoolfile char prompt 'Spool to <filename>: ' default '&TMPDIR.tmpparm.lst';


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
       'V$NLS_Parameters Report'|| chr(10) ||
       '------------------------------------------------------'|| chr(10) ||
       'Database Name :  &&dbname'|| chr(10) ||
       'User Name     :  '||user||' '|| chr(10) ||
       'Run On        :  '||sysdate||' '|| chr(10) ||
       'Parameter     :  &&param'|| chr(10) ||
       'Spool File    :  &&spoolfile'|| chr(10) ||
       '------------------------------------------------------'|| chr(10) from dual
/

set heading off;

prompt Parameter                           Value                          
prompt ----------------------------------- ------------------------------;

select parameter
      ,value
  from v$nls_parameters
 where parameter like '&&param.%'
 order by parameter;

prompt -----------------------------------------------------------------------------;
prompt 

spool off;

undefine param
undefine spoolfile
