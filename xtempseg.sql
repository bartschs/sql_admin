rem
rem NAME
rem     sh_os.sql
rem FUNCTION
rem     get OS user's session info
rem NOTE
rem     start from sqlplus/sqldba
rem MODIFIED
rem     11.11.98 SBartsch - made it
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

column sid         format 9999999
column serial#     format 9999999
column username    format a15
column program     format a15
column osuser      format a10
column process     format a9
column machine     format a10
column terminal    format a10
column tablespace  format a15

prompt
prompt -----------------------------------------------------------;
prompt Temporary Segment Usage Report;
prompt -----------------------------------------------------------;
prompt
accept user_name  char prompt 'User Name: ....... : ' ;
accept sid        char prompt 'Oracle SID: ...... : ' ;
accept filename   char prompt 'Spool to <filename>: ' default '&TMPDIR.tempseg.lst';

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
       'Temporary Segment Usage Report'|| chr(10) ||
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

select  s. sid, s.serial#, s.username 
       ,b.tablespace, b.contents, b.segtype, b.extents, b.blocks 
  from v$sql_workarea_active a, v$tempseg_usage b, v$session s
 where a.SEGBLK# = b.SEGBLK#
  and a.SEGRFNO# = b.SEGRFNO#
  and s.SADDR = b.SESSION_ADDR
   and s.username like upper(nvl('&&user_name.%','%'))
   and s.sid = nvl('&&sid', s.sid)
/

--undefine user_name 
--undefine sid      
undefine filename

spool off;

