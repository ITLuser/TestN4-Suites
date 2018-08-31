REM START "do something window" dir
REM TASKLIST /NH /FI "WINDOWTITLE eq Tomcat"
FOR /F "tokens=2" %%I IN ('TASKLIST /NH /FI "WINDOWTITLE eq Tomcat"' ) DO (SET PID=%%I)
ECHO %PID%
TASKKILL /PID %PID%