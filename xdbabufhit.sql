select  sum(decode(NAME, 'consistent gets',VALUE, 0)) consistent_Get ,
    sum(decode(NAME, 'db block gets',VALUE, 0)) db_blk_read,
    sum(decode(NAME, 'physical reads',VALUE, 0)) phy_read,
    round((sum(decode(name, 'consistent gets',value, 0)) +
           sum(decode(name, 'db block gets',value, 0)) -
           sum(decode(name, 'physical reads',value, 0))) /
          (sum(decode(name, 'consistent gets',value, 0)) +
           sum(decode(name, 'db block gets',value, 0))) * 100,2) hit_ratio
   from   v$sysstat
/
