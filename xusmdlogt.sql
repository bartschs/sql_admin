rem
rem NAME
rem   xusmdlog.sql
rem FUNCTION
rem   list delta log protocol cycle not older than interval
rem NOTE
rem   filename, interval set by calling routine
rem MODIFIED
rem   20.09.2007 SBartsch - made it
rem

set serveroutput on;
set heading off;
set pause off;
set feedback off;
set verify off;
--set verify on;
set trimspool on;

column class_name       format a15 heading 'CLASS'
column action_result    format a8  heading 'RESULT'
column action_detail    format a30 heading 'DETAIL'
column row_count        format 999999999

prompt
prompt ------------------------------------------------------;
prompt USM Delta Manager Protocol Cycle Report
prompt ------------------------------------------------------;
prompt
accept timestamp    char prompt 'Date   (YYYYMMDDHH24MISS) .... [] : ';
accept interval     char prompt 'Interval (+/- minutes) ..... [10] : ' default '10';
accept classname    char prompt 'Class Name ................... [] : ';
accept actionresult char prompt 'Action Result (SUCESS/FAILURE) [] : ';
accept filename     char prompt 'Spool to <filename> ...........[] : ' default '&TMPDIR.xusmdlogt.lst';

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
       'USM Delta Manager Protocol Cycle Report'|| chr(10) ||
       '------------------------------------------------------'|| chr(10) ||
       'Database Name :  &&dbname'|| chr(10) ||
       'User Name     :  '||user||' '|| chr(10) ||
       'Run On        :  '||sysdate||' '|| chr(10) ||
       'Time Interval :  &&interval'|| chr(10) ||
       'Class Name    :  &&classname'|| chr(10) ||
       'Action Result :  &&actionresult'|| chr(10) ||
       'Spool File    :  &&filename'|| chr(10) ||
       '------------------------------------------------------'|| chr(10) from dual
/

set heading on;
set feedback on;

select cp.action_time, cp.class_name, cp.action_result, cp.action_detail, cp.row_count  
  from usm$ta_class_protocol cp
 where (
	    cp.action_time between (to_date('&&timestamp', 'yyyymmddhh24miss') - &&interval/1440) and
                               (to_date('&&timestamp', 'yyyymmddhh24miss') + &&interval/1440) 
       )
   and cp.class_name = UPPER(NVL('&&classname', cp.class_name))
   and cp.action_result like UPPER(NVL('&&actionresult.%', '%'))
order by cp.action_time 
/


spool off;

undefine interval
undefine classname
undefine actionresult
undefine filename

rem exit
