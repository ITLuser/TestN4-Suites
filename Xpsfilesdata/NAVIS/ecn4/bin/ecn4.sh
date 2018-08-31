#!/bin/bash
# * ----------------------------------------------------------
# * Set the Java Options and ECN4 Options
# * Execute ECN4 application
# * ----------------------------------------------------------

pidfile="$NAVIS_BASE/ecn4/logs/ecn4.pid"

function ecn4_running() {
    if [ -e $pidfile ]; then
	    pgrep -F $pidfile
        return $?
    else
        return 1
    fi
}

function kill_ecn4() {

   if ecn4_running; then
      echo "Shutting down ECN4 with with process ID $pid"
      pkill -F $pidfile	  
	  sleep 5
	  pgrep -F $pidfile
	  if [ $! != 0 ]; then
	      pgrep -signal 9 -F $pidfile
	  fi
	  rm $pidfile
      exit 0
   else
      if [ -e $pidfile ]; then
		rm $pidfile
      fi
	  echo "ECN4 is not running."
      exit 1
   fi
}

# Stop ECN4
if [ $@ == stop ]; then
   kill_ecn4
fi

# Before we do anything else make sure ECN4 isn't already running.
if  ecn4_running; then
    echo "ECN4 is already running."
    exit 1
fi


# Check that JAVA is installed and the JAVA_HOME variable is set. We aren't even going to bother starting if we can't find Java.
if [ -z "$JAVA_HOME" ]; then
    echo "Can not find a Java Virtual Machine. Please make sure that the JAVA_HOME environment variable is defined and that it points to the location of a valid Java virtual machine."
    exit 1
fi

if [ ! -x "$JAVA_HOME"/bin/java ]; then
    echo "Can not find a Java Virtual Machine. Please make sure that the JAVA_HOME environment variable is defined and that it points to the location of a valid Java virtual machine."
    exit 1
fi
# Find out where we live (making sure to resolve the symbolic links).
while [ -h "$PRG" ]; do
  ls=`ls -ld "$PRG"`
  link=`expr "$ls" : '.*-> \(.*\)$'`
  if expr "$link" : '/.*' > /dev/null; then
    PRG="$link"
  else
    PRG=`dirname "$PRG"`/"$link"
  fi
done

PRGDIR=`dirname "$PRG"`

# If NAVIS_HOME is set use that for ECN4_HOME
if [ ! -z "$NAVIS_HOME" ]; then
    ECN4_HOME="$NAVIS_HOME/ecn4"
fi
# Check that the ECN4_HOME has been set if not ECN4_HOME defaults to the directory above this script's directory.
if [ -z "$ECN4_HOME"  ]; then
    ECN4_HOME = `cd "$PRGDIR/.." ; pwd`
fi

# If NAVIS_BASE is set use that for ECN4_BASE
if [ ! -z "$NAVIS_BASE" ]; then
    ECN4_BASE="$NAVIS_BASE/ecn4"
fi
# Check to see if ECN4_BASE has been set. (ECN4_BASE defaults to ECN4_HOME if it's not set.)
 if [ -z "$ECN4_HOME"  ]; then
     ECN4_BASE = $ECN4_HOME
 fi


# ecn4_conf_dir is the conf directory in ECN4_BASE.
ecn4_conf_dir="$ECN4_BASE/conf"

# Check that the conf directory has been created
if [ ! -d "$ecn4_conf_dir"  ]; then
    echo "Can not find a configuration directory located at $ecn4_conf_dir"
    echo "Please create a configuration directory and place all your configuration files within it."
    exit 1
fi

# Set the location of the ECN4 settings file (Defaults to the ecn4_settings_prod.xml file)
settings_file="$ecn4_conf_dir/ecn4_settings_prod.xml"

# Check that it exist
if [ ! -e "$settings_file"  ]; then
    echo "Can not find the ECN4 settings file $settings_file"
    echo "Please make sure that it has been placed in the directory $ecn4_conf_dir."
    exit 1
else
     JAVA_OPTS="$JAVA_OPTS -Dcom.navis.ecn4.settings.file=$settings_file"
fi


# Set the location of the ECN4 Log4j settings file and the system property that defines the log directory home
log4j_file="$ecn4_conf_dir/log4j.xml"

# Check that it exist
if [ ! -e "$log4j_file"  ]; then
    echo "Can not find the log4j property file $log4j_file" and the application will run without it.
    exit 1
else
     JAVA_OPTS="$JAVA_OPTS -Dlog4j.configuration=file:$log4j_file -Dcom.navis.ecn4.log.dir=$ECN4_BASE/logs"
fi

# Get user configurable Java options
source $ecn4_conf_dir/ecn4.conf
# Sets JVM arguments

# If they're not set these are defaults for the memory settings
[ -z "$JAVA_MEMORY_POOL_MIN" ] && JAVA_MEMORY_POOL_MIN="2488M"
[ -z "$JAVA_MEMORY_POOL_MAX" ] && JAVA_MEMORY_POOL_MAX="2488M"

# The default JMX port
[ -z "$NAVIS_JMX_PORT" ] && NAVIS_JMX_PORT="8019"

JAVA_ARGS="-ea -server -Xms$JAVA_MEMORY_POOL_MIN -Xmx$JAVA_MEMORY_POOL_MAX \
-Dfile.encoding=UTF-8 \
-Dcom.navis.ecn4.settings.ECN4_DIR=$ECN4_BASE \
-XX:+UseG1GC \
-XX:MaxGCPauseMillis=750 \
-XX:InitiatingHeapOccupancyPercent=45 \
-XX:+HeapDumpOnOutOfMemoryError \
-XX:HeapDumpPath=$ECN4_BASE/logs \
-XX:ErrorFile=$ECN4BASE/logs/hs_err_pid%%p.log \
-Dcom.navis.ecn4.log.file=navis-ecn4 \
-Dcom.sun.management.jmxremote.port=$NAVIS_JMX_PORT \
-Dcom.sun.management.jmxremote.ssl=false \
-Dcom.sun.management.jmxremote.authenticate=false"

# Force our working directory to be ECN4_HOME
cd $ECN4_HOME

# Start ECN4
"$JAVA_HOME"/bin/java $JAVA_ARGS $JAVA_OPTS -jar $ECN4_HOME/lib/n4-ecn4.jar "$@"  &
echo $! > $pidfile
exit 0
