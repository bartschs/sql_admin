SELECT s.username, s.sid,  u.TABLESPACE, u.CONTENTS, u.extents, u.blocks
    FROM v$session s, v$sort_usage u
WHERE s.saddr = u.session_addr
/

/*
select ( select username from v$session where saddr = session_addr) uname
      ,v.* , s.sql_text
  from v$sort_usage v
      ,v$sql s
 where v.sqlhash = s.hash_value
/
*/

/*
select address, hash_value, executions, disk_reads, rows_processed, sorts,
       sql_text
 from v$sqlarea
 where disk_reads > 50000
 order by disk_reads desc
 /
*/
