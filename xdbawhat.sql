set trimspool on;
set verify off;
set linesize 100;
set arraysize 4;
--set long 10000;
--set maxdata 30000;
--set pagesize 100;
--set heading off;
set feedback off;

--set newpage 0
--set pagesize 0


prompt
prompt -----------------------------------------------------------;
prompt DB Process Overview Report
prompt -----------------------------------------------------------;
prompt
accept user_name  char prompt 'User Name: ....... : ' ;
accept sid        char prompt 'Oracle SID: ...... : ' ;
accept filename   char prompt 'Spool to <filename>: ' default '&TMPDIR.tsqlwhat.lst';

column status format a10

set feedback off;
set serveroutput on;

spool &&filename

select username, sid, serial#, process, status
from v$session
where username is not null
  and username like upper(nvl('&&user_name.%','%'))
  and sid = nvl('&&sid', sid)
order by 2
/

column username format a20
column sql_text format a55 word_wrapped

set serveroutput on size 1000000;

declare
    x number;
begin
    for x in
    ( select username||'('||sid||','||serial#||
                ') ospid = ' ||  process ||
                ' program = ' || program username,
             to_char(LOGON_TIME,'DD.MM.YYYY HH24:MI:SS') logon_time,
             to_char(sysdate,'DD.MM.YYYY HH24:MI:SS') current_time,
             sql_address, LAST_CALL_ET
        from v$session
       where status like '%ACTIVE'
         and rawtohex(sql_address) <> '00'
         and sid = nvl('&&sid', sid)
         and username like upper(nvl('&&user_name.%','%'))
         and username is not null order by last_call_et )
    loop
        for y in ( select max(decode(piece,0,sql_text,null)) ||
                          max(decode(piece,1,sql_text,null)) ||
                          max(decode(piece,2,sql_text,null)) ||
                          max(decode(piece,3,sql_text,null)) ||
                          max(decode(piece,4,sql_text,null)) ||
                          max(decode(piece,5,sql_text,null)) ||
                          max(decode(piece,6,sql_text,null)) ||
                          max(decode(piece,7,sql_text,null)) ||
                          max(decode(piece,8,sql_text,null)) ||
                          max(decode(piece,9,sql_text,null))
                               sql_text
                     from v$sqltext_with_newlines
                    where address = x.sql_address
                      and piece < 10)
        loop
            if ( y.sql_text not like '%listener.get_cmd%' and
                 y.sql_text not like '%RAWTOHEX(SQL_ADDRESS)%')
            then
                dbms_output.put_line( '--------------------' );
                dbms_output.put_line( x.username );
                dbms_output.put_line( x.logon_time || ' ' ||
                                      x.current_time||
                                      ' last et = ' ||
                                      x.LAST_CALL_ET);
                dbms_output.put_line(
                          substr( y.sql_text, 1, 250 ) );
            end if;
        end loop;
    end loop;
end;
/

column username format a25 word_wrapped
column module format a25 word_wrapped
column action format a15 word_wrapped
column client_info format a20 word_wrapped

select username||'('||sid||','||serial#||')' username,
       module,
       action,
       client_info
from v$session
where module||action||client_info is not null 
  and username like upper(nvl('&&user_name.%','%'))
  and sid = nvl('&&sid', sid)
order by 2
/


undefine filename

spool off;
