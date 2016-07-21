rem NAME
rem   analyze.sql
rem FUNCTION
rem   analyze user schema
rem NOTE
rem   start from user with DBA role
rem MODIFIED
rem   18.07.97 SBartsch - made it
rem

--  procedure analyze_object
--    (type varchar2, schema varchar2, name varchar2, method varchar2,
--     estimate_rows number default null,
--     estimate_percent number default null, method_opt varchar2 default null);
  --  Equivalent to SQL "ANALYZE TABLE|CLUSTER|INDEX [<schema>.]<name>
  --    [<method>] STATISTICS [SAMPLE <n> [ROWS|PERCENT]]"
  --  Input arguments:
  --    type
  --      One of 'TABLE', 'CLUSTER' or 'INDEX'.  If none of these, the
  --      procedure just returns.
  --    schema
  --      schema of object to analyze.  NULL means current schema.  Case
  --      sensitive.
  --    name
  --      name of object to analyze.  Case sensitive.
  --    method
  --      NULL or 'ESTIMATE'.  If 'ESTIMATE' then either estimate_rows
  --      or estimate_percent must be non-zero.
  --    estimate_rows
  --      Number of rows to estimate
  --    estimate_percent
  --      Percentage of rows to estimate.  If estimate_rows is specified
  --      than ignore this parameter.
  --    method_opt
  --      method options of the following format
  --      [ FOR TABLE ]
  --      [ FOR ALL [INDEXED] COLUMNS] [SIZE n]
  --      [ FOR ALL INDEXES ]
  --  Exceptions:
  --    ORA-20000: Insufficient privileges or object does not exist.
  --    ORA-20001: Bad value for object type.  Should be one of TABLE, INDEX
  --      or CLUSTER.

--  procedure analyze_schema(schema varchar2, method varchar2,
--    estimate_rows number default null,
--    estimate_percent number default null, method_opt varchar2 default null);
  --  Analyze all the tables, clusters and indexes in a schema.
  --  Input arguments:
  --    schema
  --      Name of the schema.
  --    method, estimate_rows, estimate_percent, method_opt
  --      See the descriptions above in sql_ddl.analyze.object.
  --  Exceptions:
  --    ORA-20000: Insufficient privileges for some object in this schema.

set verify off

prompt -----------------------------------------------------------;
prompt Schema Analysis;
prompt -----------------------------------------------------------;
accept schemaname char prompt 'Schema Name:          [] ';
accept method     char prompt 'Method:        [COMPUTE] ';
accept estrows    char prompt 'Estimate Rows:    [null] ';
accept estproc    char prompt 'Estimate Percent: [null] ';
prompt ;
prompt Working...(This will take a while);

declare
    schema_name      varchar2(30) := upper(nvl('&&schemaname', 'XXX'));
    analyze_method   varchar2(30) := upper(nvl('&&method', 'COMPUTE'));
    estimate_rows    number       := nvl('&&estrows', null);
    estimate_procent number       := nvl('&&estproc', null);
begin
    dbms_utility.analyze_schema(schema_name, analyze_method, 
                                estimate_rows, estimate_procent,
        'FOR TABLE FOR ALL INDEXED COLUMNS FOR ALL INDEXES');
end;
/
