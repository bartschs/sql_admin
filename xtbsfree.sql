rem NAME
rem   tbsfree.sql
rem FUNCTION
rem   Get Tablespace Free Space info
rem NOTE
rem   
rem MODIFIED
rem   29.04.03 SBartsch - made it
rem

set serveroutput on size 1000000 format wrapped;
set verify off; 
set feedback off; 
set trimspool on;
set heading off;

set long 20000;
set maxdata 60000;
set pagesize 2000;

clear columns
clear breaks
clear computes

ttitle off
btitle off

prompt
prompt -----------------------------------------------------------;
prompt Tablespace Free Space Report;
prompt -----------------------------------------------------------;
prompt
accept tbsname       char prompt 'Tablespace Name [%]: ' default '%';
accept sorting       char prompt 'Sort order:  [name]: ' default 'name';
accept filename      char prompt 'Spool to <filename>: ' default '&TMPDIR.xtbsfree.lst';

rem
rem get current DB Name
rem

set termout off
define dbname=xxx
column currname new_value dbname
select global_name currname from global_name;
set termout on

spool &&filename

select '------------------------------------------------------'|| chr(10) ||
       'Tablespace Free Space Report'|| chr(10) ||
       '------------------------------------------------------'|| chr(10) ||
       'Database Name  :  &&dbname'|| chr(10) ||
       'User Name      :  '||user||' '|| chr(10) ||
       'Run On         :  '||sysdate||' '|| chr(10) ||
       'Tablespace Name:  &&tbsname'|| chr(10) ||
       'Sort order:    :  &&sorting'|| chr(10) ||
       'Spool File     :  &&filename'|| chr(10) ||
       '------------------------------------------------------'|| chr(10) from dual
/

set heading on;

column  dummy        noprint
column  pct_used     format 999.9           heading "%|Used"
column  name         format a20             heading "Tablespace Name"
column  Kbytes       format 999,999,999,999 heading "KBytes"
column  used         format 999,999,999,999 heading "Used"
column  free         format 999,999,999,999 heading "Free"
column  largest      format 999,999,999     heading "Largest"
column  max_size     format 999,999,999     heading "MaxPoss|Kbytes"
column  pct_max_used format 999.9           heading "%|Max|Used"

break   on report
compute sum of kbytes on report
compute sum of free on report
compute sum of used on report
select name, kbytes, used, free, pct_used
from 
(
select 
      (select decode(extent_management,'LOCAL','*','') 
         from dba_tablespaces 
        where tablespace_name = b.tablespace_name) || 
       nvl(b.tablespace_name
      ,nvl(a.tablespace_name,'UNKOWN')) name
      ,kbytes_alloc kbytes
      ,kbytes_alloc-nvl(kbytes_free,0) used
      ,nvl(kbytes_free,0) free
      ,((kbytes_alloc-nvl(kbytes_free,0))/
                          kbytes_alloc)*100 pct_used
      ,nvl(largest,0) largest
      ,nvl(kbytes_max,kbytes_alloc) Max_Size
      ,decode( kbytes_max, 0, 0, (kbytes_alloc/kbytes_max)*100) pct_max_used
from 
( select sum(bytes)/1024 Kbytes_free,
         max(bytes)/1024 largest,
           tablespace_name
  from  sys.dba_free_space
  group by tablespace_name
) a,
( select sum(bytes)/1024 Kbytes_alloc,
         sum(maxbytes)/1024 Kbytes_max,
   	           tablespace_name
  from sys.dba_data_files
  group by tablespace_name
  union all
  select sum(bytes)/1024 Kbytes_alloc,
         sum(maxbytes)/1024 Kbytes_max,
 	           tablespace_name
  from sys.dba_temp_files
  group by tablespace_name 
) b
where a.tablespace_name (+) = b.tablespace_name
)
 where name like upper('%&&tbsname%')
order by &&sorting
/
 
spool off;

undefine tbsname
undefine sorting
undefine filename

