@ECHO OFF
REM *----------------------------------------------------------
REM * Script will install the Navis ECN4 Web as a windows service
REM *----------------------------------------------------------

set SERVICE_NAME=ecn4web
set SERVICE_DISPLAY_NAME="Navis ECN4-Web 2.6 ARK"
set SERVICE_DESCRIPTION="Navis ECN4-Web application listening on 8280 (http) and 1389 (ajp13)"

REM * set the NAVIS_HOME variable
if "%NAVIS_HOME%" == "" set NAVIS_HOME=C:\sparcsN4

REM * set the Tomcat home and base variables
set CATALINA_HOME=%NAVIS_HOME%\ecn4web
set CATALINA_BASE=%CATALINA_HOME%
set tomcat=tomcat7
set jvm_memory=1144

REM * set the JDK
if exist "%JAVA_HOME%\jre\bin\server\jvm.dll" set JVM=%JAVA_HOME%\jre\bin\server\jvm.dll
if not exist "%JVM%" goto NO-JAVA


if "%PROCESSOR_ARCHITECTURE%" == "x86" (move %CATALINA_HOME%\bin\%tomcat%-32bit.exe %CATALINA_HOME%\bin\%tomcat%.exe) else (del %CATALINA_HOME%\bin\%tomcat%-32bit.exe)
%CATALINA_HOME%\bin\%tomcat%.exe //IS//%SERVICE_NAME% --Jvm="%JVM%" --StartClass=org.apache.catalina.startup.Bootstrap --StartParams start --StopClass=org.apache.catalina.startup.Bootstrap  --StopParams stop
%CATALINA_HOME%\bin\%tomcat%.exe //US//%SERVICE_NAME% --JvmMs=%jvm_memory% --JvmMx=%jvm_memory% --DisplayName=%SERVICE_DISPLAY_NAME% --Description=%SERVICE_DESCRIPTION%
%CATALINA_HOME%\bin\%tomcat%.exe //US//%SERVICE_NAME% --StartMode=jvm  --StartParams=start --LogPath="%CATALINA_BASE%\logs" --LogLevel=warn --StdOutput=auto --StdError=auto
%CATALINA_HOME%\bin\%tomcat%.exe //US//%SERVICE_NAME% --StopMode=jvm --StopPath=%CATALINA_HOME%
%CATALINA_HOME%\bin\%tomcat%.exe //US//%SERVICE_NAME% --Classpath=%CATALINA_HOME%\bin\bootstrap.jar;
%CATALINA_HOME%\bin\%tomcat%.exe //US//%SERVICE_NAME% --JvmOptions="-Dcom.navis.servlet.container.port=8280#-Dfile.encoding=UTF-8#-Dcatalina.home=%CATALINA_HOME%#-Dcatalina.base=%CATALINA_HOME%#-Djava.endorsed.dirs=%CATALINA_HOME%\endorsed#-Djava.io.tmpdir=%CATALINA_HOME%\temp#-Djava.util.logging.manager=org.apache.juli.classLoaderlogManager#-Dcom.navis.ecn4web.log.dir=%ECN4_HOME%\logs#-XX:+UseConcMarkSweepGC#-XX:+HeapDumpOnOutOfMemoryError#-XX:HeapDumpPath=%CATALINA_BASE%\logs\#-XX:ErrorFile=%CATALINA_BASE%\logs\hs_err_pid%%p.log#-XX:MaxPermSize=256M"
copy %CATALINA_HOME%\bin\%tomcat%w.exe %CATALINA_HOME%\bin\%SERVICE_NAME%w.exe
goto END
:NO-JAVA
echo Can not find your Java Virtual Machine. Installation cannot continue.
pause
:END
