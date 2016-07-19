--set autotrace on;
set autotrace traceonly explain;
set timing on;
set trimspool on;

prompt
prompt ------------------------------------------------------;
prompt SQL Trace Report
prompt ------------------------------------------------------;
prompt
accept filename char prompt 'Spool SQL trace to <filename>: [] ' default '&TMPDIR.xtrcxpl.lst';
prompt ------------------------------------------------------;
prompt

spool &&filename
