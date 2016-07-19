rem NAME
rem   sqlarea.sql
rem FUNCTION
rem   search for SQL text within SQL Area 
rem NOTE
rem   start from SQL*Plus as user
rem MODIFIED
rem   29.04.03 SBartsch - made it
rem


set verify off;
set linesize 100;
set arraysize 4;
set long 10000;
set maxdata 30000;
set pagesize 200;
set heading off;
set feedback off;

clear columns
clear breaks
clear computes

ttitle off
btitle off

prompt
prompt -----------------------------------------------------------;
prompt SQL Area Report
prompt -----------------------------------------------------------;
prompt
--accept objtext  char prompt 'Stored Object Text:  [] ';
accept filename char prompt 'Spool to <filename>: [] ' default '&TMPDIR.xsqltext.lst';


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
       'SQL Area Report'|| chr(10) ||
       '------------------------------------------------------'|| chr(10) ||
       'Database Name  :  &&dbname'|| chr(10) ||
       'User Name      :  '||user||' '|| chr(10) ||
       'Run On         :  '||sysdate||' '|| chr(10) ||
       'Spool File     :  &&filename'|| chr(10) ||
       '------------------------------------------------------'|| chr(10) from dual
/

column module     new_value varmodule noprint
column action     new_value varaction noprint

column varmodule  format a15
column varaction  format a10

break on module skip 1 -
      on action skip page 


ttitle left '--------------------------------------' skip 1 -
            'Module: ' varmodule  skip 1 -
            'Action: ' varaction  skip 1 -
	    '--------------------------------------' skip 1 -
	    '                                      '

--select a.module, a.action, a.sorts, t.sql_text 
select a.module, a.action, t.sql_text 
  from v$sqlarea a, v$sqltext t
 where a.address = t.address 
   and a.hash_value = t.hash_value
/

-- order by a.module, a.action, t.piece
spool off;

undefine filename


/*
select a.module, a.action, a.sorts, a.sql_text 
  from v$sqlarea a
/
*/

/*
select t.sql_text 
  from v$sqltext t
group by t.piece, t.sql_text
/
*/

/*
select * 
      from (
    select address, hash_value, 
           lag(sql_text) over (partition by address, hash_value order by piece) ||
           sql_text ||
           lead(sql_text) over (partition by address, hash_value order by piece) 
              sql_text
      from v$sqltext_with_newlines
           )
     where upper(sql_text) like '%BEGIN%'
    /
*/

/*
select sql_text
      from v$sqlarea vsa,
           v$session vs,
           v$transaction vt
     where vsa.address = vs.sql_address
       and vsa.hash_value = vs.sql_hash_value
       and vs.taddr = vt.addr
       and bitand(vt.flag,power(2,7))>0;
*/

/*
select sql_text,USERNAME,SID,SERIAL#,OSUSER,TERMINAL, flag,'rolling_back'
      from v$sqlarea vsa,
           v$session vs,
           v$transaction vt
     where vsa.address = vs.sql_address
       and vsa.hash_value = vs.sql_hash_value
       and vs.taddr = vt.addr
       and bitand(vt.flag,power(2,7))>0
*/

--select sql_text
--     from v$sqltext_with_newlines
--     where command_type in ( 2 /* inserts */,
--     3 /* selects */,
--     6 /* update */,
--     7 /* delete */ ,
--     47 /* plsql */ )
--     order by address, hash_value, piece
--/

/*


    Right on dot, as always. What's the purpose of the FLAG column in v$transaction? 
    I see that while rolling back, it's 7811 and an ongoing transaction has 7683. 
    What other values are possible and what do they indicate? 


    Followup: 
    They are undocumented bit flags actually -- it is not the numbers 7811 and 7683 
    so much as the HEX:

    ops$tkyte@ORA920> select to_char( 7811, '0000000X' ), to_char( 7683, '0000000X' 
    ) from dual;

    TO_CHAR(7 TO_CHAR(7
    --------- ---------
     00001E83  00001E03
           ^         ^

    0 indicates "normal user transaction"
    8 indicates "rollback,most likely - means no more changes and you cannot commit"

select sql_text,USERNAME,SID,SERIAL#,OSUSER,TERMINAL, flag
      from v$sqlarea vsa,
           v$session vs,
           v$transaction vt
     where vsa.address = vs.sql_address
       and vsa.hash_value = vs.sql_hash_value
       and vs.taddr = vt.addr
       and bitand(vt.flag,power(2,7))=0

select v$session.* 
      from v$session, v$transaction 
     where v$session.saddr = v$transaction.ses_addr;

It's a bitmap, so, look at the two numbers in binary:
    7811 = 0001 1110 1000 0011 = active transaction, no rollback
    7683 = 0001 1110 0000 0011 = rollback in progress

    Note that the numbers only differ by one bit.  Looking
    at the numbers in decimal, it's not obvious, but in binary
    it sure is.

    So, Starting with the right, counting left, and starting
    with the first bit on the right is bit 0, we can see that
    bit 7 is the bit that identifies a transaction that's being
    rolled back.  So, to check if bit 7 is set, you can write:
    "where bitand(flag,power(2,7))<>0"

    If you ever learn what the meaning of the other bits is,
    you can check those too.  For example, if bit 28 is set,
    that's a transaction with the SERIALIZABLE isolation level.

*/

/*
select username, v$lock.sid, 
    trunc(id1/power(2,16)) rbs, 
    bitand(id1,to_number('ffff','xxxx'))+0 slot, 
    id2 seq, lmode, request, block
    from v$lock, v$session
    where v$lock.type='TX'
    and v$lock.sid=v$session.sid
    and v$session.username=USER

To to show that you learn new things every day -- between the time I wrote the 
    book and now -- I've found an easier way:

    ops$tkyte@ORA920> select dbms_transaction.local_transaction_id from dual;

    LOCAL_TRANSACTION_ID
    -----------------------
    13.36.60919

    ops$tkyte@ORA920> select XIDUSN, XIDSLOT,XIDSQN from v$transaction;

        XIDUSN    XIDSLOT     XIDSQN
    ---------- ---------- ----------
            13         36      60919


    but yes, it would work with UNDO tablespaces since they are just rollback 
    segments in disguise.   

1)  SCNs are just numbers.  Think of the base and the wrap as a way to store an 
    even bigger number --  The wrap is incremented whenever an increment to the base 
    would result in an overflow (when the SCN would roll over to zero again).

    It will not always be zero, just depends on how many wraps you've done (roll 
    overs if you will)

    ps$tkyte@ORA817DEV> select start_scnw, start_scnb from v$transaction;

    START_SCNW START_SCNB
    ---------- ----------
          1683 4117418604



    2) see


    http://technet.oracle.com/docs/products/oracle8i/doc_library/817_doc/server.817/a76965/c23cnsis.htm#17882


    we use undo data to provide consistent reads

    3) we use the SCN and find the block that would be "most correct" -- the newest 
    block with the SCN greater than or equal to the SCN that was in place when your 
    transaction began.  The rollback segments give us this information.  It is 
    pretty much the same in 9iR2 as it was in 8i, 8.0, 7.x, 6.x...  tweaks and 
    optimizations but fundementally the same.
     
*/

/*
From ixora.au.com

    You should be able to calculate the number of slots for any database block size
    and for any given version from V$TYPE_SIZE without dumping a header block. For
    example for your 2K block size it goes like this:

          2048 bytes  db_block_size
        -   16 bytes  cache layer undo block header (KTUBH)
        -    4 bytes  cache layer tail
        -   72 bytes  extent control header (KTECH)
        -   44 bytes  extent map header (KTECT)
        -  960 bytes  extent table = extent entry * (maxextents - 1)
                      = 8 bytes (KTETB) * (db_block_size/16 - 8)
        -  104 bytes  transaction control header (KTUXC)
           =========
        =  848 bytes  for the transaction table
        /   40 bytes  per transaction table entry (KTUXE)
        =   21        transaction table slots!
            (8 bytes  unused)
*/
