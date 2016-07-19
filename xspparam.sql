rem NAME
rem   spparam.sql
rem FUNCTION
rem   Get Parameter Values for SP Parameters with description info
rem NOTE
rem   start from user with execute grant 
rem MODIFIED
rem   28.10.99 SBartsch - made it
rem

set serveroutput on size 1000000 format wrapped;
set verify off; 
set feedback off; 
set trimspool on;
set heading off;

set long 20000;
set maxdata 60000;
set pagesize 2000;

clear columns
clear breaks
clear computes

ttitle off
btitle off

column param_id          format 9999999999
column param_value       format a30
column description_id    format 9999999999
column long_description  format a30

prompt
prompt -----------------------------------------------------------;
prompt SP Parameter Report;
prompt -----------------------------------------------------------;
prompt
accept filename      char prompt 'Spool to <filename>: ' default '&TMPDIR.xspparam.lst';

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
       'SP Parameter Report'|| chr(10) ||
       '------------------------------------------------------'|| chr(10) ||
       'Database Name :  &&dbname'|| chr(10) ||
       'User Name     :  '||user||' '|| chr(10) ||
       'Run On        :  '||sysdate||' '|| chr(10) ||
       'Spool File    :  &&filename'|| chr(10) ||
       '------------------------------------------------------'|| chr(10) from dual
/

SELECT p.param_id, p.param_value, d.description_id, d.long_description
  FROM RBI$TA_SP_Parameter p
      ,RBI$TA_DESCRIPTION  d
 WHERE p.description_id = d.description_id(+)
ORDER BY p.param_id
/

undefine filename

spool off;
