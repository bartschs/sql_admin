rem NAME
rem    printl.sql
rem FUNCTION
rem    print long text > 256 Chars
rem NOTE
rem    
rem MODIFIED
rem    11.07.2002 SBartsch  - made it
rem

set trimspool on;
set verify off;
set feedback off;
set heading off;

clear columns
clear breaks
clear computes

ttitle off
btitle off

prompt
prompt ------------------------------------------------------;
prompt User SQL View Report
prompt ------------------------------------------------------;
prompt
accept ownname  char prompt 'Owner Name: [] ';
accept viewname char prompt 'View Name:  [] ';
accept filename char prompt 'Spool File: [] ' default '&TMPDIR.sqlview.lst' ;
prompt ------------------------------------------------------;
prompt

rem
rem get current DB Name
rem

rem set termout off
define dbname=xxx
column currname new_value dbname
select global_name currname from global_name;
rem set termout on

spool &&filename

select '------------------------------------------------------'|| chr(10) ||
       'User SQL View Report'|| chr(10) ||
       '------------------------------------------------------'|| chr(10) ||
       'Database Name :  &&dbname'|| chr(10) ||
       'User Name     :  '||user||' '|| chr(10) ||
       'Run On        :  '||sysdate||' '|| chr(10) ||
       'Owner Name    :  &&ownname'|| chr(10) ||
       'View Name     :  &&viewname'|| chr(10) ||
       'Spool File    :  &&filename'|| chr(10) ||
       '------------------------------------------------------'|| chr(10) from dual
/

set heading on;
set feedback on;

set serveroutput on

create or replace procedure xxx$pa_print_long
as
--declare
  i_owner        varchar2(30) := NVL('&&ownname','%');
  i_view_name    varchar2(30) := NVL('&&viewname','%');

  l_owner        varchar2(30);
  l_view_name    varchar2(30);

  --l_sql_text     varchar2(4000);
  l_sql_text     VARCHAR2(32000);

  line_counter   NUMBER := 0;

  TYPE source_type IS TABLE OF VARCHAR2(1000) INDEX BY BINARY_INTEGER;
  source source_type;

  TYPE tab_vc256 IS TABLE OF VARCHAR2(256) INDEX BY BINARY_INTEGER;

   g_ml_line_width   CONSTANT NUMBER      := 100;          -- Line Width
   g_ml_pref_sep     CONSTANT CHAR(1)     := ',';          -- Preferred Separator Character
   g_ml_src_trunc    CONSTANT NUMBER      := 32000;        -- Trunc source to (0 = No truncation)
   g_ml_prefix       CONSTANT VARCHAR2(10):= '';           -- Multi-Line prefix
   g_ml_suffix       CONSTANT VARCHAR2(10):= '';           -- Multi-Line suffix

   ---------------------------------------
   PROCEDURE print_source IS
      i BINARY_INTEGER;
   BEGIN
      IF source.COUNT > 0 THEN
         FOR i IN source.FIRST .. source.LAST LOOP
           dbms_output.put_line(source(i));
         END LOOP;
      END IF;
      source.DELETE;
   END;

   ---------------------------------------
   PROCEDURE add_source (i_line IN VARCHAR2) IS
   BEGIN
      line_counter := line_counter + 1;
      source(source.COUNT+1) := i_line;
-- DEBUG
-- print_source;
   END;

   PROCEDURE add_source (
      i_line IN tab_vc256
   )
   IS
   BEGIN
      FOR i IN i_line.FIRST .. i_line.LAST LOOP
         line_counter := line_counter + 1;
         source(source.COUNT+1) := i_line(i);
      END LOOP;
-- DEBUG
-- print_source;
   END;

   ---------------------------------------
   -- Routines for Multi-Line-Output
   ---------------------------------------
   --
   FUNCTION ML_Put_Line (
       i_source  IN VARCHAR2            -- Source Text
      ,i_linwid  IN NUMBER := 70        -- Line Width
      ,i_prfsep  IN VARCHAR2 := ','     -- Preferred Separator Character
      ,i_srctrc  IN NUMBER := 0         -- Trunc source to
      ,i_prefix  IN VARCHAR2 := NULL    -- Prefix
      ,i_suffix  IN VARCHAR2 := NULL    -- Suffix
   )
   RETURN tab_vc256
   IS
       lv_width   NUMBER;             -- Width  of this ML Region
       lv_work    VARCHAR2(32767);    -- Working Storage String
       lv_line    VARCHAR2(32767);    -- Current Lineful of Wrapped Text
       lv_lineno  NUMBER;             -- Current ML Region Line Number
       lv_errcode NUMBER;
      --
      -- The broken line below is intentional
      l_nl_char  constant  char(1) := '
';
      l_carriage_return CONSTANT VARCHAR2(1) := CHR(10);
      --
      -- Container for Source information (PL/SQL Table)
      l_source tab_vc256;
      --
      -- store pointers of trace container
      l_first  BINARY_INTEGER := 1;
      l_last   BINARY_INTEGER := 1;
      l_count  BINARY_INTEGER := 0;
      l_from   BINARY_INTEGER := 1;
      l_to     BINARY_INTEGER := 1;
      --
      l_line_counter NUMBER := 0;
      l_first_cycle  BOOLEAN := TRUE;
      --
      l_put_stack CONSTANT VARCHAR2(30) := 'apr$pa_tools_ML_PUT_LINE';
      l_currmod VARCHAR2(128);
      l_prevmod VARCHAR2(128);
      l_loc_ident INTEGER := 0;
      --
      -------------------- Private Routines ---------------------------
      --
      ---------------------------------------
      PROCEDURE add_source (i_line IN VARCHAR2) IS
      BEGIN
         l_line_counter := l_line_counter + 1;
         l_source(l_source.COUNT+1) := i_line;
      END;
      --
      ---------------------------------------
      PROCEDURE skip IS
      BEGIN
         add_source('');
      END;
      --
      ---------------------------------------
      PROCEDURE ML_NextLine (
          i_source  IN varchar2          -- Source String
         ,i_linwid  IN number            -- Line Width
         ,i_prfsep  IN varchar2 := ','   -- Preferred Separator Character
         ,o_nxtlin  OUT varchar2         -- First Wrapped Line
         ,o_remain  OUt varchar2         -- Remaining Text
      )
      IS
          lv_lensrc    number;            -- Length of Source String
          lv_tmp       number;            -- Temporary Copy of Wrap-Field Width
          lv_linefeed  number := 0;       -- Check for Linefeeds Width
          lv_chr10     number := 0;       -- Hex '0A'
          lv_chr13     number := 0;       -- Hex '0D'
          lv_chr21     number := 0;       -- Hex '15'
      BEGIN
          --
          -- Setup Initial Values
          --
          lv_lensrc := length( i_source );
          --
          -- Check source string for special characters (linefeed, CR etc.)
          --
          lv_chr10 := instr(substr(i_source, 1, i_linwid)
                            ,chr(10));
          lv_chr13 := instr(substr(i_source, 1, i_linwid)
                            ,chr(13));
          lv_chr21 := instr(substr(i_source, 1, i_linwid)
                            ,chr(21));
          IF (lv_chr10 <> 0) THEN
              lv_linefeed := lv_chr10;
          END IF;
          IF (lv_chr13 <> 0 AND lv_chr13 < lv_linefeed) THEN
              lv_linefeed := lv_chr13;
          END IF;
          IF (lv_chr21 <> 0 AND lv_chr21 < lv_linefeed) THEN
              lv_linefeed := lv_chr21;
          END IF;
          --
          -- If what we're being asked to wrap is longer than the
          -- space in which we're being asked to wrap it...
          -- ... and there are no special characters found
          --
          if ( lv_linefeed = 0 ) THEN
              if ( lv_lensrc > i_linwid ) THEN
                  lv_tmp := i_linwid;
                  if ( substr( i_source, i_linwid + 1, 1) <> ' ') THEN
                      --
                      -- Work our way backwards from the cutoff point, in
                      -- search of a place to break the line, either a space
                      -- or the preferred separator character
                      --
                      while ( lv_tmp <> 0 )
                      lOOP
                          exit when (substr(i_source,lv_tmp,1) in (' ', i_prfsep));
                          lv_tmp := lv_tmp - 1;
                      END LOOP;
                      --
                      -- If we walked all the way backwards through the string
                      -- without ever finding a place to break it off, then we
                      -- just cut the string clean at the wrap-field length
                      --
                      if ( lv_tmp = 0 ) THEN
                         lv_tmp := i_linwid;
                      END IF;
                  END IF;
                  o_nxtlin := substr( i_source, 1, lv_tmp );
                  o_remain := ltrim( substr( i_source, lv_tmp + 1), ' ');
              ELSE
                  o_nxtlin := i_source;
                  o_remain := null;
              END IF;
              --
              -- We've found special characters
              --
          ELSE
              o_nxtlin := substr( i_source, 1, lv_linefeed -1 );
              o_remain := substr( i_source, lv_linefeed + 1);
          END IF;
      END;
      --
      ---------------------------------------
   BEGIN
       --
       -- Setup Initial/Default Values
       --
       lv_lineno := 0;

       IF (i_source IS NULL)
       THEN
           lv_work := NULL;
       ELSE
           lv_work := i_source;
       END IF;

       IF (i_srctrc <> 0)
       THEN
           lv_work := SUBSTR(lv_work,1, i_srctrc);
       END IF;

       --
       -- Keep Looping until the Workstring has been completely
       -- separated (in wrapped lines) into Multi(ple) Lines
       --
       WHILE ( lv_work IS NOT NULL )
       LOOP
           --
           -- Get the next linefull of text from 'lv_work', leaving
           -- what's left back in 'lv_work'.
           --
           ML_NextLine(lv_work, i_linwid, i_prfsep, lv_line, lv_work);
           IF ( lv_line IS NOT NULL )
             THEN
               lv_lineno := lv_lineno + 1;
               -- push source stack
               add_source(i_prefix || lv_line || i_suffix);
           END IF;
      END LOOP;
      RETURN l_source;
   EXCEPTION
   WHEN VALUE_ERROR
   THEN
       add_source('--ERROR: Input line too long ('|| TO_CHAR(LENGTH(i_source))|| ')');
       RETURN l_source;
   WHEN OTHERS
   THEN
       add_source('--ERROR: '||i_source);
       RETURN l_source;
   END;

begin
  dbms_output.enable(1000000);

  l_owner := i_owner;
  l_view_name := i_view_name;

  dbms_output.put_line('Owner     -> '||l_owner);
  dbms_output.put_line('View Name -> '||l_view_name);

  for view_info in (  
      select view_name, text 
        from all_views 
       where owner like upper(nvl(l_owner||'%','%'))
         and view_name like upper(nvl('%'||l_view_name'%','%'))
       order by owner, view_name
      )
  loop

    dbms_output.put_line('View Name -> '||view_info.view_name);
    --
    dbms_output.put_line('View Text -> ');
/*
    add_source( ml_put_line (view_info.text
                            ,g_ml_line_width   
                            ,g_ml_pref_sep    
                            ,g_ml_src_trunc  
                            ,g_ml_prefix
                            ,g_ml_suffix
                           ));
    print_source;
*/
    --
  end loop;
end;
/

spool off;

undefine dbname
undefine ownname
undefine viewname
undefine filename

