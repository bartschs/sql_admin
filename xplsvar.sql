rem NAME
rem   plsvar.sql
rem FUNCTION
rem   get variable value of PL/SQL Package
rem NOTE
rem   start from user with execute grant 
rem MODIFIED
rem   01.02.01 SBartsch - made it
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

prompt -----------------------------------------------------------;
prompt Variable Value Report
prompt -----------------------------------------------------------;
accept pkgname char  prompt 'PL/SQL Package Name:  [] ';
accept varname char  prompt 'PL/SQL Variable Name: [] ';
accept filename char prompt 'Spool to <File>:      [] ' default '&TMPDIR.plsvar.lst';

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
       'Variable Value Report'|| chr(10) ||
       '------------------------------------------------------'|| chr(10) ||
       'Database Name :  &&dbname'|| chr(10) ||
       'User Name     :  '||user||' '|| chr(10) ||
       'Package Name  :  &&pkgname'|| chr(10) ||
       'Variable Name :  &&varname'|| chr(10) ||
       'Spool File    :  &&filename'|| chr(10) ||
       '------------------------------------------------------'|| chr(10) from dual
/

declare
    l_pkg_name      varchar2(30) := upper(nvl('&&pkgname', '%'));
    l_var_name      varchar2(30) := upper(nvl('&&varname', 'VERSION'));
    --
    l_cursor      INTEGER;
    l_rc          INTEGER;
    --
    l_stmnt  VARCHAR2(32767);
    l_value  VARCHAR2(30);

    cursor c_packages (
	i_pkg_name VARCHAR2
    )
    IS
       select distinct object_name pkg_name
         from all_objects
        where object_name like upper(nvl('%'||i_pkg_name||'%','%'))
          and object_type in ('PACKAGE', 'PACKAGE BODY', 'FUNCTION', 'PROCEDURE', 'TRIGGER')
       -- and object_name like upper('%$PA%')
       ;

begin
    dbms_output.put_line('-----------------------------------------------------------');
    dbms_output.put_line('Variable Value Report');
    dbms_output.put_line('-----------------------------------------------------------');
    --dbms_output.put_line('DEBUG -> Package Name:  '||l_pkg_name);
    --dbms_output.put_line('DEBUG -> Variable Name: '||l_var_name);
    --
    dbms_output.put_line('-----------------------------------------------------------------------');
    --dbms_output.put_line('Package Name:                 '||'  '||'Variable Value:');
    dbms_output.put_line(rpad('Package Name:', 30, ' ')||'  '||
                         rpad('Variable:', 30, ' ')||'  '||'Value:');
    dbms_output.put_line('-----------------------------------------------------------------------');
    for cloop in c_packages(l_pkg_name) loop
	--
	begin
            l_stmnt := 
            'declare '||
            '  l_version  VARCHAR2(30); '||
            'begin '||
            '  :'||l_var_name||' := '||cloop.pkg_name||'.'||l_var_name||'; '||
            'end;'; 
            --
            l_cursor := dbms_sql.open_cursor;
            dbms_sql.parse(l_cursor, l_stmnt, dbms_sql.native);
            dbms_sql.bind_variable(l_cursor, ':'||l_var_name, l_value, 30);
            l_rc := dbms_sql.execute(l_cursor);
            dbms_sql.variable_value(l_cursor, ':'||l_var_name, l_value);
            dbms_sql.close_cursor(l_cursor);
            --
            --dbms_output.put_line(rpad(cloop.pkg_name, 30, ' ')||'  '||l_value);
            dbms_output.put_line(rpad(cloop.pkg_name, 30, ' ')||'  '||
			         rpad(l_var_name, 30, ' ')||'  '||l_value);
        exception
            when others then
                --dbms_output.put_line(rpad(cloop.pkg_name, 30, ' ')||'  '||'UNKNOWN');
                dbms_output.put_line(rpad(cloop.pkg_name, 30, ' ')||'  '||SQLCODE);
        end;
        --
    end loop;
    --
    dbms_output.put_line('-----------------------------------------------------------------------');
exception
    when others then
         dbms_output.put_line('ERROR -> Package Name: '||l_pkg_name);
         dbms_output.put_line('ERROR -> SQL-Stmnt: '||substr(l_stmnt, 1, 200));
         raise;
end;
/

prompt ;

undefine pkgname
undefine filename

spool off;
