--set termout off
--set heading off
--set feedback off
--
--spool &TMPDIR.xprompt.sql
--select 'set sqlprompt "'|| substr(global_name,1,instr(global_name,'.')-1) || '('||USER||')> "'
-- from global_name;
--
--spool off
--
--set termout on
--set heading on
--set feedback on
--show user
--@@&TMPDIR.xprompt.sql

set termout off
set heading off
set feedback off

set termout off
define var_prompt=SQL>
column user_prompt new_value var_prompt
select '"'|| substr(global_name,1,instr(global_name,'.')-1) || '('||USER||')> "' user_prompt
 from global_name;
set termout on

set sqlprompt &&var_prompt
undefine var_prompt

set termout on
set heading on
set feedback on
