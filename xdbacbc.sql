reate or replace function to_hex( p_dec in number ) 
return varchar2
is
        l_str   varchar2(255) default NULL;
        l_num   number  default p_dec;
        l_hex   varchar2(16) default '0123456789ABCDEF';
begin
        if ( trunc(p_dec) <> p_dec OR p_dec < 0 ) then
                raise PROGRAM_ERROR;
        end if;
        loop
                l_str := substr( l_hex, mod(l_num,16)+1, 1 ) || l_str;
                l_num := trunc( l_num/16 );
                exit when ( l_num = 0 );
        end loop;
        return lpad(l_str,16,'0');
end to_hex;
/

undefine CBC_ADDR_P1
column segment_name format a35
set linesize 120

select /*+ RULE */
  e.owner ||'.'|| e.segment_name  segment_name,
  e.extent_id  extent#,
  x.dbablk - e.block_id + 1  block#,
  x.tch,
  l.child#,l.sleeps
from
  sys.v$latch_children  l,
  sys.x$bh  x,
  sys.dba_extents  e
where
  x.hladdr  = to_hex('&&CBC_ADDR_P1') and
  e.file_id = x.file# and
  x.hladdr = l.addr and
  x.dbablk between e.block_id and e.block_id + e.blocks -1
  order by x.tch desc ;
exit;
