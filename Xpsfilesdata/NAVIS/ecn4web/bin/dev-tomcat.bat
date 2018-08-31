REM Copyright (c) 2012 Navis LLC. All Rights Reserved.
rem @echo off
rem For time shift, run "dev-tomcat shift_time_to <datetime>", where <datetime> is of
rem the form ""yyyy-mm-dd_hh:mm_zzz", with "zzz" being the time zone.  For example,
rem "1963-12-09_04:50_PST".

setlocal enabledelayedexpansion

if "%OS%" == "Windows_NT" setlocal

rem Gather command line arguments for profiling tools
set CMD=%1
set DATETIME=%2

rem A repulsive batch-hack to get our parent dir.
set CURRENT=%CD%
cd ..
set PARENT=%CD%
cd %CURRENT%
set CATALINA_HOME=%PARENT%

if defined TEAMCITY_VERSION (
    set str=%JAVA_HOME%
    rem Get rid of any trailing spaces
    for /l %%a in (1,1,31) do if "!str:~-1!"==" " set str=!str:~0,-1!
    set JRE_HOME=%str%
)

echo catalina home is %CATALINA_HOME%
set JAVA_OPTS=%JAVA_OPTS% -Dnavis.external.config.shared=%CATALINA_HOME%\conf
set spring.profiles.active=test

rem Enable JRebel
rem To use jrebel, must define environmrnt variable JREBEL_JAR to point to the jrebel jar file (e.g. inside the
rem intellij plugin), and must create/generate a rebel.xml in apex/web/WEB-INF that lists the module java class
rem and/or web directories to be monitored by jrebel.
if exist "%JREBEL_JAR%" (
    echo jrebel jar is %JREBEL_JAR%
    set JAVA_OPTS=%JAVA_OPTS% -javaagent:%JREBEL_JAR% -noverify
)

rem JVM memory options
set JAVA_OPTS= %JAVA_OPTS% ^
               -Xms256M ^
               -Xmx2000M ^
               -XX:MaxPermSize=500M ^
               -Dfile.encoding=UTF-8 ^
               -Dsun.jnu.encoding=UTF-8

rem JVM diag options
set JAVA_OPTS= %JAVA_OPTS% ^
               -XX:+HeapDumpOnOutOfMemoryError ^
               -XX:HeapDumpPath=..\logs ^
			   -XX:+UseGCLogFileRotation ^
               -Xloggc:..\logs\gc.log ^
               -XX:GCLogFileSize=25M ^
			   -XX:NumberOfGCLogFiles=20 ^
			   -verbose:gc ^
			   -XX:+UseG1GC ^
			   -XX:+PrintGCDetails ^
			   -XX:+PrintGCDateStamps 			   

rem Set cache provider settings based on environment variables with defaults
rem that shouldn't clash with other applications using some of the same parameters.

if not defined CACHE_PROVIDER (
    set CACHE_PROVIDER=HAZELCAST
    echo "Env. variable CACHE_PROVIDER not defined.  Using default..."
)
echo "CACHE_PROVIDER=%CACHE_PROVIDER%"

GOTO CASE_%CACHE_PROVIDER%
:CASE_EHCACHE
    rem ehcache
    if defined N4_TERRACOTTA_SERVERURL (
        set JAVA_OPTS= %JAVA_OPTS% ^
        -Dterracotta.server.url=%N4_TERRACOTTA_SERVERURL%
    )
    GOTO nodes
:CASE_HAZELCAST
    rem hazelcast
    set JAVA_OPTS= %JAVA_OPTS% ^
    -Dhazelcast.jmx=true
    GOTO nodes

:nodes
rem Nodes - Ports
if "node" ==  "%CMD:~0,4%" (
    set JAVA_OPTS=%JAVA_OPTS% -Denvironment.container.identity=%CMD%
    if "%CMD%" == "node1" (
	      set SERVLET_PORT=9080
	      set DEBUG_PORT=5005
        set JMX_PORT=7020

    )
    if "%CMD%" == "node2" (
	      set SERVLET_PORT=10080
	      set DEBUG_PORT=5006
	      set JMX_PORT=7021

    )
    if "%CMD%" == "node3" (
	      set SERVLET_PORT=11080
	      set DEBUG_PORT=5007
	      set JMX_PORT=7022

    )
) else (
    rem Setting default tomcat node...
	  set SERVLET_PORT=8280
	  set DEBUG_PORT=5005
    set JMX_PORT=7020
	set JMX_SERVER_PORT=7023
    rem for dev purposes, to keep one node for the tomcat appl. server
    set JAVA_OPTS=%JAVA_OPTS% -Denvironment.container.identity=standaloneNode
)


rem Set the JMX options.
set JMX_PARMS=-Dcom.sun.management.jmxremote ^
              -Dcom.sun.management.jmxremote.ssl=false ^
              -Dcom.sun.management.jmxremote.authenticate=false ^
              -Dcom.sun.management.jmxremote.port=%JMX_PORT%
set JAVA_OPTS= %JAVA_OPTS% %JMX_PARMS% ^
               -Dcom.navis.servlet.container.port=%SERVLET_PORT%

:fastStart
rem Fast startup for general development. Selectively disables product features (e.g. Groovy extensions).
if defined N4_TOMCAT_FAST_START set JAVA_OPTS= %JAVA_OPTS% ^
            -DdisableExtensionValidation=true ^
            -DdisableGroovyPluginInstall=true ^
            -DdisableWorkflowResourceCompilation=true

:debugOpts
rem Set the debug options, which allows remote debugging.  Also enables Java assertions.
if defined N4_TOMCAT_DEBUG set JAVA_OPTS= %JAVA_OPTS% ^
            -ea ^
            -Xdebug ^
            -Xnoagent ^
            -Djava.compiler=NONE ^
            -Xrunjdwp:transport=dt_socket,server=y,suspend=n,address=%DEBUG_PORT%

rem Check that target executable exists
set EXECUTABLE=%CATALINA_HOME%\bin\startup.bat
if exist "%EXECUTABLE%" goto okHome
echo The CATALINA_HOME environment variable is not defined correctly
echo This environment variable is needed to run this program
echo Cannot find %EXECUTABLE%
echo This file is needed to run this program
goto end

:okHome
rem Gather JVM architecture model
rem use 'findstr' vs 'find' as that can be confused with
rem linux 'find' ported to windows
java -version 2>&1 | findstr "64-Bit" > nul:
if errorLevel 1 (
    set JVM_MODEL=32
) else (
    set JVM_MODEL=64
)

rem JVM library path
set JAVA_OPTS= %JAVA_OPTS% -Djava.library.path=%CATALINA_HOME%\bin;%CATALINA_HOME%\shared\native\lib%JVM_MODEL%

rem  Where to find common configuration files
:shared_config_dir_check
echo %JAVA_OPTS%|findstr /i "navis.external.config.shared" >nul:
if %errorlevel%==1 (
    set JAVA_OPTS= %JAVA_OPTS% -Dnavis.external.config.shared=%CATALINA_HOME%\conf
)
echo "JAVA_OPTS=%JAVA_OPTS%"

rem Setup Yourkit options for profiling
if "%CMD%" == "profile" (
    if not defined YOUR_KIT_PROFILER_HOME (
        echo The YOUR_KIT_PROFILER_HOME environment variable is not defined.
        echo This environment variable is needed to run the profiler.
        echo It must point to the YourKit Java Profiler home directory.
        goto end
    )
    echo "YOUR_KIT_PROFILER_HOME = %YOUR_KIT_PROFILER_HOME%"
    if not exist "%YOUR_KIT_PROFILER_HOME%"\bin\win%JVM_MODEL% (
        echo The YOUR_KIT_PROFILER_HOME binary could not be found.
        goto end
    )
    set JAVA_OPTS=%JAVA_OPTS% -agentpath:"%YOUR_KIT_PROFILER_HOME%"\bin\win%JVM_MODEL%\yjpagent.dll=sessionname=Tomcat
    echo Start Profiling
    echo JAVA_OPTS %JAVA_OPTS%
)

if "%CMD%" == "shift_time_to" (
    set JAVA_OPTS=%JAVA_OPTS% -javaagent:..\..\..\common\util\NavisInterceptorAgent\build\NavisInterceptor.jar=%DATETIME%
    echo "start time shift"
)

set EXECUTABLE=%CATALINA_HOME%\bin\startup.bat
if exist "%EXECUTABLE%" goto okHome
echo The CATALINA_HOME environment variable is not defined correctly
echo This environment variable is needed to run this program
goto end
:okHome
:checkExec

if defined CMD (
    rem Set the cluster settings
    echo "Node is %CMD%"
    for %%i in (node1 node2 node3) do if "%CMD%" == "%%i" set CATALINA_BASE=%CATALINA_HOME%\instances\%CMD%
)

rem Check that target executable exists
if exist "%EXECUTABLE%" goto okExec
echo Cannot find %EXECUTABLE%
echo This file is needed to run this program
goto end
:okExec

rem Start Tomcat
echo "Executable is: %EXECUTABLE%"
echo "Java options: %JAVA_OPTS%
%EXECUTABLE%

:end
