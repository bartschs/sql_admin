rem NAME
rem   plsver.sql
rem FUNCTION
rem   get version No of PL/SQL Package
rem NOTE
rem   start from user with execute grant 
rem MODIFIED
rem   28.10.99 SBartsch - made it
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
prompt Package Version Report
prompt -----------------------------------------------------------;
accept pkgname char  prompt 'PL/SQL Package Name:    [] ';
accept pkgver  char  prompt 'PL/SQL Package Version: [] ';
accept errmsg  char  prompt 'PL/SQL Error Message:  [0] ' default '0'; 
accept filename char prompt 'Spool to <File>:        [] ' default '&TMPDIR.plsver.lst';

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
       'Package Version Report'|| chr(10) ||
       '------------------------------------------------------'|| chr(10) ||
       'Database Name   :  &&dbname'|| chr(10) ||
       'User Name       :  '||user||' '|| chr(10) ||
       'Run On          :  '||sysdate||' '|| chr(10) ||
       'Package Name    :  &&pkgname'|| chr(10) ||
       'Package Version :  &&pkgver'|| chr(10) ||
       'Print SQLERRM   :  &&errmsg'|| chr(10) ||
       'Spool File      :  &&filename'|| chr(10) ||
       '------------------------------------------------------'|| chr(10) from dual
/

declare
    l_pkg_name      varchar2(30) := upper(nvl('&&pkgname', '%'));
    l_pkg_ver       varchar2(30) := nvl('&&pkgver', NULL);
    l_errmsg        boolean := ( '1' = '&&errmsg');
    --
    l_cursor      INTEGER;
    l_rc          INTEGER;
    --
    l_stmnt    VARCHAR2(32767);
    l_version  VARCHAR2(30);

    cursor c_packages (
	i_pkg_name VARCHAR2
    )
    IS
       select distinct object_name pkg_name
         from all_objects
        where object_name like upper(nvl('%'||i_pkg_name||'%','%'))
          and object_type in ('PACKAGE', 'PACKAGE BODY', 'FUNCTION', 'PROCEDURE', 'TRIGGER')
       -- and object_name like upper('%$PA%')
        order by 1
       ;

begin
    dbms_output.put_line('-----------------------------------------------------------');
    dbms_output.put_line('Package Version Report');
    dbms_output.put_line('-----------------------------------------------------------');
    --dbms_output.put_line('DEBUG -> Input Package Name:    '||l_pkg_name);
    --dbms_output.put_line('DEBUG -> Input Package Version: '||l_pkg_ver);
    --
    dbms_output.put_line('------------------------------------------------');
    dbms_output.put_line('Package Name:                 '||'  '||'Version:');
    dbms_output.put_line('------------------------------------------------');
    for cloop in c_packages(l_pkg_name) loop
	--
	begin
            l_stmnt := 
            'declare '||
            '  l_version  VARCHAR2(30); '||
            'begin '||
            '  :version := '||cloop.pkg_name||'.version; '||
            'end;'; 
            --
            l_cursor := dbms_sql.open_cursor;
            dbms_sql.parse(l_cursor, l_stmnt, dbms_sql.native);
            dbms_sql.bind_variable(l_cursor, ':version', l_version, 30);
            l_rc := dbms_sql.execute(l_cursor);
            dbms_sql.variable_value(l_cursor, ':version', l_version);
            dbms_sql.close_cursor(l_cursor);
            --
            if l_pkg_ver is null then
               dbms_output.put_line(rpad(cloop.pkg_name, 30, ' ')||'  '||l_version);
            else
               --if l_pkg_ver = l_version then
               if instr(l_version, l_pkg_ver) > 0 then
                  dbms_output.put_line(rpad(cloop.pkg_name, 30, ' ')||'  '||l_version);
               end if;
            end if;
        exception
            when others then
                if l_errmsg then
                   dbms_output.put_line(rpad(cloop.pkg_name, 30, ' ')||'  '||SQLERRM);
                else
                   if l_pkg_ver is null then
                      dbms_output.put_line(rpad(cloop.pkg_name, 30, ' ')||'  '||'UNKNOWN');
                   end if;
                end if;
        end;
        --
    end loop;
    --
    dbms_output.put_line('------------------------------------------------');
exception
    when others then
         dbms_output.put_line('ERROR -> Package Name: '||l_pkg_name);
         dbms_output.put_line('ERROR -> SQL-Stmnt: '||substr(l_stmnt, 1, 200));
         raise;
end;
/

prompt ;

undefine pkgname
undefine pkgver
undefine errmsg
undefine filename

spool off;
