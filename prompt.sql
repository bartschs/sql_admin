set termout off
set heading off
set feedback off

spool /tmp/xprompt.sql
select 'set sqlprompt "'|| substr(global_name,1,instr(global_name,'.')-1) || '> "' from global_name;
spool off

set termout on
set heading on
set feedback on
show user
@@/tmp/xprompt.sql
