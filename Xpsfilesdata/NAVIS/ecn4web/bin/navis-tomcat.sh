#!/usr/bin/env bash
# Copyright (c) 2011 Navis LLC All Rights Reserved.


# Some useful functions
function badcat() {
    echo "The CATALINA_HOME environment variable is not defined correctly."
    echo "Please ensure that this environment variable is set properly and the shell scripts in the \$CATALINA_HOME/bin' directory have executable permisions set."
    exit 1
 }

function usage() {
    printf "Usage: %s: [-n node] [-a coherence multicast address] [-t coherence multicast TTL] [ -i node identity] [-l (enable coherence local storage)] [-d (run in developer mode)] [-k (force shutdown)] start|stop|restart\n" $0 >&2
}

# Find out where we live (making sure to resolve the symbolic links).
PRG="$0 $@"
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


# Get our command line options...
while getopts 'n:a:t:i:lkdr' OPTION
  do
  case $OPTION in
    n)  node="$OPTARG";;
    a)  cluster="$OPTARG";;
    t)  ttl="$OPTARG";;
    i)  identity="$OPTARG";;
    l)  localstorage="true";;
    d)  developer="true";;
    k)  force=1;;
    r)  runinprocess="true";;
    ?)  usage; exit 2;;
  esac
done
shift $(($OPTIND-1))

# If JRE_HOME is not set. Set it to JAVA_HOME
[ -z "JRE_HOME" ] && [ -d "$JAVA_HOME" ] && JRE_HOME="$JAVA_HOME"

# Some reasonable defaults for CATALINA_HOME AND CATALINA_BASE
[ -z "$CATALINA_HOME" ] && CATALINA_HOME=`cd "$PRGDIR/.." ; pwd`

# If NAVIS_BASE is set put CATALINA BASE THERE
[ ! -z "$NAVIS_BASE" ] && [ $node ] && CATALINA_BASE="$NAVIS_BASE/$node"
[ -z "$CATALINA_BASE" ] && [ $node ] && CATALINA_BASE="$CATALINA_HOME/instances/$node"
[ -z "$CATALINA_BASE" ] && CATALINA_BASE=$CATALINA_HOME


# Load up our config files.

[ -e "$CATALINA_HOME"/bin/"${node}.conf" ] && echo "Use of the node.conf configuration files in the CATALINA_HOME/bin directories is deprecated. Please please move these files to CATALINA_BASE/conf/sparcsn4.conf"

[ -e "$CATALINA_HOME"/conf/navis-tomcat.conf ] && source "$CATALINA_HOME"/conf/navis-tomcat.conf

[ -e "$CATALINA_BASE"/conf/"navis-tomcat.conf" ] && source "$CATALINA_BASE"/conf/"navis-tomcat.conf"

# Where does our PID file live?
[ -z $CATALINA_PID ] && CATALINA_PID="$CATALINA_BASE/logs/catalina.pid"
echo $CATALINA_PID
export CATALINA_HOME CATALINA_BASE CATALINA_PID


# Set Java memory options
case $@ in
    start|restart)
        if [ "$JVM_MEMORY_OPTS" ]
            then
                jvm_memory="$JVM_MEMORY_OPTS"
                echo "Overriding default jvm memory with $JVM_MEMORY_OPTS"
            else
            # Allow for parameterizing memory requirements.
                [ $JAVA_MEMORY_POOL_MAX ] || JAVA_MEMORY_POOL_MAX=2844M
                [ $JAVA_MEMORY_POOL_MIN ] || JAVA_MEMORY_POOL_MIN=2844M
                [ $JAVA_MEMORY_MAXPERMSIZE ] || JAVA_MEMORY_MAXPERMSIZE=300M
               jvm_memory="-Xmx${JAVA_MEMORY_POOL_MAX} -Xms${JAVA_MEMORY_POOL_MIN} -XX:MaxPermSize=${JAVA_MEMORY_MAXPERMSIZE}"
            fi
       ;;
esac


# Clustering options

case $@ in
    start|restart)
    # Set the cluster container identity string if we've got one.
    [ $identity ] && CONTAINER_IDENTITY=$identity
    [ $CONTAINER_IDENTITY ] && environment_container_identity="-Denvironment.container.identity=${CONTAINER_IDENTITY}"

    # Check if a Terracotta URL exists.
    if [ $N4_TERRACOTTA_SERVERURL ]
        then teracotta="-Dterracotta.server.url=$N4_TERRACOTTA_SERVERURL"

        # If no Terracotta we're doing Oracle Coherence...
        else
            if [ -e "$OVERRIDE_FILE" ]
                then
                    override_file="-Dtangosol.coherence.override=${OVERRIDE_FILE}"
                else
                if [ -z "$NAVIS_SHARED" ] && [ -e "$PRGDIR/../../conf" ]
                   then
                        NAVIS_SHARED=`cd "$PRGDIR/../../conf" ; pwd`
                fi
                if [ -e "$NAVIS_SHARED"/tangosol-coherence-override-prod.xml ]
                    then
                        override_file="-Dtangosol.coherence.override=${NAVIS_SHARED}/tangosol-coherence-override-prod.xml"
                fi
            fi
            # Old Coherence flags for backward compatibility...
            [ $cluster ] && TANGOSOL_CLUSTERADDRESS=$cluster
            [ $ttl ] && TANGOSOL_TTL=$ttl
            TANGOSOL_LOCALSTORAGE="false"
            [ $localstorage ] && TANGOSOL_LOCALSTORAGE="true"

            # Coherence system properties
            [ "$TANGOSOL_CLUSTERADDRESS" ] && tangosol_coherence_address="-Dtangosol.coherence.clusteraddress=${TANGOSOL_CLUSTERADDRESS}"
            [ "$TANGOSOL_TTL" ] && tangosol_coherence_ttl="-Dtangosol.coherence.ttl=${TANGOSOL_TTL}"
            tangosol_coherence_localstorage="-Dtangosol.coherence.distributed.localstorage=${TANGOSOL_LOCALSTORAGE}"
     fi
     ;;
esac

# For Oracle RAC
[ "$ORACLE_HOME" ] && oracle_home="-Doracle.ons.oraclehome=${ORACLE_HOME}"

# Allow for remote monitoring.
# To enable specify JMX_REMOTE_PORT, for now, admins must secure this port outside for security
case $@ in
  start|restart)
        [ "$NAVIS_JMXREMOTE_PORT"  ] && jmx_remote_port="-Dcom.sun.management.jmxremote.port=${NAVIS_JMXREMOTE_PORT}"
    if [ "$NAVIS_JMXREMOTE_PORT" ]
      then
      export HQ_OPTS=" ${jmx_remote_port}  -Dcom.sun.management.jmxremote.ssl=false -Dcom.sun.management.jmxremote.authenticate=false"
      echo "Using HQ_OPTS:   $HQ_OPTS"
    fi
  ;;
esac

# To enable debugging specify DEBUG_PORT
case $@ in
  start|restart)
  if [ "$N4TOMCAT_DEBUG_PORT"  ]
    then
      debug="-Xdebug -Xnoagent -Djava.compiler=NONE -Xrunjdwp:transport=dt_socket,server=y,suspend=n,address=$N4TOMCAT_DEBUG_PORT"
      echo "Using DEBUG_PORT: $N4TOMCAT_DEBUG_PORT"
    fi
  ;;
esac
# Yourkit schtuff
case $@ in
  start|restart)
    if [ $YOUR_KIT_PROFILER_HOME ]
        then
            uname
            case `uname` in
                Darwin) os_platform="mac"; yjp_lib="libyjpagent.jnilib" ;;
                Linux)
                    case `uname -m` in
                        x86_64) os_platform="linux-x86-64" ;;
                        i686|i386) os_platform="linux-x86-32" ;;
                    esac
                    yjp_lib="libyjpagent.so" ;;
                 CYGWIN*) os_platform="win32"; yjp_lib="yjpagent.dll" ;;
             esac
            echo "YOUR_KIT_PROFILER_HOME: ${YOUR_KIT_PROFILER_HOME}"
            [ -d "$YOUR_KIT_PROFILER_HOME" ] && printf "Cannot find a functioning YourKit\n. The YOUR_KIT_PROFILER_HOME environment variable must be set and point to the YourKit Java Profiler home directory.\n"
            JAVA_OPTS=$JAVA_OPTS -agentpath:"$YOUR_KIT_PROFILER_HOME"/bin/${os_platform}/${yjp_lib}=sessionname=Tomcat
     fi
esac

# Set our Java Options when starting the tomcat...

if [ ! -d "${CATALINA_BASE}/logs" ]
    then
        mkdir "${CATALINA_BASE}/logs"
fi
if [ ! -d "${CATALINA_BASE}/temp" ]
    then
        mkdir "${CATALINA_BASE}/temp"
fi

# This is how we start things...
function start() {
# Our friendly neighborhood start script.
  if [ "$runinprocess" == "true" ]; then
      EXECUTABLE="${CATALINA_HOME}/bin/catalina.sh run"
    else
      EXECUTABLE="${CATALINA_HOME}/bin/startup.sh"
    fi

# Check to see if there is already a tomcat running.
  if [ -e $CATALINA_PID ]
    then
        kill -0 `cat $CATALINA_PID`
        if [ $? == 0 ]; then printf "Tomcat $node is already running with process id: `cat $CATALINA_PID`\n" >&2; exit 1;
            else rm -f $CATALINA_PID
        fi
  fi


# The default JMX port
[ -z "$NAVIS_JMXREMOTE_PORT" ] && NAVIS_JMXREMOTE_PORT="8019"

# Only set external config folder and n4-settings.xml if not in developer mode

if [ "$NAVIS_APP" = "sparcsn4" ]; then 
[ "$developer" != "true" ] && cache_and_esb_settings="-Dnavis.external.config.shared=//${NAVIS_SHARED}/conf -Desb.settings.file=${NAVIS_SHARED}/conf/n4-settings.xml" 
fi

# log directory for ecn4web log file 
if [ "$NAVIS_APP" = "ecn4web" ]; then 
ecn4web_log_dir="-Dcom.navis.ecn4web.log.dir=${CATALINA_BASE}/logs"
ecn4_server_address="-Dcom.navis.ecn4web.ecn4.server.address=${ECN4_ADDRESS}"
fi

if [ -f /etc/init.d/sparcsn4cluster ]; then
override_center="-Doverride.center=true"
fi

# Set our JAVA_OPTS and start this sucker.
    export JAVA_OPTS="${JAVA_OPTS} ${HQ_OPTS} ${debug} ${jvm_memory} \
-Djava.awt.headless=true \
-Dnavis.jvm.shutdown=true \
-Dfile.encoding=UTF-8 \
-Dcatalina.home=${CATALINA_HOME} \
-Dcatalina.base=${CATALINA_BASE} \
-Djava.library.path=${CATALINA_HOME}/webapps/apex/WEB-INF/native/lib64 \
-Djava.security.auth.login.config=${CATALINA_HOME}/conf/jaas.conf \
-Djava.endorsed.dirs=${CATALINA_HOME}/endorsed \
-Djava.io.tmpdir=${CATALINA_BASE}/temp \
-XX:+HeapDumpOnOutOfMemoryError \
-XX:HeapDumpPath=${CATALINA_BASE}/logs/ \
-XX:ErrorFile=${CATALINA_BASE}/logs/hs_err_pid%%p.log \
-verbose:gc \
-XX:+PrintGCDetails \
-XX:+PrintGCDateStamps \
-Xloggc:${CATALINA_BASE}/logs/gc.log \
-XX:+UseG1GC \
-XX:MaxGCPauseMillis=750 \
-XX:InitiatingHeapOccupancyPercent=45 \
-Dcom.sun.management.jmxremote.port=${NAVIS_JMXREMOTE_PORT} \
-Dcom.sun.management.jmxremote.ssl=false \
-Dcom.sun.management.jmxremote.authenticate=false \
-Dorg.apache.activemq.store.kahadb.LOG_SLOW_ACCESS_TIME=3000 \
${cache_and_esb_settings} ${oracle_home} ${environment_container_identity} ${terracotta} ${tangosol_coherence_address} ${tangosol_coherence_ttl} ${tangosol_coherence_localstorage} ${override_file} ${override_center} ${ecn4web_log_dir} ${ecn4_server_address}"

# Make sure CATALINA_HOME is set properly and that the startup script has the executable bit set...
[ ! -x $EXECUTABLE ] && badcat

# Force our working directory to be Tomcat's bin directory.
cd $CATALINA_HOME

# Geronimo!
$EXECUTABLE
}

# This is how we stop them...
function stop() {

# Our friendly neighborhood shut down script.
EXECUTABLE="${CATALINA_HOME}/bin/shutdown.sh"

# A message we might need later...
    [ $node ] && nodee="$node "
    asd_message="Tomcat ${nodee}is already shut down."

# A limited set of JAVA_OPTS for shutdown
    export JAVA_OPTS="${JAVA_OPTS} -Djava.awt.headless=true \
-Dnavis.jvm.shutdown=true \
-Dfile.encoding=UTF-8 \
-Dcatalina.home=${CATALINA_HOME} \
-Dcatalina.base=${CATALINA_BASE} \
-Djava.endorsed.dirs=${CATALINA_HOME}/endorsed \
-Djava.io.tmpdir=${CATALINA_BASE}/temp"

# Make sure CATALINA_HOME is set properly and that the shut down script has the executable bit set...
[ ! -x $EXECUTABLE ] && batcat

    if [ -e "$CATALINA_PID" ];
      then
          kill -0 `cat $CATALINA_PID`
          if [ $? == 0 ];
              then
                  [ $force ] &&  $EXECUTABLE -force && exit 0
                  [ -z $force ] && $EXECUTABLE
                else
                  echo "$asd_message"
                  rm -f $CATALINA_PID;
            fi
        else
          echo "$asd_message"
    fi
}

# Finally we get around to actually doing this thing...
case $@ in
  start) start;;
  stop)  stop;;
    restart) stop; start;;
  *)  usage ; exit 2;;
esac
