CREATE OR REPLACE FUNCTION fk_level (p_table_name VARCHAR2) RETURN
NUMBER IS
   l_fk_level NUMBER := 0;
   l_level    NUMBER;
BEGIN
   FOR cur IN (
      SELECT parent.table_name
        FROM user_constraints child,
             user_constraints parent
       WHERE child.table_name = p_table_name
         AND child.constraint_type = 'R'
         AND parent.constraint_type IN ('P', 'U')
         AND child.r_constraint_name = parent.constraint_name
         AND child.table_name <> parent.table_name)
   LOOP
      SELECT fk_level (cur.table_name) + 1
        INTO l_level
        FROM DUAL;

      IF l_level > l_fk_level THEN
         l_fk_level := l_level;
      END IF;
   END LOOP;

   RETURN l_fk_level;
END;
/

/*
Note that you don't need statements: 


   AND child.constraint_type = 'R'
   AND parent.constraint_type IN ('P', 'U')

but without these statements, SELECT is very slow. Possible uses of fk_level function: 


SELECT fk_level (table_name) fk_level,
       table_name
  FROM user_tables -- or dba_tables
 ORDER BY
       fk_level,
       table_name
/


or 



SELECT table_name
  FROM user_tables -- or dba_tables
 ORDER BY
       fk_level (table_name),
       table_name
/

*/

