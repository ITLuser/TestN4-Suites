@ECHO OFF
REM * ----------------------------------------------------------
REM * Set the ECN4 Options
REM * ----------------------------------------------------------

REM * Set the location of ECN4 home directory
REM * set ECN4_HOME=C:\N4\ECN4_Production

REM * Check that the ECN4_HOME has been set
if "%ECN4_HOME%" == "" goto EXIT

%ECN4_HOME%\bin\ecn4.bat stop
REM * Exit ECN4 if we reach this point
exit /b 0

:EXIT
echo The ECN4_HOME environment variable is not defined. Please define the ECN4_HOME environment variable either on
echo your system or within this script.
exit /b 1
:END
