rem
rem NAME
rem   getpar.sql
rem FUNCTION
rem   lists values of the v$parameter table via DBMS_UTILITY
rem NOTE 
rem   start from sqlplus/sqldba as DBA
rem MODIFIED
rem   24.03.04 SBartsch - made it
rem   

set trimspool on;
set verify off;
rem set heading on;
set heading off;
set feedback off;
set trimspool on;

prompt ------------------------------------------------------;
prompt Parameter Session Setting Report;
prompt ------------------------------------------------------;
accept var_param char prompt 'Parameter Name ... : ' default 'db_name';
accept spoolfile char prompt 'Spool to <filename>: ' default '&TMPDIR.tmpgpar.lst';


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
       'Parameter Session Setting Report'|| chr(10) ||
       '------------------------------------------------------'|| chr(10) ||
       'Database Name :  &&dbname'|| chr(10) ||
       'User Name     :  '||user||' '|| chr(10) ||
       'Run On        :  '||sysdate||' '|| chr(10) ||
       'Parameter     :  &&var_param'|| chr(10) ||
       'Spool File    :  &&spoolfile'|| chr(10) ||
       '------------------------------------------------------'|| chr(10) from dual
/

set heading off;

declare
  l_param    varchar2(30) := '&&var_param';
  l_return   binary_integer;
  l_intval   binary_integer;
  l_strval   varchar2(30);
begin
  dbms_output.enable (1000000);
  l_return := dbms_utility.get_parameter_value( l_param, l_intval, l_strval );
  if l_return = 1 then 
    dbms_output.put_line('Parameter Name : '|| l_param);
    dbms_output.put_line('Parameter Value: '|| l_strval);
  else
    dbms_output.put_line('Parameter Name : '|| l_param);
    dbms_output.put_line('Parameter Value: '|| l_intval);
  end if;
end;
/

prompt ------------------------------------------------------;
prompt

spool off;

undefine param
undefine spoolfile
