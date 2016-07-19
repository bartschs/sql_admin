rem NAME
rem   sqlid.sql
rem FUNCTION
rem   gets info about user's sql statements
rem NOTE
rem   start from specified user with Admin priviledge
rem MODIFIED
rem   22.02.10 SBartsch - made it  
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

column TABLE_NAME        format a25 heading 'TABLE'
column PARTITION_NAME    format a25 heading 'PARTITION'
column SUBPARTITION_NAME format a25 heading 'SUBPARTITION'

prompt
prompt -----------------------------------------------------------;
prompt SQL ID Report;
prompt -----------------------------------------------------------;
prompt
accept objname       char prompt 'Object Name: ...... [] ';
accept filename      char prompt 'Spool to <filename>:.. ' default '&TMPDIR.sqlstale.lst';

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
       'SQL ID Report'|| chr(10) ||
       '------------------------------------------------------'|| chr(10) ||
       'Database Name :  &&dbname'|| chr(10) ||
       'User Name     :  '||user||' '|| chr(10) ||
       'Object Name   :  &&objname'|| chr(10) ||
       'Spool File    :  &&filename'|| chr(10) ||
       '------------------------------------------------------'|| chr(10) from dual
/

set heading on;
set feedback on;

select distinct TABLE_NAME, PARTITION_NAME, SUBPARTITION_NAME, LAST_ANALYZED 
  from all_tab_statistics
 where stale_stats = 'YES'
   and table_name like upper(nvl('%&&objname.%','%'))
order by 1 
/


spool off;

undefine objname
undefine filename

set pagesize 22
set linesize 120

rem pause Press <Return> to continue;

rem exit
