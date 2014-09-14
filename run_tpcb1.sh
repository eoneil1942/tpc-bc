#!/usr/bin/env bash
# 
# eoneil: TPCB script, single host case, Voltdb or CVoltdb
# and here VOLTROOT is a parameter 
# Added targets for running with asserts enabled: server-ea, client-ea

APPNAME="tpcb"
VOLTROOT=../$1
MP_PERCENT=$3
VOLTJAR=`ls $VOLTROOT/voltdb/voltdb-[23].*.jar`
CLASSPATH=$({ \
    \ls -1 $VOLTROOT/voltdb/voltdbclient-[23].*.jar; \
    \ls -1 "$VOLTROOT"/lib/*.jar; \
    \ls -1 "$VOLTROOT"/lib/extension/*.jar; \
} 2> /dev/null | paste -sd ':' - )
echo CLASSPATH: $CLASSPATH
#CLASSPATH="$VOLTJAR:../$VOLTROOT/lib" #:./obj/com:./obj/com/procedures"
VOLTDB="$VOLTROOT/bin/voltdb"
VOLTCOMPILER="$VOLTROOT/bin/voltcompiler"
LICENSE="$VOLTROOT/voltdb/license.xml"
LEADER="localhost"
BRANCHES=6

# remove build artifacts
function clean() {
    rm -rf obj debugoutput $APPNAME.jar voltdbroot plannerlog.txt
}

# compile the source code for procedures and the client
function srccompile() {
    mkdir -p obj
    javac -classpath $CLASSPATH -d obj \
        src/com/*.java \
        src/com/procedures/*.java \
        src/com/tpcbprocedures/*.java
    # stop if compilation fails
    if [ $? != 0 ]; then exit; fi
}

# build an application catalog, VoltDB case
function catalog-v() {
    srccompile
    $VOLTCOMPILER obj tpcb-project.xml $APPNAME.jar
    # stop if compilation fails
    if [ $? != 0 ]; then exit; fi
}

# CVoltdb build-catalog: use cv version of project.xml
function catalog-cv() {
    srccompile
    $VOLTCOMPILER obj tpcb-cv-project.xml $APPNAME.jar
    # stop if compilation fails
    if [ $? != 0 ]; then exit; fi
}

# run the voltdb server locally 
function server() {
    # if a catalog doesn't exist, build one
    if [ ! -f $APPNAME.jar ]; then catalog; fi
    # run the server
    echo running server with $APPNAME.jar
    $VOLTDB create catalog $APPNAME.jar deployment deployment.xml \
        license $LICENSE leader $LEADER
}

# added by eoneil--run the voltdb server locally with assertions on
function server-ea() {
    # if a catalog doesn't exist, build one
    if [ ! -f $APPNAME.jar ]; then catalog; fi
    # run the server
    echo running server with $APPNAME.jar
    # add -ea to flags to enable asserts--
    VOLTDB_OPTS=-ea; export VOLTDB_OPTS
    $VOLTDB create catalog $APPNAME.jar deployment deployment.xml \
        license $LICENSE leader $LEADER
}

# run the client that drives the tpcb example
# MP-percent=15 is the TPCB standard
function client() {
    srccompile
    java -classpath obj:$CLASSPATH:obj com.MyTPCB \
        --servers=localhost \
        --duration=60 \
        --branches=$BRANCHES \
        --MP-percent=$MP_PERCENT
}

# eoneil: with assertions on
function client-ea() {
    srccompile
    java -classpath obj:$CLASSPATH:obj -ea com.MyTPCB \
        --servers=localhost \
        --duration=60 \
        --branches=$BRANCHES \
        --MP-percent=$MP_PERCENT
}
function help() {
    echo "Usage: ./run_tpcbx.sh voltrootdir {clean|catalog-v|catalog-cv|server|server-ea|client|client-ea}"
}

# Run the server in the dir passed as the first arg on the command line
# Use the command that is the second arg
if [ $# -gt 3 ]; then help; exit; fi
if [ $# = 3 ]; then $2; fi
if [ $# = 2 ]; then $2; fi
if [ $# -le 1 ]; then help; fi
