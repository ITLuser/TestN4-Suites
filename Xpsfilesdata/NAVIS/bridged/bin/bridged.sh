#!/bin/sh
# * ----------------------------------------------------------
# * Set the Java Options and BRIDGED Options
# * Execute BRIDGED application
# * ----------------------------------------------------------

pidfile="$NAVIS_BASE/bridged/logs/bridged.pid"

function bridge_running() {
    if [ -e $pidfile ]; then
	    pgrep -F $pidfile
        return $?
    else
        return 1
    fi
}

function kill_bridge() {

   if bridge_running; then
      echo "Shutting down BRIDGED with with process ID $pid"
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
	  echo "BRIDGED is not running."
      exit 1
   fi
}

# Stop BRIDGED
if [ $@ == stop ]; then
   kill_bridge
fi

# Before we do anything else make sure BRIDGED isn't already running.
if  bridge_running; then
    echo "Bridged is already running."
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

# If NAVIS_HOME is set use that for BRIDGED_HOME
if [ ! -z "$NAVIS_HOME" ]; then
    BRIDGED_HOME="$NAVIS_HOME/bridged"
fi
# Check that the BRIDGED_HOME has been set if not BRIDGED_HOME defaults to the directory above this script's directory.
if [ -z "$BRIDGED_HOME"  ]; then
    BRIDGED_HOME = `cd "$PRGDIR/.." ; pwd`
fi

# If NAVIS_BASE is set use that for BRIDGED_BASE
if [ ! -z "$NAVIS_BASE" ]; then
    BRIDGED_BASE="$NAVIS_BASE/bridged"
fi
# Check to see if BRIDGED_BASE has been set. (BRIDGED_BASE defaults to BRIDGED_HOME if it's not set.)
 if [ -z "$BRIDGED_HOME"  ]; then
     BRIDGED_BASE = $BRIDGED_HOME
 fi


# bridge_conf_dir is the conf directory in BRIDGED_BASE.
bridge_conf_dir="$BRIDGED_BASE/conf"

# Check that the conf directory has been created
if [ ! -d "$bridge_conf_dir"  ]; then
    echo "Can not find a configuration directory located at $bridge_conf_dir"
    echo "Please create a configuration directory and place all your configuration files within it."
    exit 1
fi

# Set the location of the BRIDGED settings file (Defaults to the bridge_settings_prod.xml file)
settings_file="$bridge_conf_dir/ecn4_settings_prod.xml"

# Check that it exist
if [ ! -e "$settings_file"  ]; then
    echo "Can not find the BRIDGED settings file $settings_file"
    echo "Please make sure that it has been placed in the directory $bridge_conf_dir."
    exit 1
else
     JAVA_OPTS="$JAVA_OPTS -Dcom.navis.bridge.settings.file=$settings_file"
fi


# Set the location of the BRIDGED Log4j settings file and the system property that defines the log directory home
log4j_file="$bridge_conf_dir/log4j.properties"

# Check that it exist
if [ ! -e "$log4j_file"  ]; then
    echo "Can not find the log4j property file $log4j_file" and the application will run without it.
    exit 1
else
     JAVA_OPTS="$JAVA_OPTS -Dlog4j.configuration=file:$log4j_file -Dcom.navis.bridgedaemon.log.dir=${BRIDGED_BASE}/logs"
fi

# Get user configurable Java options
source $bridge_conf_dir/bridged.conf
# Sets JVM arguments

# If they're not set these are defaults for the memory settings
[ -z "$JAVA_MEMORY_POOL_MIN" ] && JAVA_MEMORY_POOL_MIN="2488M"
[ -z "$JAVA_MEMORY_POOL_MAX" ] && JAVA_MEMORY_POOL_MAX="2488M"

# The default JMX port
[ -z "$NAVIS_JMX_PORT" ] && NAVIS_JMX_PORT="13019"

JAVA_ARGS="-server -Xms${JAVA_MEMORY_POOL_MIN} -Xmx${JAVA_MEMORY_POOL_MAX} \
-Dfile.encoding=UTF-8 \
-Dcom.navis.bridgedaemon.log.dir=${BRIDGED_BASE}/logs \
-Dlog4j.configuration=file:///${BRIDGED_BASE}/conf/log4j.properties \
-XX:+UseConcMarkSweepGC \
-XX:+HeapDumpOnOutOfMemoryError \
-XX:HeapDumpPath=${BRIDGED_BASE}/logs/ \
-XX:ErrorFile=${BRIDGED_BASE}/logs/hs_err_pid%%p.log \
-Dcom.sun.management.jmxremote.port=${NAVIS_JMX_PORT}  \
-Dcom.sun.management.jmxremote.ssl=false \
-Dcom.sun.management.jmxremote.authenticate=false \
-Dcom.navis.bridge.settings.FILE=${BRIDGED_BASE}/conf/ecn4_settings_prod.xml \
-Desb.settings.file=${NAVIS_SHARED}/conf/n4-settings.xml"

# Force our working directory to be BRIDGED_HOME
cd $BRIDGED_HOME

# Start BRIDGED
"$JAVA_HOME"/bin/java $JAVA_ARGS $JAVA_OPTS -jar $BRIDGED_HOME/lib/n4-bridged.jar "$@"  &
echo $! > $pidfile
exit 0