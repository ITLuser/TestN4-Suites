REM Copyright (c) 2010 Zebra Technologies Corp. All Rights Reserved.
@echo off

if "%OS%" == "Windows_NT" setlocal

set N4_TOMCAT_DEBUG=true
if not defined N4_TERRACOTTA_SERVERURL set N4_TERRACOTTA_SERVERURL=localhost:9510
set EXECUTABLE=.\dev-tomcat-terracotta.bat
%EXECUTABLE%

:end
