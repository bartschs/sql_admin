rem NAME
rem    sh_who.sql
rem FUNCTION
rem    locate all UNIX server processes for a possible 'kill -9'
rem NOTE
rem    start as DBA
rem MODIFIED
rem    10.10.02 SBartsch - revised it
rem    11.10.96 SBartsch - made it
rem

set pagesize 58
set linesize 132
col username format a10
col osuser format a10
col sid format 9999
col serial# format 999999
col machine format a10 heading 'CLIENT'
col program format a20
col terminal format a8
col os_pid format 999999

select
   s.username,
   s.osuser,
   s.sid,
   s.serial#,
   s.machine,
   s.process "PID",
   p.spid "OS_PID",
   s.terminal,
   p.program,
   p.background
from v$session s, v$process p
where s.paddr = p.addr
order by s.username, s.machine, s.process, s.sid;
