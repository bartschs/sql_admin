SELECT to_char(startup_time, 'DD.MM.YYYY HH24:MI:SS') STARTUP
  FROM v$instance
 WHERE instance_number = 1
/
