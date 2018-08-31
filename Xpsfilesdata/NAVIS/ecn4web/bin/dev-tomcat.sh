#!/usr/bin/env bash
# $Id: dev-tomcat.sh,v 1.3 2009-02-02 21:38:48 abrar Exp $
# JVM memory options
JAVA_OPTS="$JAVA_OPTS -Xms256M -Xmx2000M -XX:MaxPermSize=500M -Dfile.encoding=UTF-8 -Dsun.jnu.encoding=UTF-8"

#JVM diag options
JMX_OPTS="-Dcom.sun.management.jmxremote -Dcom.sun.management.jmxremote.ssl=false  -Dcom.sun.management.jmxremote.authenticate=false \
  -Dcom.sun.management.jmxremote.port=7020"
JAVA_OPTS="$JAVA_OPTS $JMX_OPTS -XX:+HeapDumpOnOutOfMemoryError -XX:HeapDumpPath=../logs -XX:+UseGCLogFileRotation \
-Xloggc:../logs/gc.log -XX:GCLogFileSize=25M -XX:NumberOfGCLogFiles=20 -verbose:gc -XX:+UseG1GC -XX:+PrintGCDetails -XX:+PrintGCDateStamps"

# Set the tomcat port to 8280
JAVA_OPTS="$JAVA_OPTS -Dcom.navis.servlet.container.port=8280"

# If N4_TOMCAT_DEBUG is true set the DEBUG port.
[ -z "$N4_TOMCAT_DEBUG" ] && N4TOMCAT_DEBUG_PORT=5005

# Allow startup to shift time
if [ "$CMD" = "shift_time_to" ]; then
    JAVA_OPTS="$JAVA_OPTS -javaagent:../../../common/util/NavisInterceptorAgent/build/NavisInterceptor.jar=$DATETIME"
    echo "Start time shift."
fi

# Set CATALINA_HOME
# resolve links - $0 may be a softlink
PRG="$0"
while [ -h "$PRG" ]; do
  ls=`ls -ld "$PRG"`
  link=`expr "$ls" : '.*-> \(.*\)$'`
  if expr "$link" : '/.*' > /dev/null; then
    PRG="$link"
  else
    PRG=`dirname "$PRG"`/"$link"
  fi
done
# Find out where we live
PRGDIR=`dirname "$PRG"`
# Only set CATALINA_HOME if not already set
[ -z "$CATALINA_HOME" ] && CATALINA_HOME=`cd "$PRGDIR/.." ; pwd`

# Gather JVM architecture model
JVM_MODEL="lib32"
if [ ! -z "$(java -version 2>&1 | grep -i '64-bit')" ]; then
    JVM_MODEL="lib64"
fi

# JVM native libary path
[ -d "$CATALINA_HOME/shared/native/$JVM_MODEL" ] &&  NATIVE_LIB_PATH=";$CATALINA_HOME/shared/native/$JVM_MODEL"

# JVM library path
JAVA_OPTS="$JAVA_OPTS -Djava.library.path=$CATALINA_HOME/bin$NATIVE_LIB_PATH "

# Check that target executable exists
EXECUTABLE="$CATALINA_HOME/bin/navis-tomcat.sh"
if [ ! -x $EXECUTABLE ]; then 
    echo "The CATALINA_HOME environment variable is not defined correctly."
    echo "This environment variable is needed to run this program."
    exit 1
fi

# Start Tomcat
export JAVA_OPTS CATALINA_HOME N4TOMCAT_DEBUG_PORT
exec $EXECUTABLE -l start
