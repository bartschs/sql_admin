REM ------------------------------------------------------------------------ 
REM REQUIREMENTS: 
REM    N/A 
REM ------------------------------------------------------------------------ 
REM AUTHOR:  
REM    Chuck Blakey  - Oracle WW-SUP 30-OCT-95 
REM ------------------------------------------------------------------------ 
REM PURPOSE: 
REM    This script is used to provide an estimate of the number of   
REM    blocks needed for a table's initial extent.   
REM   
REM    NOTES 1) You must have calculated Average Row Length by hand   
REM             or obtained the value from analyzing the existing   
REM             table.   
REM          2) The accurate value for Initrans is NOT I*23 but   
REM             I*24 bytes.   
REM          3) When you compare the actual number of blocks used   
REM             with the calculated number of blocks, be sure to   
REM             add one block for each extent allocated. These   
REM             blocks hold the block header information.   
REM   
REM    Here are the formulas used.   
REM                                  number of rows in table   
REM    number of blocks = CEIL -------------------------------------   
REM                                  number of rows per block   
REM   
REM                                      available bytes per block   
REM    number of rows per block = FLOOR -----------------------------   
REM                                      data bytes + overhead bytes 
REM  
REM  
REM ------------------------------------------------------------------------ 
REM EXAMPLE: 
REM    SQL> @size 
REM    Enter the Oracle Block Size: 4048 
REM    Enter the number of Rows:    1000 
REM    Enter Percent Free:          20 
REM    Enter Init Trans:            1 
REM    Enter Average Row Length:    500 
REM    Enter number of columns with 250 bytes or less:   10 
REM    Enter number of columns with more than 250 bytes: 2 
REM 
REM    BLOCKS 
REM    ---------- 
REM           167 
REM  
REM ------------------------------------------------------------------------ 
REM DISCLAIMER: 
REM    This script is provided for educational purposes only. It is NOT  
REM    supported by Oracle World Wide Technical Support. 
REM    The script has been tested and appears to work as intended. 
REM    You should always run new scripts on a test instance initially. 
REM ------------------------------------------------------------------------ 
REM Main text of script follows: 
 
ACCEPT v_blksize PROMPT 'Enter the Oracle Block Size: .................... '   
ACCEPT v_rows PROMPT    'Enter the number of Rows: ....................... '   
ACCEPT v_pctf PROMPT    'Enter Percent Free: ............................. '   
ACCEPT v_initr PROMPT   'Enter Init Trans: ............................... '   
ACCEPT v_avg PROMPT     'Enter Average Row Length: ....................... '   
ACCEPT v_250c PROMPT    'Enter number of columns with 250 bytes or less: . '   
ACCEPT v_251c PROMPT    'Enter number of columns with more than 250 bytes: '   
   
SELECT    
 CEIL ( (&v_rows)/   
 FLOOR ((&v_blksize-(&v_initr * 24)-57-4)*(1-(&v_pctf/100)) /   
       (&v_avg+2+3+&v_250c+(3 * &v_251c))) ) BLOCKS   
FROM dual   
/   
SET ECHO on   
   
 

undefine v_blksize 
undefine v_rows 
undefine v_pctf 
undefine v_initr 
undefine v_avg 
undefine v_250c 
undefine v_251c 
