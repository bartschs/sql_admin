set trimspool on;
set verify off;
set feedback off;
set heading off;

clear columns
clear breaks
clear computes

ttitle off
btitle off

column sid       format 999999  heading "SID"
column username  format a10     heading "User"
column operation format a25     heading "Operation"
column pct       format 999.9   heading "% done"
column finish                   heading "Estimated Finish"
column start_time               heading "Started"
column nl newline heading 'SQL Text';


prompt
prompt -----------------------------------------------------------;
prompt DB Long OPS SQL Text Overview Report
prompt -----------------------------------------------------------;
prompt
accept user_name  char prompt 'User Name: ....... : ' ;
accept filename   char prompt 'Spool to <filename>: ' default '&TMPDIR.tdbalongt.lst';

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
       'DB Long OPS SQL Text Overview Report'|| chr(10) ||
       '------------------------------------------------------'|| chr(10) ||
       'Database Name :  &&dbname'|| chr(10) ||
       'User Name     :  '||user||' '|| chr(10) ||
       'Run On        :  '||sysdate||' '|| chr(10) ||
       'User Name     :  &&user_name'|| chr(10) ||
       'Spool File    :  &&filename'|| chr(10) ||
       '------------------------------------------------------'|| chr(10) from dual
/

set heading on;
set feedback on;


select 
       sl.username 
      ,s.sql_text nl
      ,sl.sofar
	  ,sl.totalwork 
	  ,sl.units 
  from 
       v$sql s
      ,v$session_longops sl
 where sl.sql_address  = s.address
   and sl.sql_hash_value = s.hash_value
   and sl.username like upper(nvl('&&user_name.%','%'))
 order by s.address, s.hash_value, s.child_number
/

-- where sl.time_remaining > 0
-- and s.username = 'RATING'
-- order by sl.finish

spool off;

undefine user_name 
undefine filename
