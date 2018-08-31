@ECHO OFF
REM *----------------------------------------------------------
REM * Script will install the Navis Bridge 2 Daemon as a windows service
REM *----------------------------------------------------------

REM * set the NAVIS_HOME variable
if "%NAVIS_HOME%" == "" set NAVIS_HOME=C:\NAVIS
if "%NAVIS_SHARED%" == "" set NAVIS_SHARED="%NAVIS_HOME%"
set jvm_memory=1000

REM * set the shared settings property and it points to the n4_settings_prod.xml file
set SHARED_SETTINGS=%NAVIS_SHARED%\conf\n4_settings_prod.xml

REM * set the tangosol override production file
set TANGOSOL_OVERRIDE_FILE=%NAVIS_SHARED%\conf\tangosol-coherence-override-prod.xml

set BRIDGED_HOME=%NAVIS_HOME%\bridged
set BRIDGED_SRVS="bridged"
if exist "%JAVA_HOME%\jre\bin\server\jvm.dll" set JVM=%JAVA_HOME%\jre\bin\server\jvm.dll
if not exist "%JVM%" goto nojava

if "%PROCESSOR_ARCHITECTURE%" == "x86" (move %BRIDGED_HOME%\bin\bridged-32bit.exe %BRIDGED_HOME%\bin\bridged.exe) else (del %BRIDGED_HOME%\bin\bridged-32bit.exe)
if "%PROCESSOR_ARCHITECTURE%" == "x86" (set jvm_memory=1144)

"%BRIDGED_HOME%\bin\bridged.exe" //IS//%BRIDGED_SRVS% --Jvm="%JVM%" --JvmMs=%jvm_memory% --JvmMx=%jvm_memory% --Classpath="%BRIDGED_HOME%\lib\n4-bridged.jar"
"%BRIDGED_HOME%\bin\bridged.exe" //US//%BRIDGED_SRVS% --DisplayName="Navis XPS Bridge Daemon 2" --Description="Daemon that facilitates communication between Navis XPS, ECN4 and the Sparcs N4 webapp using Mule"
"%BRIDGED_HOME%\bin\bridged.exe" //US//%BRIDGED_SRVS% --StartMode=jvm --StartClass=com.navis.bridged.bridge2.Bridge2 --StartPath="%BRIDGED_HOME%" --StartParams=-f#%SHARED_SETTINGS%
"%BRIDGED_HOME%\bin\bridged.exe" //US//%BRIDGED_SRVS% --StdOutput=auto --StdError=auto --LogPath="%BRIDGED_HOME%\logs" --LogLevel=warn --JvmOptions=-Dfile.encoding="UTF-8"#-XX:+UseConcMarkSweepGC#-XX:+HeapDumpOnOutOfMemoryError#-XX:HeapDumpPath=%BRIDGED_HOME%\logs\#-XX:ErrorFile=%BRIDGED_HOME%\logs\hs_err_pid%%p.log#-Dtangosol.coherence.distributed.localstorage=false#-Dtangosol.coherence.mode=prod#-Dtangosol.coherence.override=%TANGOSOL_OVERRIDE_FILE%
"%BRIDGED_HOME%\bin\bridged.exe" //US//%BRIDGED_SRVS% --StopMode=jvm --StopClass=com.navis.bridged.bridge2.Bridge2 --StopMethod=shutdown --StopPath="%BRIDGED_HOME%"
goto end
:nojava
echo No Java Virtual Machine can be found. Please make sure a Java Development Kit (JDK) is installed and the environment variable JAVA_HOME is set and points to the correct location.
:end
