rem NAME
rem   plsobj.sql
rem FUNCTION
rem   gets info about  user's objects
rem NOTE
rem   start from specified user
rem MODIFIED
rem   06.11.95 SBartsch - made it  
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

column object_name     format a30
column object_id       format 99999999
column object_type     format a12 heading 'TYPE' 
column created         format a10
column last_ddl_time   format a10 heading 'MODIFIED'
column timestamp       format a10 heading 'TIMESTAMP'
column status          format a7


prompt
prompt -----------------------------------------------------------;
prompt User PL/SQL Objects Report
prompt -----------------------------------------------------------;
prompt
accept objname  char prompt 'Object Name:   [] ';
accept stat     char prompt 'Object Status: [] ';
accept ordcrit  char prompt 'Order by [Object] ';
accept filename char prompt 'Spool File:    [] ' default '&TMPDIR.plsobj.lst';
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
       'User PL/SQL Objects Report'|| chr(10) ||
       '------------------------------------------------------'|| chr(10) ||
       'Database Name :  &&dbname'|| chr(10) ||
       'User Name     :  '||user||' '|| chr(10) ||
       'Run On        :  '||sysdate||' '|| chr(10) ||
       'Object Name   :  &&objname'|| chr(10) ||
       'Object Status :  &&stat'|| chr(10) ||
       'Order by      :  &&ordcrit'|| chr(10) ||
       'Spool File    :  &&filename'|| chr(10) ||
       '------------------------------------------------------'|| chr(10) from dual
/

set heading on;
set feedback on;

--select object_name, object_type, created, last_ddl_time,
select object_name, object_type, created, last_ddl_time,
       substr(timestamp, nvl(instr(timestamp,':'),0) +1) timestamp, status, object_id 
  from user_objects 
 where object_name like upper(nvl('%&&objname.%','%'))
   and object_type in ('PACKAGE', 'PACKAGE BODY', 'FUNCTION', 'PROCEDURE', 'TRIGGER')
   and status like upper(nvl('&&stat.%','%'))   
 order by decode (nvl('&&ordcrit', 'object')
                  ,'date', to_char(last_ddl_time,'yyyymmddhh24miss')
                  ,'created', to_char(created,'yyyymmddhh24miss')
                  ,'object', object_name
                  ,object_name)
/

spool off;

rem  order by decode (nvl('&&ordcrit', object_name), 'date', last_ddl_time , object_name)

undefine objname
undefine stat
undefine ordcrit

rem pause Press <Return> to continue;

rem exit
