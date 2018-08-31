REM Copyright (c) 2010 Zebra Technologies Corp All Rights Reserved.
@echo off
if "%OS%" == "Windows_NT" setlocal

rem Gather command line arguments
set CMD=%1

rem Guess CATALINA_HOME if not defined
set CURRENT_DIR=%cd%
if not "%CATALINA_HOME%" == "" goto gotHome
set CATALINA_HOME=%CURRENT_DIR%
if exist "%CATALINA_HOME%\bin\shutdown.bat" goto okHome
cd ..
set CATALINA_HOME=%cd%
cd %CURRENT_DIR%
:gotHome
set EXECUTABLE=%CATALINA_HOME%\bin\shutdown.bat
if exist "%EXECUTABLE%" goto okHome
echo The CATALINA_HOME environment variable is not defined correctly
echo This environment variable is needed to run this program
goto end
:okHome
:checkExec

rem Set the cluster settings
if "%CMD%" == "node1" (
	set CATALINA_BASE=%CATALINA_HOME%\instances\node1
)
if "%CMD%" == "node2" (
	set CATALINA_BASE=%CATALINA_HOME%\instances\node2
)
if "%CMD%" == "node3" (
	set CATALINA_BASE=%CATALINA_HOME%\instances\node3
)

rem Check that target executable exists
if exist "%EXECUTABLE%" goto okExec
echo Cannot find %EXECUTABLE%
echo This file is needed to run this program
goto end
:okExec

rem Start Tomcat
%EXECUTABLE%

:end
