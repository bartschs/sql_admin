-------------------------------------------------------------------------------
----
----    file:      rpl_cre_jobs.sql
----
----    comment:   Creates ORACLE-JOBS for rpl
----               This script must get called in a &SPRSCHEMA session.
----
----               Jobs get automatically deleted with scratch-installations
----               (see .../general/gen_drop_jobs.sql)
----
-------------------------------------------------------------------------------

set verify off;
set serveroutput on;

declare
   job_num   binary_integer;
begin
   dbms_job.submit(job_num, 'rpl$PA_replicator.job;',
                   sysdate + (15*60)/(60*60*24), null, false);
end;
/

commit
/

show errors


-------------------------------------------------------------------------------
-- End of SQL-Script
-------------------------------------------------------------------------------
