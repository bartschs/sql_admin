rem NAME
rem   plscntr.sql
rem FUNCTION
rem   gets info about  user's contracts
rem NOTE
rem   start from specified user
rem MODIFIED
rem   11.01.99 SBartsch - made it
rem

set verify off
set linesize 100
set arraysize 4
set long 10000
set maxdata 30000
set pagesize 22;
set heading off
set feedback off

clear columns
clear breaks
clear computes

ttitle off
btitle off

column id          		format 999999
column package_name     format a30 heading 'PACKAGE'
column function_name	format a30 heading 'FUNCTION'
column param_name		format a30 heading 'NAME'
column param_group		format a15 heading 'GROUP'
column param_position	format 999999 heading 'POSITION'

spool &TMPDIR.plscntr

prompt
prompt -----------------------------------------------------------;
prompt User PL/SQL Contract Objects Report
prompt -----------------------------------------------------------;
prompt
accept objname  char prompt 'Object Name:   [] ';

set heading on;
select id, package_name, function_name from apr$ta_contract_function
where upper(package_name) like upper(nvl('%&&objname.%','%'))
order by id
/
set heading off;

column package_name		new_value varpack	noprint
column function_name	new_value varfunc	noprint
column id         		new_value varid		noprint

column varpack    format a20
column varfunc    format a20
column varid      format 999999

break on pack skip 1 -
      on id skip page

ttitle left '--------------------------------------' skip 1 -
            'Package:  ' varpack  skip 1 -
            'Function: ' varfunc  skip 1 -
            'ID: ' varid  skip 1 -
	    '--------------------------------------' skip 1 -
	    '                                      '

select package_name, function_name, p.id, p.param_position, p.param_name, p.param_group, p.max_rows
from apr$ta_contract_param p,
	 apr$ta_contract_function f1
where p.id = f1.id
and p.id in
(select f2.id from apr$ta_contract_function f2
  where upper(f2.package_name) like upper(nvl('%&&objname.%','%')))
order by p.id, p.param_position
/

prompt

spool off;

set heading on;
undefine objname
undefine varpack
undefine varfunc
undefine varid

clear columns
clear breaks
clear computes

ttitle off
btitle off

rem pause Press <Return> to continue;

rem exit
