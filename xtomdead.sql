

   Tom,

   I have been digging into lock investigation using a combination of scripts and 
   ideas from your book, your website, Metalink, Oracle Internal Services by Steve 
   Adams, etc. I think I have learned some useful things.

   But I have a baffling situation...
   We have a situation with our 3rd party app, where INSERT statements are being 
   blocked. These appear to be just plain old insert statements. The blocker is 
   blocking them with a lock_mode/type of 6/TX. The waiters are waiting with a 
   lock_mode/type of 4/TX.

   What could the blocker possibly be doing to block an insert statement?

   Thanks,

   Robert. 


    Followup: 
    o look for unindexed foreign keys
    o unique/primary key constraints (both inserting same value)



    eg:

    ops$tkyte@ORA817DEV> create table p ( x int primary key );
    Table created.

    ops$tkyte@ORA817DEV> create table c ( x references p );
    Table created.

    ops$tkyte@ORA817DEV> insert into p values ( 1 );
    1 row created.

    ops$tkyte@ORA817DEV> insert into p values ( 2 );
    1 row created.

    ops$tkyte@ORA817DEV> insert into c values ( 2 );
    1 row created.

    ops$tkyte@ORA817DEV> commit;
    Commit complete.

    ops$tkyte@ORA817DEV> update p set x = 1 where x = 1;
    1 row updated.

    that'll lock the child table in 8i and below...


    ops$tkyte@ORA817DEV> insert into p values ( 3 );
    1 row created.

    that'll block anyone from inserting into p the value 3


    ops$tkyte@ORA817DEV> select SID, TYPE, ID1, ID2, LMODE,
      2        (select object_name from user_objects where object_id=id1) oname,
      3             block
      4    from v$lock
      5   where sid = (select sid from v$mystat where rownum=1 )
      6   or block = 1;

           SID TY        ID1        ID2      LMODE ONAME           BLOCK
    ---------- -- ---------- ---------- ---------- ---------- ----------
            10 TM      51210          0          3 P                   0
            10 TM      51212          0          4 C                   0
            10 TX     262198       5165          6                     0

    ops$tkyte@ORA817DEV>
    ops$tkyte@ORA817DEV> set echo off
    either run:
    insert into c values(2)
    insert into p values(3)
    in another session and then hit / again here...

    this is after trying to insert into C:

    ops$tkyte@ORA817DEV> /

           SID TY        ID1        ID2      LMODE ONAME           BLOCK
    ---------- -- ---------- ---------- ---------- ---------- ----------
            10 TM      51210          0          3 P                   0
            10 TM      51212          0          4 C                   1
            10 TX     262198       5165          6                     0

    and then I ctl-c'ed and tried to insert into P


    ops$tkyte@ORA817DEV> /

           SID TY        ID1        ID2      LMODE ONAME           BLOCK
    ---------- -- ---------- ---------- ---------- ---------- ----------
            10 TM      51210          0          3 P                   0
            10 TM      51212          0          4 C                   0
            10 TX     262198       5165          6                     1

     
