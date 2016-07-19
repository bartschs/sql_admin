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
accept interval     char prompt 'Date   (DD.MM.YYYY) .........: [] ';
accept classname    char prompt 'Class Name ..................: [] ';
accept actionresult char prompt 'Action Result (SUCESS/FAILURE) [] ';
accept filename     char prompt 'Spool to <filename> .........: [] ' default '&TMPDIR.prot_ref_cycle.lst';

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
 where trunc(cp.action_time) = to_date('&&interval', 'dd.mm.yyyy')
   and cp.class_name = UPPER(NVL('&&classname', cp.class_name))
   and cp.action_result like UPPER(NVL('&&actionresult.%', '%'))
order by cp.action_time 
/

-- where (trunc(cp.action_time) = NVL(to_date('&&interval', 'dd.mm.yyyy'), trunc(sysdate-30)) or
--        trunc(cp.action_time) >= NVL(to_date('&&interval', 'dd.mm.yyyy'), trunc(sysdate-30)) )

spool off;

undefine interval
undefine classname
undefine actionresult
undefine filename

rem exit
