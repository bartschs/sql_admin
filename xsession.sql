select  substr(sid,1,3)         sid
,       substr(serial#,1,4)     ser#
,       substr(username,1,6)    username
,       substr(schemaname,1,6)  schemaname
,       substr(osuser,1,8)      osuser
,       process
,       substr(machine,1,6)     machine
,       substr(terminal,1,13)   terminal
,       substr(program,1,12)    program
,       substr(type,1,10)       type
,       substr(to_char(logon_time, 'HH24:MI:SS'),1,8) logon_time
from    v$session
/
