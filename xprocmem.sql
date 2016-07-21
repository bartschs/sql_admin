rem NAME
rem     procmem.sql
rem FUNCTION
rem     gets info about DBA Proecess Memory
rem NOTE
rem     start as DBA
rem MODIFIED
rem     27.03.07 SBartsch - made it   
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

column tablespace_name   format a20          heading 'TBS'
column bytes             format 990,000.000  heading 'G_BYTES'
column blocks            format 9999999999   heading 'BLOCKS'
column name format a30

prompt -----------------------------------------------------------;
prompt DBA Process Memory Report
prompt -----------------------------------------------------------;
accept sid      char prompt 'Oracle-SID: [] ';
accept filename char prompt 'Spool File: [] ' default '&TMPDIR.dbaproc.lst';

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
       'DBA Process Memory Report'|| chr(10) ||
       '------------------------------------------------------'|| chr(10) ||
       'Database Name   :  &&dbname'|| chr(10) ||
       'User Name       :  '||user||' '|| chr(10) ||
       'Oracle-SID      :  &&sid'|| chr(10) ||
       'Spool File      :  &&filename'|| chr(10) ||
       '------------------------------------------------------'|| chr(10) from dual
/

set heading on;
set feedback on;


select   sid, name, value
  from   v$statname n,v$sesstat s
 where   n.STATISTIC# = s.STATISTIC# 
   and   n.name like 'session%memory%'
   and   s.sid like to_number(nvl('&sid', s.sid))
order by 3 asc
/


undefine sid
