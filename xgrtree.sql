rem NAME
rem   grtree.sql
rem FUNCTION
rem   Get Depth-first Grant Tree Traversal info
rem NOTE
rem   start from SQL*Plus as user
rem MODIFIED
rem   03.06.03 SBartsch - made it
rem

set serveroutput on size 1000000 format wrapped
set verify off;
set linesize 100;
set arraysize 4;
set long 10000;
set maxdata 30000;
set pagesize 100;
set heading off;
set feedback off;

clear columns
clear breaks
clear computes

ttitle off
btitle off

prompt
prompt -----------------------------------------------------------;
prompt Depth-first Grant Tree Traversal Report
prompt -----------------------------------------------------------;
prompt
accept dbuser    char prompt 'DB User: ........... [] ';
accept privilege char prompt 'Privilege: ......... [] ';
accept filename  char prompt 'Spool to <filename>: [] ' default '&TMPDIR.xsqltext.lst';


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
       'Depth-first Grant Tree Traversal Report'|| chr(10) ||
       '------------------------------------------------------'|| chr(10) ||
       'Database Name  :  &&dbname'|| chr(10) ||
       'User Name      :  '||user||' '|| chr(10) ||
       'Run On         :  '||sysdate||' '|| chr(10) ||
       'DB User        :  &&dbuser'|| chr(10) ||
       'Privilege      :  &&privilege'|| chr(10) ||
       'Spool File     :  &&filename'|| chr(10) ||
       '------------------------------------------------------'|| chr(10) from dual
/

set heading on;


 declare
  type ROLE_HIERARCHY_TYPE is record (
    granted_role dba_role_privs.granted_role%TYPE,
    level NUMBER (3,0)
  );
  type ROLE_HIERARCHY_TABLE_TYPE is table of ROLE_HIERARCHY_TYPE
    INDEX BY BINARY_INTEGER;
  rpp ROLE_HIERARCHY_TYPE;
  v_rp ROLE_HIERARCHY_TABLE_TYPE;
  i PLS_INTEGER := 1;
  cursor crp (p_grantee VARCHAR2) is
    select granted_role from dba_role_privs
    where grantee = p_grantee;
  cursor csp (p_grantee VARCHAR2) is
    select privilege from dba_sys_privs
    where grantee = p_grantee;
  cursor ctp (p_grantee VARCHAR2) is
    select privilege, owner, table_name from dba_tab_privs
    where grantee = p_grantee
    order by owner, table_name, privilege;
  tpp ctp%ROWTYPE;
  tp_concat VARCHAR2 (100);
begin
  v_rp (i).granted_role := upper('&&dbuser');
  v_rp (i).level := 0;
  while i > 0 loop
    rpp := v_rp (i);
    i := i - 1;
    dbms_output.put_line (rpad (' ', rpp.level * 2) || rpp.granted_role);
    for sp in csp (rpp.granted_role) loop
      dbms_output.put_line (rpad (' ', (rpp.level + 1) * 2) || sp.privilege);
    end loop;
    for tp in ctp (rpp.granted_role) loop
      if (tp.owner || '.' || tp.table_name <> tpp.owner || '.' ||
          tpp.table_name) and tpp.owner is not null then
        dbms_output.put_line (rpad (' ', (rpp.level + 1) * 2) || rpad
          (tpp.owner || '.' || tpp.table_name,40) || tp_concat);
        tp_concat := null;
      end if;
      tp_concat := tp_concat || tp.privilege || ' ';
      tpp := tp;
    end loop;
    if tpp.owner is not null then
      dbms_output.put_line (rpad (' ', (rpp.level + 1) * 2) || rpad
          (tpp.owner || '.' || tpp.table_name,40) || tp_concat);
    end if;
    for rp in crp (rpp.granted_role) loop
      i := i + 1;
      v_rp (i).granted_role := rp.granted_role;
      v_rp (i).level := rpp.level + 1;
    end loop;
  end loop;
end;
/

declare
  type ROLE_HIERARCHY_TYPE is record (
    grantee dba_role_privs.grantee%TYPE,
    level NUMBER (3,0)
  );
  type ROLE_HIERARCHY_TABLE_TYPE is table of ROLE_HIERARCHY_TYPE
    INDEX BY BINARY_INTEGER;
  rpp ROLE_HIERARCHY_TYPE;
  v_rp ROLE_HIERARCHY_TABLE_TYPE;
  i PLS_INTEGER := 1;
  cursor cstrp (p_grant VARCHAR2, p_role_only VARCHAR2) is
    select grantee from dba_sys_privs
    where privilege = p_grant
    and upper (p_role_only) = 'N'
    union all
    select grantee from dba_tab_privs
    where table_name = p_grant
    and upper (p_role_only) = 'N'
    union all
    select grantee from dba_role_privs
    where granted_role = p_grant;
  v_role_only VARCHAR2 (1) := 'N';
begin
  v_rp (i).grantee := upper('&&privilege');
  v_rp (i).level := 0;
  while i > 0 loop
    rpp := v_rp (i);
    i := i - 1;
    dbms_output.put_line (rpad (' ', rpp.level * 2) || rpp.grantee);
    for strp in cstrp (rpp.grantee, v_role_only) loop
      i := i + 1;
      v_rp (i).grantee := strp.grantee;
      v_rp (i).level := rpp.level + 1;
    end loop;
    v_role_only := 'Y';
  end loop;
end;
/

spool off;

undefine dbuser
undefine privilege

