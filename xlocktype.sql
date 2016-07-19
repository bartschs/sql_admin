rem NAME
rem   sqllock.sql
rem FUNCTION
rem   gets info about user lcoked objects
rem NOTE
rem   start from specified user
rem MODIFIED
rem   05.11.03 SBartsch - made it  
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


column username     format a8 trunc heading 'DB User'
column type         format a4 trunc
column name         format a25 trunc
column description  format a65 trunc

prompt
prompt -----------------------------------------------------------;
prompt Lock Types Report
prompt -----------------------------------------------------------;
prompt
accept filename char prompt 'Spool File:    [] ' default '&TMPDIR.sqllock.lst';
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
       'Lock Types Report'|| chr(10) ||
       '------------------------------------------------------'|| chr(10) ||
       'Database Name :  &&dbname'|| chr(10) ||
       'User Name     :  '||user||' '|| chr(10) ||
       'Spool File    :  &&filename'|| chr(10) ||
       '------------------------------------------------------'|| chr(10) from dual
/

set heading on;
set feedback on;

select type ,name ,description 
  from v$lock_type
 order by 1
/

spool off;

undefine dbname
undefine objname
undefine objtype
undefine ordcrit
undefine filename

rem pause Press <Return> to continue;

rem exit
  
