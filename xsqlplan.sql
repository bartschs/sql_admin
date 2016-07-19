rem NAME
rem   sqlplan.sql
rem FUNCTION
rem   gets info about user's sql plan
rem NOTE
rem   start from specified user with Admin priviledge
rem MODIFIED
rem   30.04.09 SBartsch - made it  
rem

set verify off;
set heading off;
set trimspool on;
set feedback off;
set pagesize 2000
set linesize 200 

clear columns
clear breaks
clear computes

ttitle off
btitle off

column ID               format 99999 heading "ID"
column OPERATION        format a20   heading "OPERATION"
column OPTIONS          format a25   heading "OPTIONS"
column OBJECT_NAME      format a30   heading "OBJECT_NAME"

prompt
prompt -----------------------------------------------------------;
prompt SQL Plan Report;
prompt -----------------------------------------------------------;
prompt
accept schemaname    char prompt 'Parsing Schema [SPR_SCHEMA]: ' default 'SPR_SCHEMA';
accept fulltext      char prompt 'SQL Full Text .......... []: ';
accept filename      char prompt 'Spool to <filename> .......: ' default '&TMPDIR.sqlikey.lst';

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
       'SQL Plan Report'|| chr(10) ||
       '------------------------------------------------------'|| chr(10) ||
       'Database Name :  &&dbname'|| chr(10) ||
       'User Name     :  '||user||' '|| chr(10) ||
       'Parsing Schema:  &&schemaname'|| chr(10) ||
       'SQL Full Text :  &&fulltext'|| chr(10) ||
       'Spool File    :  &&filename'|| chr(10) ||
       '------------------------------------------------------'|| chr(10) from dual
/

set heading on;
set feedback on;

select distinct 
       p.id, p.sql_id, p.child_number
      ,p.operation, p.options
      ,p.object_name
    --,p.partition_start, p.partition_stop
      ,p.timestamp 
  from v$sql_plan p
      ,(
        select distinct 
               t.plan_hash_value 
          from v$sql t
         where t.sql_fulltext like UPPER('%&&fulltext%')
           and t.parsing_schema_name = UPPER('&&schemaname')
       ) t
where p.plan_hash_value = t.plan_hash_value  
order by p.timestamp desc, p.sql_id, p.id
/

spool off;

undefine dbname
undefine schemaname
undefine fulltext
undefine filename

set pagesize 22
set linesize 120

rem pause Press <Return> to continue;

rem exit

/*
select id, operation, options, object_name, partition_start, partition_stop, timestamp from v$sql_plan
where plan_hash_value = 
(
select distinct plan_hash_value from v$sql 
where sql_fulltext like UPPER('%&&fulltext%')
and parsing_schema_name = UPPER('&&schemaname')
)
order by timestamp desc, sql_id, id
/
*/
