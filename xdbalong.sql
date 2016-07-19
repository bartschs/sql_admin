column sid       format 999999  heading "SID"
column username  format a10     heading "User"
column operation format a50     heading "Operation"
column pct       format 999.9   heading "% done"
column finish                   heading "Estimated Finish"

select sid,
       username, 
       opname||' '||target operation,
       (sofar * 100) / totalwork pct,
       last_update_time + (time_remaining / 86400) finish
  from v$session_longops
   where time_remaining > 0
   order by finish
/
