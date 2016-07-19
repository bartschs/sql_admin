select * from(
select sql_id, elapsed_time, rank() over (order by elapsed_time desc) as rank
from V$sql
) where rank <=10
/
