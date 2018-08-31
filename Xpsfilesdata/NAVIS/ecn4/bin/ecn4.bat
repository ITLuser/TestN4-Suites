@ECHO OFF
REM * ----------------------------------------------------------
REM * Set the Java Options and ECN4 Options
REM * Execute ECN4 application
REM * ----------------------------------------------------------

REM * Set the location of ECN4 home directory
REM * set ECN4_HOME=C:\N4\ECN4_Production

REM * Check that the ECN4_HOME has been set
if not "%ECN4_HOME%" == "" goto CHECK-JDK-HOME_VARIABLES
echo The ECN4_HOME environment variable is not defined. Please define the ECN4_HOME environment variable either on
echo your system or within this script.
goto EXIT

:CHECK-JDK-HOME_VARIABLES
REM JAVA_HOME="Define locally the Java Location (if needed)"
REM * Make sure JAVA is installed and the JAVA_HOME variable is set
if not "%JAVA_HOME%" == "" goto CHECK-JDK-HOME
echo The JAVA_HOME environment variable is not defined. Please define the JAVA_HOME environment variable either on
echo your system or within this script.
goto EXIT

REM * Ensure the jdk is correctly setup
:CHECK-JDK-HOME
if not exist "%JAVA_HOME%\bin\java.exe" goto NO-JAVA
if not exist "%JAVA_HOME%\bin\javaw.exe" goto NO-JAVA

REM * Set the conf directory home
set CONF_DIR_HOME=%ECN4_HOME%\conf
REM * Check that the conf directory has been created
if exist "%CONF_DIR_HOME%" goto :CHECK-SETTINGS-FILE
echo Can not find the conf directory located %CONF_DIR_HOME%
echo Please create the conf directory and place all your configuration files within it.
goto EXIT

:CHECK-SETTINGS-FILE
REM * Set the location of the ECN4 settings file (Defaults to the ecn4_settings_prod.xml file)
set SETTINGS_FILE=%ECN4_HOME%\conf\ecn4_settings_prod.xml
if not exist "%SETTINGS_FILE%" goto NO-SETTINGS-FILE
REM * Add the settings file to the java options
set JAVA_OPTS=-Dcom.navis.ecn4.settings.file=%SETTINGS_FILE%

REM * Check if the environment variable is set
if not "%TANGOSOL_OVERRIDE_FILE%" == "" goto :TANGOSOL-OVERRIDE-FILE-EXISTS
REM * If the environment variable is not set use the default located in the conf directory
REM * Set the location of the tangosol override production configuration file (See example conf/tangosol-coherence-override-prod.xml)
REM * Change this file to a customer specific configuration
set TANGOSOL_OVERRIDE_FILE=%ECN4_HOME%\conf\tangosol-coherence-override-prod.xml

:TANGOSOL-OVERRIDE-FILE-EXISTS
REM * Check that the tangosol override prod file exist
if not exist "%TANGOSOL_OVERRIDE_FILE%" goto NO-COHERENCE-OVERRIDE-FILE
REM * Set the coherence properties
set JAVA_OPTS=%JAVA_OPTS% -Dtangosol.coherence.mode=prod -Dtangosol.coherence.override=file:/%TANGOSOL_OVERRIDE_FILE%

REM * Set the location of the ECN4 Log4j settings file
set LOG4J_FILE=%ECN4_HOME%\conf\log4j.xml
REM * Check that the log4j file exist
if not exist "%LOG4J_FILE%" goto NO-LOG4J-FILE
REM * Set the log4j properties including the system property to define the log directory
set JAVA_OPTS=%JAVA_OPTS% -Dlog4j.configuration=file:/%LOG4J_FILE% -Dcom.navis.ecn4.log.dir=%ECN4_HOME%\logs

REM * Sets JVM arguments
set JAVA_ARGS=-ea -server -Xms128m -Xmx256m

REM * Start ECN4
"%JAVA_HOME%"\bin\java %JAVA_ARGS% %JAVA_OPTS% -jar "%ECN4_HOME%"\lib\n4-ecn4.jar %1
REM * Exit ECN4 if we reach this point
goto EXIT

:NO-JAVA
echo Can not find the Java Virtual Machine. Please check your java installation.
goto EXIT

:NO-SETTINGS-FILE
echo Can not find the settings file %SETTINGS_FILE%
echo Please set the property "SETTINGS_FILE" contained within this script to point to the correct location.
goto EXIT

:NO-COHERENCE-OVERRIDE-FILE
echo Can not find the tangosol coherence override production file %TANGOSOL_OVERRIDE_FILE%
echo Please set the "TANGOSOL_OVERRIDE_FILE" environment variable or the property within this script to point to the correct location.
goto EXIT

:NO-LOG4J-FILE
echo Can not find the log4j property file %LOG4J_FILE%
echo Please set the property "LOG4J_FILE" contained within this script to point to the correct location.
goto EXIT

:EXIT
exit /b 1
:END
