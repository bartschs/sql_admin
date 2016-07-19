set verify off;

variable l_last_refresh  VARCHAR2(20)
variable l_valid_from VARCHAR2(20)
variable l_valid_to VARCHAR2(20)

begin
  --:l_last_refresh := '25.07.2002 12:00:00';
  :l_last_refresh := '&&last_refresh';
  :l_valid_from := '01.01.-4712 00:00:00';
  :l_valid_to   := '30.12.4712 23:59:59';
end;
/

-- TO_DATE(:l_valid_to, 'dd.mm.yyyy hh24:mi:ss')
-- TO_DATE(:l_valid_from,'dd.mm.syyyy hh24:mi:ss')
