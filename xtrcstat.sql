set autotrace traceonly explain statistics;
set timing on;
set trimspool on;

prompt
prompt ------------------------------------------------------;
prompt SQL Trace Report
prompt ------------------------------------------------------;
prompt
accept filename char prompt 'Spool SQL trace to <filename>: [] ' default '&TMPDIR.xtrcstat.lst';
prompt ------------------------------------------------------;
prompt

spool &&filename
