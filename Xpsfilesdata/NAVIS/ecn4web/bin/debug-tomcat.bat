REM Copyright (c) 2012 Navis LLC. All Rights Reserved.
@echo off
rem For time shift, run "debug-tomcat shift_time_to <datetime>", where <datetime> is of
rem the form ""yyyy-mm-dd_hh:mm_zzz", with "zzz" being the time zone.  For example,
rem "1963-12-09_04:50_PST".

set N4_TOMCAT_DEBUG=true
set EXECUTABLE=.\dev-tomcat.bat %*

echo "%EXECUTABLE%"
%EXECUTABLE%

:end
