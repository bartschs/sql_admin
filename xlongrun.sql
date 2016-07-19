set trimspool on;
set verify off;
set feedback off;
set heading off;

clear columns
clear breaks
clear computes

ttitle off
btitle off

column program_id       format 9999999999 heading "PID"
column username         format a10   heading "RANK"
column operation        format a25   heading "DURATION"
column rows_processed   format 9999999999 heading "ROWS"
column sql_text         format a30   heading "SQL_TEXT"

prompt
prompt -----------------------------------------------------------;
prompt DB Long OPS Overview Report
prompt -----------------------------------------------------------;
prompt
accept user_name  char prompt 'User Name: ....... : ' ;
accept sid        char prompt 'Oracle SID: ...... : ' ;
accept filename   char prompt 'Spool to <filename>: ' default '&TMPDIR.tdbalong.lst';

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
       'DB Long Run Overview Report'|| chr(10) ||
       '------------------------------------------------------'|| chr(10) ||
       'Database Name :  &&dbname'|| chr(10) ||
       'User Name     :  '||user||' '|| chr(10) ||
       'Run On        :  '||sysdate||' '|| chr(10) ||
       'User Name     :  &&user_name'|| chr(10) ||
       'SID           :  &&sid'|| chr(10) ||
       'Spool File    :  &&filename'|| chr(10) ||
       '------------------------------------------------------'|| chr(10) from dual
/

set heading on;
set feedback on;

select a.program_id, r.rank, a.rows_processed, r.elapsed_time/1000/1000/60/60 elapsed_duration, a.sql_text
  from  v$sqlarea a 
       ,(select * from
           (
             select sql_id, elapsed_time, rank() over (order by elapsed_time desc) as rank
               from V$sql
           ) 
           where rank <=10
        ) r
 where a.sql_id = r.sql_id
/


/*
select 
       sl.sid
      ,sl.username 
    --,sl.opname||' '||sl.target operation
	  ,sl.message
      ,(sl.sofar * 100) / sl.totalwork pct
      ,sl.start_time
      ,sl.last_update_time + (sl.time_remaining / 86400) finish
  from 
       v$session_longops sl
      ,v$session s
 where s.sid(+)     = sl.sid
   and s.serial#(+) = sl.serial#
   and s.username like upper(nvl('&&user_name.%','%'))
   and s.sid = nvl('&&sid', s.sid)
 order by s.sid, sl.start_time 
/
*/

-- where sl.time_remaining > 0
-- and s.username = 'RATING'
-- order by sl.finish

spool off;

--undefine user_name 
--undefine sid      
--undefine filename

/*
SELECT   SID,
         DECODE (totalwork,
                 0, 0,
                 ROUND (100 * sofar / totalwork, 2)
                ) "Percent",
         MESSAGE "Message", start_time, elapsed_seconds, time_remaining
    FROM v$session_longops
   WHERE (SID = 526 AND serial# = 266) OR (SID = 515 AND serial# = 210)
ORDER BY SID
/
*/

