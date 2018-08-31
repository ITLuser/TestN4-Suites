@ECHO OFF
REM *----------------------------------------------------------
REM * Script will install the Navis ECN4 as a windows service
REM *----------------------------------------------------------

set SERVICE_NAME=ecn4
set SERVICE_DISPLAY_NAME="Navis ECN4 Daemon 2.6 ARK"
set SERVICE_DESCRIPTION="Daemon that facilitates the Equipment Control of N4"


REM * set the NAVIS_HOME and NAVIS_SHARED variables
if "%NAVIS_HOME%" == "" set NAVIS_HOME=C:\sparcsN4
if "%NAVIS_SHARED%" == "" set NAVIS_SHARED=%NAVIS_HOME%

REM * set the ecn4 home
set ECN4_HOME=%NAVIS_HOME%\ecn4
set jvm_memory=1024

REM * set the shared settings property and it points to the ecn4_settings_prod.xml file
set SHARED_SETTINGS=%NAVIS_SHARED%\conf\n4_settings_prod.xml

REM * set the tangosol override production file
set TANGOSOL_OVERRIDE_FILE=%NAVIS_SHARED%\conf\tangosol-coherence-override-prod.xml

REM * set the JDK
if exist "%JAVA_HOME%\jre\bin\server\jvm.dll" set JVM=%JAVA_HOME%\jre\bin\server\jvm.dll
if not exist "%JVM%" goto NO-JAVA


if "%PROCESSOR_ARCHITECTURE%" == "x86" (move %ECN4_HOME%\bin\ecn4-32bit.exe %ECN4_HOME%\bin\ecn4.exe) else (del %ECN4_HOME%\bin\ecn4-32bit.exe)

if "%PROCESSOR_ARCHITECTURE%" == "x86" (set jvm_memory=1144)


%ECN4_HOME%\bin\ecn4.exe //IS//%SERVICE_NAME% --Jvm="%JVM%" --JvmMs=%jvm_memory% --JvmMx=%jvm_memory% --Classpath="%ECN4_HOME%\lib\n4-ecn4.jar"
%ECN4_HOME%\bin\ecn4.exe //US//%SERVICE_NAME% --DisplayName=%SERVICE_DISPLAY_NAME% --Description=%SERVICE_DESCRIPTION%
%ECN4_HOME%\bin\ecn4.exe //US//%SERVICE_NAME% --StartMode=jvm --StartClass=com.navis.ecn4.Ecn4StandaloneCacheLauncher --StartMethod=windowsService --StartParams=start --StartPath="%ECN4_HOME%"
%ECN4_HOME%\bin\ecn4.exe //US//%SERVICE_NAME% --StdOutput=auto --StdError=auto --LogPath="%ECN4_HOME%\logs" --LogLevel=warn --JvmOptions=-Dfile.encoding="UTF-8"#-XX:+UseConcMarkSweepGC#-XX:+HeapDumpOnOutOfMemoryError#-XX:HeapDumpPath=%ECN4_HOME%\logs\#-XX:ErrorFile=%ECN4_HOME%\logs\hs_err_pid%%p.log#-Dcom.navis.ecn4.settings.file=%SHARED_SETTINGS%#-Dcom.navis.ecn4.log.dir=%ECN4_HOME%\logs#-Dtangosol.coherence.distributed.localstorage=true#-Dtangosol.coherence.mode=development#-Dtangosol.coherence.override=%TANGOSOL_OVERRIDE_FILE%#-Dlog4j.configuration=file:///%ECN4_HOME%/conf/log4j.xml#"
%ECN4_HOME%\bin\ecn4.exe //US//%SERVICE_NAME% --StopMode=jvm --StopClass=com.navis.ecn4.Ecn4StandaloneCacheLauncher --StopMethod=windowsService --StopParams=stop --StopPath="%ECN4_HOME%"
goto END

:NO-JAVA
:nojava
echo No Java Virtual Machine can be found. Please make sure a Java Development Kit (JDK) is installed and the environment variable JAVA_HOME is set and points to the correct location.
:END
