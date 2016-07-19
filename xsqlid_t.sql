select status, sql_id, sql_child_number from v$session
where username = 'BARTSCHS_P3'

select sql_id, child_number, sql_text from v$sql
where sql_text like '%TH_INV_ASSIGNMENT_QFD_BULK11%' and sql_text not like '%v$sql%'	  

select sql_id, child_number, sql_text from v$sql
where sql_text like '%TA_SVC_EVT_PATTERN%' and sql_text not like '%v$sql%'	  


select * from table(dbms_xplan.display_cursor('djnhjudz03vmp',0))

select sql_id, child_number, disk_reads, buffer_gets, last_active_time, hash_value, sql_text from v$sql
where sql_text like '%TH_ACS_CREDIT_INSTANCE_BULK11%' and sql_text not like '%v$sql%'
  and hash_value = 3078305630

- 3078305630
- 2186330381

select sql_hash_value from v$session where sid = 8491

select b.sid, a.sql_id, a.child_number, a.disk_reads, a.buffer_gets, a.last_active_time, a.hash_value, a.sql_text
 from v$sql a, v$session b
where a.sql_text like '%TH_ACS_CREDIT_INSTANCE_BULK11%' and a.sql_text not like '%v$sql%'
  and a.hash_value = b.sql_hash_value
--  and a.hash_value = 3078305630
  and b.sid = 8491

select b.sid, a.sql_id, a.child_number, a.disk_reads, a.buffer_gets, a.last_active_time, a.hash_value, a.sql_text
 from v$sql a, v$session b
where a.sql_text like '%TH_ACS_CREDIT_INSTANCE_BULK11%' and a.sql_text not like '%v$sql%'
  and a.hash_value = b.sql_hash_value
  and a.hash_value = 2186330381
  --and b.sid = 8491


select a.sql_id, a.child_number, a.disk_reads, a.buffer_gets, a.last_active_time, a.hash_value, a.sql_text
 from v$sql a
where a.hash_value = 2080611240



