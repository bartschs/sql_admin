rem NAME
rem   plstrig.sql
rem FUNCTION
rem   gets info about PL/SQL triggers
rem NOTE
rem   start from specified user
rem MODIFIED
rem   31.05.99 SBartsch - made it  
rem

/*
 Name                            Null?    Type
 ------------------------------- -------- ----
 OWNER                           NOT NULL VARCHAR2(30)
 TRIGGER_NAME                    NOT NULL VARCHAR2(30)
 TRIGGER_TYPE                             VARCHAR2(16)
 TRIGGERING_EVENT                         VARCHAR2(26)
 TABLE_OWNER                     NOT NULL VARCHAR2(30)
 TABLE_NAME                      NOT NULL VARCHAR2(30)
 REFERENCING_NAMES                        VARCHAR2(87)
 WHEN_CLAUSE                              VARCHAR2(2000)
 STATUS                                   VARCHAR2(8)
 DESCRIPTION                              VARCHAR2(2000)
 TRIGGER_BODY                             LONG
*/

set verify off;
set heading off;
set trimspool on;

set long 20000;
set maxdata 60000;
set pagesize 2000;

clear columns
clear breaks
clear computes

ttitle off
btitle off


column owner                    format a12
column trigger_name		format a30 
column trigger_type		format a30 
column triggering_event	        format a30 
column table_name		format a30
column status    		format a10


prompt
prompt -----------------------------------------------------------;
prompt User Trigger Report
prompt -----------------------------------------------------------;
prompt
accept ownname   char prompt 'Owner Name:          [] ';
accept trigname  char prompt 'Trigger Name:        [] ';
accept status    char prompt 'Trigger Status:      [] ';
accept filename  char prompt 'Spool to <filename>: [] ' default '&TMPDIR.plstrig.lst';
prompt
prompt ------------------------------------------------------;
prompt

spool &&filename

column owner                new_value var_owner                noprint
column trigger_name         new_value var_trigger_name         noprint
column trigger_type         new_value var_trigger_type         noprint
column triggering_event     new_value var_triggering_event     noprint
column table_name           new_value var_table_name           noprint
column status               new_value var_status               noprint

column var_owner                format a20
column var_trigger_name         format a30
column var_trigger_type         format a16
column var_triggering_event     format a26
column var_table_name           format a30
column var_status               format a10

spool &&filename

break on owner skip 1 -
      on trigger_name skip page

ttitle left '--------------------------------------' skip 1 -
            'Owner:          ' var_owner             skip 1 -
            'Trigger Name:   ' var_trigger_name      skip 1 -
            'Trigger Type:   ' var_trigger_type      skip 1 -
            'Trigger Event:  ' var_triggering_event  skip 1 -
            'Table Name:     ' var_table_name        skip 1 -
            'Status:         ' var_status            skip 1 -
            '--------------------------------------' skip 1 -
            '                                      '

select owner
      ,trigger_name
      ,trigger_type
      ,triggering_event
      ,table_name
      ,status
      ,trigger_body
  from all_triggers
 where owner like upper(nvl('%&&ownname.%','%'))
   and trigger_name like upper(nvl('%&&trigname.%','%'))
   and status like upper(nvl('%&&status.%','%'))
 order by owner, trigger_name
/
 
spool off;

undefine ownname
undefine trigname
undefine filename

set heading on;
set long 80;
set maxdata 60000;
set pagesize 22;

clear columns
clear breaks
clear computes

ttitle off
btitle off

rem pause Press <Return> to continue;

rem exit
  
