rem NAME
rem   objwidth.sql
rem FUNCTION
rem   compute SQL objects width 
rem NOTE
rem   start from SQL*Plus as user
rem MODIFIED
rem   14.06.02 SBartsch - made it
rem


set trimspool on;
set verify off
set linesize 100
set arraysize 4
set long 10000
set maxdata 30000
set pagesize 0;
set heading off
set feedback off

clear columns
clear breaks
clear computes

ttitle off
btitle off

column referenced_name  format a30

prompt
prompt -----------------------------------------------------------;
prompt SQL Objects Width Report
prompt -----------------------------------------------------------;
prompt
accept ownname  char prompt 'Owner Name: .... [USER] ';
accept objname  char prompt 'Object Name........: [] ';
accept objtype  char prompt 'Object Type........: [] ';
accept objref   char prompt 'Referenced Object..: [] ';
accept filename char prompt 'Spool to <filename>: [] ' default '&TMPDIR.objwidth.lst';

spool &&filename

break on name on width on type skip 1

set colsep ',';

select 'NAME, REFERENCED_NAME, WIDTH' from dual
/

select distinct dep.name, dep.referenced_name, col.width
  from all_dependencies dep
      ,
       (select distinct x.owner, x.table_name, 
               sum(decode(x.data_type 
			             ,'NUMBER', NVL(x.data_precision, 22)
			             ,'DATE', 7 
						 , x.data_length)
		          ) width
          from all_tab_columns x 
         where x.table_name like upper(nvl('%&&objname.%','%'))
           and x.owner like upper(nvl('%&&ownname.%', USER))
         group by x.owner, x.table_name
       ) col
 where 
       dep.owner = col.owner
   and dep.name = col.table_name
   and dep.owner like upper(nvl('%&&ownname.%', USER))
   and dep.name like upper(nvl('%&&objname.%','%'))
   and dep.type like upper(nvl('%&&objtype.%','%'))
   and (dep.name not like 'RBI$VI_TMP_%')
   and (dep.referenced_name != 'STANDARD')
   and (dep.referenced_name != 'DUAL')
   and dep.referenced_name like upper(nvl('%&&objref.%','%'))
 group by dep.name, dep.referenced_name, col.width
 order by substr(dep.name, 12), substr(dep.name, 8), dep.referenced_name
/

spool off;

set heading on;
undefine objname
undefine objtype
undefine objtext
undefine varname
undefine vartype
undefine filename

clear columns
clear breaks
clear computes

ttitle off
btitle off

rem pause Press <Return> to continue;

rem exit

