rem NAME
rem   allobj.sql
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

column OWNER           format a12
column object_name     format a30
column object_type     format a12 heading 'TYPE' 
column created         format a10
column last_ddl_time   format a10 heading 'MODIFIED'
column timestamp       format a10 heading 'TIMESTAMP'
column status          format a7

prompt
prompt -----------------------------------------------------------;
prompt User DB-Objects Report
prompt -----------------------------------------------------------;
prompt
accept ownname  char prompt 'Owner Name:    [] ';
accept objname  char prompt 'Object Name:   [] ';
accept objtype  char prompt 'Object Type:   [] ';
accept stat     char prompt 'Object Status: [] ';
accept ordcrit  char prompt 'Order by [Object] ';
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
       'User DB-Objects Report'|| chr(10) ||
       '------------------------------------------------------'|| chr(10) ||
       'Database Name :  &&dbname'|| chr(10) ||
       'User Name     :  '||user||' '|| chr(10) ||
       'Object Name   :  &&objname'|| chr(10) ||
       'Object Type   :  &&objtype'|| chr(10) ||
       'Object Status :  &&stat'|| chr(10) ||
       'Order by      :  &&ordcrit'|| chr(10) ||
       'Spool File    :  &&filename'|| chr(10) ||
       '------------------------------------------------------'|| chr(10) from dual
/

set heading on;
set feedback on;

select owner, object_name, object_type, created, last_ddl_time,
       substr(timestamp, nvl(instr(timestamp,':'),0) +1) timestamp, status 
  from all_objects 
 where owner like upper(nvl('%&&ownname.%','%'))
   and object_name like upper(nvl('%&&objname.%','%'))
   and object_type = upper(nvl('&&objtype','%'))
   and status like upper(nvl('&&stat.%','%'))   
 order by decode (nvl('&&ordcrit', 'object')
                  ,'date', to_char(last_ddl_time,'yyyymmddhh24miss')
                  ,'created', to_char(created,'yyyymmddhh24miss')
                  ,'object', object_name
                  ,object_name)
/

-- and object_name like upper(nvl('%&&objname.%','%'))
-- and object_type like upper(nvl('%&&objtype.%','%'))      

spool off;
rem  order by decode (nvl('&&ordcrit', object_name), 'date', last_ddl_time , object_name)

rem  order by object_name;

rem   and object_type in ('PACKAGE', 'PACKAGE BODY', 'FUNCTION', 'PROCEDURE', 'TRIGGER')

undefine dbname
undefine ownname
undefine objname
undefine objtype
undefine status
undefine ordcrit
undefine filename

rem pause Press <Return> to continue;

rem exit
