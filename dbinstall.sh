#!/bin/ksh
#
# $Header: /willi/aida-v1/SSWE/db/dbinstall/RCS/dbinstall,v 1.9 1997/08/29 14:45:10 bartsch Exp $
#
# *************************************************************
# Danet GmbH Darmstadt / GS-AN
# *************************************************************
#
# Filename:
#   dbinstall  
# Version:
#   1.1.8
# Authors:
#   SBartsch
# CreationDate:
#   19.06.97
# Last Modified:
#   25.08.97 SBartsch - rename all DB_NETMOS_* references -> DB_AIDA_*
#   20.08.97 SBartsch - bug fix in do_import()/do_export(): 
#                       use system/$DB_NETMOS_PWSYSTEM
#   18.08.97 SBartsch - bug fixes in do_checkdir(), do_cleanup()
#                       do_checkdir(): mkdir -p
#                       do_checkdir(): no file check if -base option
#                       do_cleanup():  shutdown abort
#                     - add SQL*Loader bad file destination
#   13.08.97 SBartsch - modify do_checkdb(): check [ ! -r ] only
#                     - modify dbinstall logfile switch
#   07.08.97 SBartsch - add new variables for password handling
#                     - DB_NETMOS_PWOWNER  -> Oracle NetMOS owner
#                     - DB_NETMOS_PWSYS    -> Oracle SYS    owner
#                     - DB_NETMOS_PWSYSTEM -> Oracle SYSTEM owner
#   28.07.97 SBartsch - modify do_load(): read loader files from load_data.in
#   24.07.97 SBartsch - add DB_NETMOS_BLOCKSIZE variable
#                     - add DB_NETMOS_SPOOLDIR variable
#   23.07.97 SBartsch - add -sqlnet option: do_sqlnet()
#                     - add hostname check
#                     - bug fixes
#   03.07.97 SBartsch - improve user interface
#   02.07.97 SBartsch - add do_write_env(), do_export_env() 
#                     - enable generating of dynamic 'dbinstallenv'-file
#                     - cleanup all *$ORACLE_SID*.*  files before patching
#                     - cleanup all tmp files after patching
#   30.06.97 SBartsch - add $DB_NETMOS_ARCHDIR; merge source (option -reinit)
#                     - add option -export
#                     - cleanup source code
#   29.06.97 SBartsch - bug fix:  do_cleanup() will now remove files
#   27.06.97 SBartsch - enhance do_patch(): patch redo log + control files
#                       add user prompts for this input information
#                     - minor echo modifications
#   26.06.97 FJL      - reinit Parameter eingefuegt
#   24.06.97 SBartsch - improve user interface
#   23.06.97 SBartsch - add user prompts/cleanup
#   20.06.97 SBartsch - change installation sequence
# Abstract:
#   used for creating/installing complete AIDA-DB
# 
#
DB_AIDA_VERSION="V1.1.9"

#set -x


# ------------------------------------------------------------
#  Display abort message on interupt.
# ------------------------------------------------------------
trap 'echo "AIDA DB-Installation Aborted!"; exit' 1 2 3 15

# ------------------------------------------------------------
#  Allow verification/trace to be turned on and off.
# ------------------------------------------------------------
case $DB_AIDA_TRACE in
    T)  set -x ;;
esac

# ------------------------------------------------------------
# store process-id for using in temp file names
# ------------------------------------------------------------
id=$$

# ------------------------------------------------------------
# Determine how to suppress newline with echo command.
# ------------------------------------------------------------
case ${N}$C in
    "") if echo "\c" | grep c >/dev/null 2>&1; then
            N='-n'
        else
            C='\c'
        fi ;;
esac

# ------------------------------------------------------------
# define all shell functions
# ------------------------------------------------------------

usage()
{
clear
echo "------------------------------------------------------------------------"
echo "AIDA DB-Installer: Installation options"
echo "------------------------------------------------------------------------"
echo >&2 "
Usage: $scriptname -sid ORACLE_SID [-default|-base|-cleanup|-create|-load|
                                     -export|-import|-reinit]

Action:
   -?          : help
   -help       : help
   -default    : standard installation (create DB + import Data)
   -base       : basic installation (create DB / Objects + load Data)
   -cleanup    : remove files from previous installation cycle
   -create     : [all | database | objects] create basic database [+ objects]
   -export     : export full application database
   -import     : import full application database
   -load       : load data
   -reinit     : reload data from import file
   -sqlnet     : generate SQL*Net control files
   -test       : spotcheck tests
 
E.g.:  $scriptname -sid netmos -create 
"
exit 1
}

do_debug()
{
  $debug echo >&2 "DBG: $* "
}

do_log()
{
  echo "$1" | tee -a $DB_AIDA_LOG
}

do_errcheck()
{
  if [ ! $? -eq 0 ]; then
     DB_AIDA_ERR="Y"
  fi
}

do_fatal_error()
{
do_log "
$1

Installation ended up with a fatal error.
Please see $DB_AIDA_LOG for further information.
" 
do_log "
------------------------------------------------------------------------
End of AIDA DB-Installation [Option=$opt] : `date`
------------------------------------------------------------------------
" 
exit 0
}


# ------------------------------------------------------------
# Read an input or use a default value with optional escape to sh.
#       usage:    DEFLT=<default> ; . read.sh ; SH_VAR=$RDVAR
#  Use a ! to escape to a sub-shell. When you exit from the
#  sub-shell you may still enter a new value or use the displayed
#  default.  If the variable DB_AIDA_DEFAULT is set to T, then don't
#  do a read, but just take the DEFLT value.
# ------------------------------------------------------------

do_read()
{
case $DB_AIDA_DEFAULT in
    T)	RDVAR=$DEFLT ; echo "$DEFLT" ;;
    *)	while :
	do
	    echo $N "[${DEFLT}]: $C"
            if [ "$1" = "NOECHO" ]; then
              stty -echo
            fi
	    read RDVAR
            if [ "$1" = "NOECHO" ]; then
              stty echo
              echo " "
            fi
	    case $RDVAR in
		"")	RDVAR=$DEFLT ; break ;;
		!*)	${SHELL-/bin/sh} ; echo ;;
		*)	break ;;
	    esac
	done ;;
esac
}

do_write_env()
{
do_debug $*
timestamp=`date`

cat 1> $HOME/$DB_AIDA_ENVFILE 2>> $DB_AIDA_LOG <<EOF

# =======================================================================
# Generated by AIDA DB-Installer $DB_AIDA_VERSION : $timestamp
# =======================================================================

# ------------------------------------------------------------------------
#  set ORACLE environment 
# ------------------------------------------------------------------------

ORACLE_HOME=$ORACLE_HOME
ORACLE_SID=$ORACLE_SID
export ORACLE_HOME ORACLE_SID

NLS_LANG=German_Germany.WE8ISO8859P1
ORA_NLS32=$ORACLE_HOME/ocommon/nls/admin/data
export NLS_LANG ORA_NLS32

#
# The following removes trailing colon from PATH and adds ORACLE_HOME/bin
#

case \$PATH in
	*\$ORACLE_HOME/bin*)  ;;
	*:) PATH=\${PATH}\$ORACLE_HOME/bin  ;;
	*)  PATH=\${PATH}:\$ORACLE_HOME/bin   ;;
esac

# --------------------------------------------------------------------------
# Make sure the local bin directory is in the path.
# --------------------------------------------------------------------------

case \$PATH in
	*/usr/lbin*)  ;;
	*:) PATH=\${PATH}/usr/lbin  ;;
	*)  PATH=\${PATH}:/usr/lbin   ;;
esac
export PATH

# ------------------------------------------------------------------------
# set general environment variables for AIDA DB-Installer
# ------------------------------------------------------------------------

# 
# set FTP environment
# 
FTP="/usr/bin/ftp -n "
export FTP

# 
# set SQL*DBA/Server Manager environment
#
SQLDBA=$ORACLE_HOME/bin/svrmgrl
export SQLDBA 

# 
# set SQL*Plus environment
#
SQLPLUS=$ORACLE_HOME/bin/sqlplus
export SQLPLUS 

#
# set SQL*Loader environment
#
SQLLOADER="$ORACLE_HOME/bin/sqlload" 
export SQLLOADER 
 
#
# set Export environment
#
EXP="$ORACLE_HOME/bin/exp"		
export EXP
#
# set Import environment
#
IMP="$ORACLE_HOME/bin/imp"
export IMP

# ------------------------------------------------------------------------
# export special environment variables for AIDA DB-Installer
# ------------------------------------------------------------------------

DB_AIDA_BASE=$DB_AIDA_BASE;         export DB_AIDA_BASE

DB_AIDA_DATADIR=$DB_AIDA_DATADIR;   export DB_AIDA_DATADIR
DB_AIDA_REDODIR=$DB_AIDA_REDODIR;   export DB_AIDA_REDODIR
DB_AIDA_ARCHDIR=$DB_AIDA_ARCHDIR;   export DB_AIDA_ARCHDIR
DB_AIDA_MIRRDIR=$DB_AIDA_MIRRDIR;   export DB_AIDA_MIRRDIR
DB_AIDA_SPOOLDIR=$DB_AIDA_SPOOLDIR; export DB_AIDA_SPOOLDIR

DB_AIDA_DUMPDIR=$DB_AIDA_DUMPDIR;   export DB_AIDA_DUMPDIR
DB_AIDA_IMPFILE=$DB_AIDA_IMPFILE;   export DB_AIDA_IMPFILE
DB_AIDA_EXPFILE=$DB_AIDA_EXPFILE;   export DB_AIDA_EXPFILE
DB_AIDA_LOADDIR=$DB_AIDA_LOADDIR;   export DB_AIDA_LOADDIR

DB_AIDA_ADMDIR=$DB_AIDA_ADMDIR;     export DB_AIDA_ADMDIR
DB_AIDA_LOGDIR=$DB_AIDA_LOGDIR;     export DB_AIDA_LOGDIR
DB_AIDA_TMPDIR=$DB_AIDA_TMPDIR;     export DB_AIDA_TMPDIR
# DB_AIDA_ENVDIR=$DB_AIDA_ENVDIR;     export DB_AIDA_ENVDIR
DB_AIDA_ENVFILE=$DB_AIDA_ENVFILE;   export DB_AIDA_ENVFILE
DB_AIDA_TRACE=$DB_AIDA_TRACE;       export DB_AIDA_TRACE
DB_AIDA_DEFAULT=$DB_AIDA_DEFAULT;   export DB_AIDA_DEFAULT

DB_AIDA_OWNER=${DB_AIDA_OWNER:="netmos"};  export DB_AIDA_OWNER
DB_AIDA_PWOWNER=${DB_AIDA_PWOWNER:="netmos"}; export DB_AIDA_PWOWNER
DB_AIDA_PWSYS=${DB_AIDA_PWSYS:="change_on_install"}; export DB_AIDA_PWSYS
DB_AIDA_PWSYSTEM=${DB_AIDA_PWSYSTEM:="manager"}; export DB_AIDA_PWSYSTEM

DB_AIDA_HOSTNAME=$DB_AIDA_HOSTNAME; export DB_AIDA_HOSTNAME
DB_AIDA_BLOCKSIZE=$DB_AIDA_BLOCKSIZE; export DB_AIDA_BLOCKSIZE

EOF
}

do_export_env()
{

# ------------------------------------------------------------------------
# !! set ORACLE environment !!
#
# !! ORACLE_HOME and ORACLE_SID must be set before !!
# ------------------------------------------------------------------------

export ORACLE_HOME ORACLE_SID

NLS_LANG=German_Germany.WE8ISO8859P1
ORA_NLS32=$ORACLE_HOME/ocommon/nls/admin/data
export NLS_LANG ORA_NLS32

#
# The following removes trailing colon from PATH and adds ORACLE_HOME/bin
#

case $PATH in
	*$ORACLE_HOME/bin*)  ;;
	*:) PATH=${PATH}$ORACLE_HOME/bin  ;;
	*)  PATH=${PATH}:$ORACLE_HOME/bin   ;;
esac

# --------------------------------------------------------------------------
# Make sure the local bin directory is in the path.
# --------------------------------------------------------------------------

case $PATH in
	*/usr/lbin*)  ;;
	*:) PATH=${PATH}/usr/lbin  ;;
	*)  PATH=${PATH}:/usr/lbin   ;;
esac
export PATH

# ------------------------------------------------------------------------
# set general environment variables for AIDA DB-Installer
# ------------------------------------------------------------------------

# 
# set FTP environment
# 
FTP="/usr/bin/ftp -n "
export FTP

# 
# set SQL*DBA/Server Manager environment
#
SQLDBA=$ORACLE_HOME/bin/svrmgrl
export SQLDBA 

# 
# set SQL*Plus environment
#
SQLPLUS=$ORACLE_HOME/bin/sqlplus
export SQLPLUS 

#
# set SQL*Loader environment
#
SQLLOADER="$ORACLE_HOME/bin/sqlload" 
export SQLLOADER 
 
#
# set Export environment
#
EXP="$ORACLE_HOME/bin/exp"		
export EXP
#
# set Import environment
#
IMP="$ORACLE_HOME/bin/imp"
export IMP

# ------------------------------------------------------------------------
# export special environment variables for AIDA DB-Installer
# ------------------------------------------------------------------------

export DB_AIDA_BASE

export DB_AIDA_DATADIR
export DB_AIDA_REDODIR
export DB_AIDA_ARCHDIR
export DB_AIDA_MIRRDIR
export DB_AIDA_SPOOLDIR

export DB_AIDA_DUMPDIR
export DB_AIDA_IMPFILE
export DB_AIDA_EXPFILE
export DB_AIDA_LOADDIR

export DB_AIDA_ADMDIR
export DB_AIDA_LOGDIR
export DB_AIDA_TMPDIR
export DB_AIDA_ENVDIR
export DB_AIDA_ENVFILE
export DB_AIDA_TRACE
export DB_AIDA_DEFAULT

export DB_AIDA_OWNER
export DB_AIDA_PWOWNER
export DB_AIDA_PWSYS
export DB_AIDA_PWSYSTEM

export DB_AIDA_HOSTNAME
export DB_AIDA_BLOCKSIZE

}

do_checkdir()
{
do_debug $*

while : ; do

  #  Get name of DB $3 directory.
  echo " "
  echo $N "Enter full pathname of the $3 directory = $N"
  DEFLT=$1; do_read; CHECKDIR=$RDVAR 

  if [ ! -d "$CHECKDIR" ]; then
     echo " "
     do_log "!! $3 directory not found !!"
     if [ "$4" = "CREATE" ]; then
        echo $N "Do you want the Installer to create the $3 directory (Y/N)? $C"
        DEFLT="Y"; do_read; ANSWER=$RDVAR 
        case $ANSWER in
            Y|y) mkdir -p $CHECKDIR
   	         if [ ! $? -eq 0 ]; then
                    echo " "
                    do_log "Can not create $3 directory $CHECKDIR !!" 
                    echo " "
   	            echo "Please create the necessary $3 directory."
	            do_log "Exiting AIDA DB-Installation." 
                    exit 0 
	         fi 
                 do_log ""
                 do_log "Check $3 directory for write privileges..."
                 touch $CHECKDIR/file$$ >> $DB_AIDA_LOG 2>&1
                 if [ ! $? -eq 0 ]; then
                     do_log " - No write privileges for $CHECKDIR !!"
                     do_log " "
                     echo "Check access rights, then restart installation."
          	     do_log "Exiting AIDA DB-Installation."
                     exit 1
                 fi
                 rm -f $CHECKDIR/file$$ >> $DB_AIDA_LOG 2>&1
                 break
                 ;;
            *)   echo " "
   	         echo "Please create the necessary $3 directory."
  	         do_log "Exiting AIDA DB-Installation."
                 exit 1 
                 ;;
        esac
     fi
  else
     if [ "$4" = "CREATE" ]; then
        do_log ""
        do_log "Check $3 directory for write privileges..."
        touch $CHECKDIR/file$$ >> $DB_AIDA_LOG 2>&1
        if [ ! $? -eq 0 ]; then
            do_log " - No write privileges for $CHECKDIR !!"
            do_log " "
            echo "Check access rights, then restart installation."
	    do_log "Exiting AIDA DB-Installation."
            exit 1
        fi
        rm -f $CHECKDIR/file$$ >> $DB_AIDA_LOG 2>&1
     fi
     break
  fi 2>> $DB_AIDA_LOG 

done
}

do_checkdb()
{
  do_log " Checking that database is running..."
  if [ !  -r $ORACLE_HOME/dbs/sgadef${ORACLE_SID}.dbf ] ; then
     do_log " - starting database <${ORACLE_SID}> ."

     $SQLDBA  <<EOF >> $DB_AIDA_LOG 2>&1
       connect internal
       startup
       exit
EOF
     if [ ! -r $ORACLE_HOME/dbs/sgadef${ORACLE_SID}.dbf ] ; then
        do_fatal_error " Error encountered when starting database <${ORACLE_SID}> !! ."
     fi
  else
     do_log " - <${ORACLE_SID}> database is running."
  fi
}

do_cleanup()
{
  do_remove_file()
  {
  do_debug $*
  files_found="N"
  #do_log "`ls $1`"
  for i in `ls $1`
  do
    files_found="Y"
    if [ -w "$i" ] ; then
       rm "$i" 1>> $DB_AIDA_LOG 2>&1
       do_errcheck
       do_log " - $2 file $i removed."
    else
       do_log " - Can not remove $2 file $i" 
    fi  2>> $DB_AIDA_LOG
  
  done 2>> $DB_AIDA_LOG
  if [ $files_found = "N" ]; then
     do_log " - No old <${ORACLE_SID}> $2 files found." 
  fi
  }

do_log "
Cleanup before installing AIDA-DB... (ORACLE_SID=`echo $ORACLE_SID`)
"
do_log " Checking that database is not running..."

if [ -w $ORACLE_HOME/dbs/sgadef${ORACLE_SID}.dbf ] ; then
   do_log " - <${ORACLE_SID}> database is running." 

   $SQLDBA  <<EOF >> $DB_AIDA_LOG 2>&1
     connect internal
     shutdown abort
     exit
EOF
else
   do_log " - <${ORACLE_SID}> database is not running." 
fi

# check for old data files

do_log "
Check for old data files...  
"
do_remove_file "${DB_AIDA_DATADIR}/nm_*.dbf" "data"

# check for old control files

do_log " 
Check for old control files...
"
do_remove_file "${DB_AIDA_DATADIR}/ctl*.ora" "control"

do_log " 
Check for old mirror files...
"
do_remove_file "${DB_AIDA_MIRRDIR}/ctl*.ora" "mirror"

# check for old redo log files

do_log "
Check for old redo log files...
"
do_remove_file "${DB_AIDA_REDODIR}/nm_log*.rdo" "redo log"

# check for old archive log files

do_log "
Check for old archive log files...
"
do_remove_file "${DB_AIDA_ARCHDIR}/nm_log*.dbf" "archive log"

do_log "
Check for old init files...
"
do_remove_file "${ORACLE_HOME}/dbs/*${ORACLE_SID}*.*" "init"

}

do_patch()
{
do_log "
Generating startup files for AIDA-DB... (ORACLE_SID=`echo $ORACLE_SID`)
" 

# Step1: patch configsid.ora 

pid=$$
cat > $DB_AIDA_TMPDIR/tmpsed$pid.sh << EOF
sed -e 's#<dbname>#$ORACLE_SID#g' \
    -e 's#<blocksize>#$DB_AIDA_BLOCKSIZE#g' \
    -e 's#<datadir>#$DB_AIDA_DATADIR#g' \
    -e 's#<archdir>#$DB_AIDA_ARCHDIR#g' \
    -e 's#<spooldir>#$DB_AIDA_SPOOLDIR#g' \
    -e 's#<mirrdir>#$DB_AIDA_MIRRDIR#g' $DB_AIDA_ADMDIR/configsid.ora > $DB_AIDA_TMPDIR/config$ORACLE_SID.ora.$pid
EOF

# execute sed script
chmod 750 $DB_AIDA_TMPDIR/tmpsed$pid.sh
$DB_AIDA_TMPDIR/tmpsed$pid.sh
$RM $DB_AIDA_TMPDIR/tmpsed$pid.sh >> $DB_AIDA_LOG 2>&1

# copy the generated file to ORACLE_HOME/dbs directory
cp $DB_AIDA_TMPDIR/config$ORACLE_SID.ora.$pid  \
$ORACLE_HOME/dbs/config$ORACLE_SID.ora  >> $DB_AIDA_LOG 2>&1
#chmod 660 $ORACLE_HOME/dbs/config$ORACLE_SID.ora
do_errcheck
$RM $DB_AIDA_TMPDIR/config$ORACLE_SID.ora.$pid 1>> $DB_AIDA_LOG 2>&1

# Step2: patch initsid_0.ora 

pid=$$
cat > $DB_AIDA_TMPDIR/tmpsed$pid.sh << EOF
sed -e 's#<dbname>#$ORACLE_SID#g' \
    -e 's#<oracle_home>#$ORACLE_HOME#g' $DB_AIDA_ADMDIR/initsid_0.ora > $DB_AIDA_TMPDIR/init${ORACLE_SID}_0.ora.$pid
EOF

# execute sed script
chmod 750 $DB_AIDA_TMPDIR/tmpsed$pid.sh
$DB_AIDA_TMPDIR/tmpsed$pid.sh
$RM $DB_AIDA_TMPDIR/tmpsed$pid.sh

# copy the generated file to ORACLE_HOME/dbs directory
cp $DB_AIDA_TMPDIR/init${ORACLE_SID}_0.ora.$pid \
$ORACLE_HOME/dbs/init${ORACLE_SID}_0.ora >> $DB_AIDA_LOG 2>&1
#chmod 660 $ORACLE_HOME/dbs/init${ORACLE_SID}_0.ora
do_errcheck
$RM $DB_AIDA_TMPDIR/init${ORACLE_SID}_0.ora.$pid 1>> $DB_AIDA_LOG 2>&1

# Step3: patch initsid.ora 

pid=$$
cat > $DB_AIDA_TMPDIR/tmpsed$pid.sh << EOF
sed -e 's#<dbname>#$ORACLE_SID#g' \
    -e 's#<oracle_home>#$ORACLE_HOME#g' $DB_AIDA_ADMDIR/initsid.ora > $DB_AIDA_TMPDIR/init$ORACLE_SID.ora.$pid
EOF

# execute sed script
chmod 750 $DB_AIDA_TMPDIR/tmpsed$pid.sh
$DB_AIDA_TMPDIR/tmpsed$pid.sh
$RM $DB_AIDA_TMPDIR/tmpsed$pid.sh

# copy the generated file to ORACLE_HOME/dbs directory
cp $DB_AIDA_TMPDIR/init$ORACLE_SID.ora.$pid  \
$ORACLE_HOME/dbs/init$ORACLE_SID.ora  >> $DB_AIDA_LOG 2>&1
#chmod 660 $ORACLE_HOME/dbs/init$ORACLE_SID.ora
do_errcheck
$RM $DB_AIDA_TMPDIR/init$ORACLE_SID.ora.$pid  1>> $DB_AIDA_LOG 2>&1

# Step4: patch crdb1sid.sql

pid=$$
cat > $DB_AIDA_TMPDIR/tmpsed$pid.sh << EOF
sed -e 's#<dbname>#$ORACLE_SID#g' \
    -e 's#<datadir>#$DB_AIDA_DATADIR#g' \
    -e 's#<redodir>#$DB_AIDA_REDODIR#g' \
    -e 's#<mirrdir>#$DB_AIDA_MIRRDIR#g' $DB_AIDA_ADMDIR/crdb1sid.sql > $DB_AIDA_TMPDIR/crdb1$ORACLE_SID.sql.$pid
EOF

# execute sed script
chmod 750 $DB_AIDA_TMPDIR/tmpsed$pid.sh
$DB_AIDA_TMPDIR/tmpsed$pid.sh
$RM $DB_AIDA_TMPDIR/tmpsed$pid.sh

# copy the generated file to ORACLE_HOME/dbs directory
cp $DB_AIDA_TMPDIR/crdb1$ORACLE_SID.sql.$pid  \
$ORACLE_HOME/dbs/crdb1$ORACLE_SID.sql  >> $DB_AIDA_LOG 2>&1
#chmod 660 $ORACLE_HOME/dbs/crdb1$ORACLE_SID.sql
do_errcheck
$RM $DB_AIDA_TMPDIR/crdb1$ORACLE_SID.sql.$pid  1>> $DB_AIDA_LOG 2>&1

# Step5: generate crdb2sid.sql

pid=$$
cat > $DB_AIDA_TMPDIR/tmpsed$pid.sh << EOF
sed -e 's#<dbname>#$ORACLE_SID#' \
    -e 's#<datadir>#$DB_AIDA_DATADIR#' $DB_AIDA_ADMDIR/crdb2sid.sql > $DB_AIDA_TMPDIR/crdb2$ORACLE_SID.sql.$pid
EOF

# execute sed script
chmod 750 $DB_AIDA_TMPDIR/tmpsed$pid.sh
$DB_AIDA_TMPDIR/tmpsed$pid.sh
$RM $DB_AIDA_TMPDIR/tmpsed$pid.sh

# copy the generated file to ORACLE_HOME/dbs directory
cp $DB_AIDA_TMPDIR/crdb2$ORACLE_SID.sql.$pid  \
$ORACLE_HOME/dbs/crdb2$ORACLE_SID.sql  >> $DB_AIDA_LOG 2>&1
#chmod 660 $ORACLE_HOME/dbs/crdb2$ORACLE_SID.sql
do_errcheck
$RM $DB_AIDA_TMPDIR/crdb2$ORACLE_SID.sql.$pid  1>> $DB_AIDA_LOG 2>&1

# Step6: generate create_$DB_AIDA_OWNER.in

pid=$$
cat > $DB_AIDA_TMPDIR/tmpsed$pid.sh << EOF
sed -e 's#<netmos_owner>#$DB_AIDA_OWNER#' \
    -e 's#<netmos_pw>#$DB_AIDA_PWOWNER#' $DB_AIDA_ADMDIR/create_user.in > $DB_AIDA_TMPDIR/create_$DB_AIDA_OWNER.in.$pid
EOF

# execute sed script
chmod 750 $DB_AIDA_TMPDIR/tmpsed$pid.sh
$DB_AIDA_TMPDIR/tmpsed$pid.sh
$RM $DB_AIDA_TMPDIR/tmpsed$pid.sh

# copy the generated file to ORACLE_HOME/dbs directory
cp $DB_AIDA_TMPDIR/create_$DB_AIDA_OWNER.in.$pid  \
$ORACLE_HOME/dbs/create_$DB_AIDA_OWNER.in  >> $DB_AIDA_LOG 2>&1
#chmod 660 $ORACLE_HOME/dbs/create_$DB_AIDA_OWNER.in
do_errcheck
$RM $DB_AIDA_TMPDIR/create_$DB_AIDA_OWNER.in.$pid  1>> $DB_AIDA_LOG 2>&1

}

do_create()
{
do_log "
Creating AIDA-DB... (ORACLE_SID=`echo $ORACLE_SID`)
" 

# create DB (use separated SQL scripts: system + rest of DB)

if [ ! "$create_what" = "OBJ" ]; then 
   do_log " Create database <${ORACLE_SID}>...
         (This will take a few minutes) "

   $SQLDBA  <<EOF >> $DB_AIDA_LOG 2>&1
     connect internal
     @$ORACLE_HOME/dbs/crdb1$ORACLE_SID
     exit
EOF

   if [ ! -r "$DB_AIDA_DATADIR/nm_system.dbf" -o \
        ! -w $ORACLE_HOME/dbs/sgadef${ORACLE_SID}.dbf ] ; then

      $SQLDBA  <<EOF >> $DB_AIDA_LOG 2>&1
        connect internal
        shutdown abort
        exit
EOF
      do_fatal_error " Error encountered when creating database <${ORACLE_SID}> ." 
   fi

   do_log " Create data dictionary/tablespaces...
         (This will take a few minutes) "

   $SQLDBA  <<EOF >> $DB_AIDA_LOG 2>&1
     connect internal
     @$ORACLE_HOME/dbs/crdb2$ORACLE_SID
     exit
EOF

# shutdown/startup DB to activate all rollback segments
   do_log " Shutdown/Startup to activate all rollback segments... "

   $SQLDBA  <<EOF >> $DB_AIDA_LOG 2>&1
     connect internal
     shutdown normal
     exit
EOF
   $SQLDBA  <<EOF >> $DB_AIDA_LOG 2>&1
     connect internal
     startup 
     exit
EOF
# change default password for Oracle's SYS/SYSTEM user
  do_log " Changing SYS/SYSTEM passwords..."

     $SQLDBA  <<EOF >> $DB_AIDA_LOG 2>&1
       connect internal
       alter user SYS identified by $DB_AIDA_PWSYS;
       alter user SYSTEM identified by $DB_AIDA_PWSYSTEM;
       exit
EOF
fi

# !! substitute creating DB-Objects by importing data !!
if [ "$create_what" = "OBJ" -o "$create_what" = "ALL" -o $act = "BASE" ]; then 

   do_checkdb

   do_log " Create DB-Objects...
	 (This will take a few minutes)"

   # create user $DB_AIDA_OWNER as AIDA application owner
   $SQLDBA  <<EOF >> $DB_AIDA_LOG 2>&1
     connect internal
     @$ORACLE_HOME/dbs/create_$DB_AIDA_OWNER.in
     exit
EOF

   # create DB-Objects (use SQL*Plus due to ORA-00904 "prompt"-Problem)
   $SQLPLUS $DB_AIDA_OWNER/$DB_AIDA_PWOWNER <<EOF >> $DB_AIDA_LOG 2>&1
     @$DB_AIDA_ADMDIR/create_table.in
     exit
EOF
   $SQLPLUS $DB_AIDA_OWNER/$DB_AIDA_PWOWNER <<EOF >> $DB_AIDA_LOG 2>&1
     @$DB_AIDA_ADMDIR/create_trigger.in
     exit
EOF
fi

}

do_import() 
{
do_log "
Importing AIDA-DB... (ORACLE_SID=`echo $ORACLE_SID`)
    (This will take a few minutes)"

do_checkdb

do_log " Importing data..."

date "+%d-%h-%y" 1> $tsfile

# user SYSTEM is needed for importing data
# because user NETMOS might not have been created until this import step

echo "USERID=system/$DB_AIDA_PWSYSTEM" \
    1>> $DB_AIDA_TMPDIR/full.imp 2>> $DB_AIDA_LOG
cat <  $DB_AIDA_ADMDIR/full.tim          \
    >> $DB_AIDA_TMPDIR/full.imp
$IMP parfile=$DB_AIDA_TMPDIR/full.imp    >> $DB_AIDA_LOG   2>&1
do_errcheck
$RM $DB_AIDA_TMPDIR/full.imp

}

do_export() 
{
do_log "
Exporting AIDA-DB... (ORACLE_SID=`echo $ORACLE_SID`)
    (This will take a few minutes)"

do_checkdb

do_log " Exporting data..."

date "+%d-%h-%y" 1> $tsfile

# user SYSTEM is needed for exporting data
# because user NETMOS might not have been created until this import step

echo "USERID=system/$DB_AIDA_PWSYSTEM" \
    1>> $DB_AIDA_TMPDIR/full.exp 2>> $DB_AIDA_LOG
cat <  $DB_AIDA_ADMDIR/full.tex          \
    >> $DB_AIDA_TMPDIR/full.exp
$EXP parfile=$DB_AIDA_TMPDIR/full.exp    >> $DB_AIDA_LOG   2>&1
do_errcheck
$RM $DB_AIDA_TMPDIR/full.exp

}

do_delete()
{
do_log "
Delete AIDA Application Data from AIDA-DB... (ORACLE_SID=`echo $ORACLE_SID`)
    (This will take a few minutes)"

do_checkdb

# drop all DB-Objects of $DB_AIDA_OWNER
do_log " Drop user <${DB_AIDA_OWNER}>..."

#  @$DB_AIDA_ADMDIR/drop_user.in
$SQLDBA  <<EOF >> $DB_AIDA_LOG 2>&1
  connect internal
  drop user $DB_AIDA_OWNER cascade;
  exit
EOF
}

do_load()
{
do_log "
Loading AIDA-DB... (ORACLE_SID=`echo $ORACLE_SID`)
    (This will take a few minutes)"

do_checkdb

do_log " Loading data..."

for i in `cat $DB_AIDA_ADMDIR/load_data.in`
do
  # echo "$i" >> $DB_AIDA_LOG   2>&1
  $SQLLOADER userid=$DB_AIDA_OWNER/$DB_AIDA_PWOWNER control="$i" \
  log="$DB_AIDA_LOGDIR/`basename $i `.log" \
  bad="$DB_AIDA_LOGDIR/`basename $i `.bad" >> $DB_AIDA_LOG 2>&1
  do_errcheck
done

}

do_sqlnet()
{
do_log "
Generating SQL*Net control files for AIDA-DB... (ORACLE_SID=`echo $ORACLE_SID`)
" 

# Step1: patch listener_sid.ora 

pid=$$
timestamp=`date`
cat > $DB_AIDA_TMPDIR/tmpsed$pid.sh << EOF
sed -e 's#<dbname>#$ORACLE_SID#g' \
    -e 's#<hostname>#$DB_AIDA_HOSTNAME#g' \
    -e 's#<oracle_home>#$ORACLE_HOME#g' \
    -e 's#<date>#$timestamp#g' $DB_AIDA_ADMDIR/listener_sid.ora > $DB_AIDA_TMPDIR/listener_$ORACLE_SID.ora.$pid
EOF

# execute sed script
chmod 750 $DB_AIDA_TMPDIR/tmpsed$pid.sh
$DB_AIDA_TMPDIR/tmpsed$pid.sh
rm $DB_AIDA_TMPDIR/tmpsed$pid.sh >> $DB_AIDA_LOG 2>&1

# copy the generated file to ORACLE_HOME/network/admin directory
cp $DB_AIDA_TMPDIR/listener_$ORACLE_SID.ora.$pid  \
$ORACLE_HOME/network/admin/listener_$ORACLE_SID.ora  >> $DB_AIDA_LOG 2>&1
#chmod 660 $ORACLE_HOME/network/admin/listener_$ORACLE_SID.ora
do_errcheck
$RM $DB_AIDA_TMPDIR/listener_$ORACLE_SID.ora.$pid 1>> $DB_AIDA_LOG 2>&1

# Step2: patch tnsnames_sid.ora 

pid=$$
timestamp=`date`
cat > $DB_AIDA_TMPDIR/tmpsed$pid.sh << EOF
sed -e 's#<dbname>#$ORACLE_SID#g' \
    -e 's#<hostname>#$DB_AIDA_HOSTNAME#g' \
    -e 's#<oracle_home>#$ORACLE_HOME#g' \
    -e 's#<date>#$timestamp#g' $DB_AIDA_ADMDIR/tnsnames_sid.ora > $DB_AIDA_TMPDIR/tnsnames_$ORACLE_SID.ora.$pid
EOF

# execute sed script
chmod 750 $DB_AIDA_TMPDIR/tmpsed$pid.sh
$DB_AIDA_TMPDIR/tmpsed$pid.sh
rm $DB_AIDA_TMPDIR/tmpsed$pid.sh >> $DB_AIDA_LOG 2>&1

# copy the generated file to ORACLE_HOME/network/admin directory
cp $DB_AIDA_TMPDIR/tnsnames_$ORACLE_SID.ora.$pid  \
$ORACLE_HOME/network/admin/tnsnames_$ORACLE_SID.ora  >> $DB_AIDA_LOG 2>&1
#chmod 660 $ORACLE_HOME/network/admin/tnsnames_$ORACLE_SID.ora
do_errcheck
$RM $DB_AIDA_TMPDIR/tnsnames_$ORACLE_SID.ora.$pid 1>> $DB_AIDA_LOG 2>&1

# Step3: patch sqlnet_sid.ora 

pid=$$
timestamp=`date`
cat > $DB_AIDA_TMPDIR/tmpsed$pid.sh << EOF
sed -e 's#<dbname>#$ORACLE_SID#g' \
    -e 's#<hostname>#$DB_AIDA_HOSTNAME#g' \
    -e 's#<oracle_home>#$ORACLE_HOME#g' \
    -e 's#<date>#$timestamp#g' $DB_AIDA_ADMDIR/sqlnet_sid.ora > $DB_AIDA_TMPDIR/sqlnet_$ORACLE_SID.ora.$pid
EOF

# execute sed script
chmod 750 $DB_AIDA_TMPDIR/tmpsed$pid.sh
$DB_AIDA_TMPDIR/tmpsed$pid.sh
rm $DB_AIDA_TMPDIR/tmpsed$pid.sh >> $DB_AIDA_LOG 2>&1

# copy the generated file to ORACLE_HOME/network/admin directory
cp $DB_AIDA_TMPDIR/sqlnet_$ORACLE_SID.ora.$pid  \
$ORACLE_HOME/network/admin/sqlnet_$ORACLE_SID.ora  >> $DB_AIDA_LOG 2>&1
#chmod 660 $ORACLE_HOME/network/admin/sqlnet_$ORACLE_SID.ora
do_errcheck
$RM $DB_AIDA_TMPDIR/sqlnet_$ORACLE_SID.ora.$pid 1>> $DB_AIDA_LOG 2>&1

}

do_test()
{
do_log "
Testing AIDA-DB... (ORACLE_SID=`echo $ORACLE_SID`)
  (Please see $DB_AIDA_LOG for further information)
" 
do_checkdb

$SQLDBA  <<EOF >> $DB_AIDA_LOG 2>&1
  connect internal
  @$DB_AIDA_ADMDIR/dbtest
  exit
EOF

$SQLPLUS $DB_AIDA_OWNER/$DB_AIDA_PWOWNER <<EOF >> $DB_AIDA_LOG 2>&1
  @$DB_AIDA_ADMDIR/dbtest
  exit
EOF

}

# ------------------------------------------------------------
# evaluate commandline input
# ------------------------------------------------------------

#exec 2> /tmp/dbinstall$$.log
#set -x

debug=":"
RM="rm"

if [ "$1" = "-d" ]
then
    options="$options -d"
    debug=""
    RM=": rm"
    shift 1
fi

scriptname=`basename $0`

    case $1 in
    "")      echo "--> 1st parameter [-sid] is missing !!"
             usage
             ;;
    "?"|"-?"|"-h"|"-help")
             usage
             ;;
    "-sid")  ;;
    *)       echo "--> 1st parameter [-sid] is not correct !!"
             usage
             ;;
    esac

for i in $*
do
    case $2 in
      "")      echo "--> ORACLE_SID is missing !!"
               usage
               ;;
      *)  TMP_ORACLE_SID="$2"
# *)  ORACLE_SID="$2";  export ORACLE_SID
               ;;
    esac

    case $3 in
      "")    echo "--> 3rd Parameter missing ! "
             usage
             ;;
      -default) 
	     act="STD"
             opt="DEFAULT"
	     ;;
      -base) act="BASE"
             opt="BASE"
	     ;;
      -cleanup) 
	     act="CLR"
             opt="CLEANUP"
	     ;;
      -create) 
             act="CRE"
             opt="CREATE"
             case $4 in
               "")     
                   create_what="ALL"
                   ;;
               all)  
                   create_what="ALL"
                   ;;
               database) 
                   create_what="DB"
                   ;;
               objects) 
                   create_what="OBJ"
                   ;;
               *) 
                   "Unknown CREATE option."
                   usage
                   ;;
             esac
	     ;;
      -export)
             act="EXP"
             opt="EXPORT"
	     ;;
      -import)
             act="IMP"
             opt="IMPORT"
	     ;;
      -load) act="LDR"
             opt="LOAD"
	     ;;
      -reinit) 
             act="REINIT"
             opt="REINIT"
             ;;
      -sqlnet) 
             act="NET"
             opt="SQLNET"
             ;;
      -test) act="TEST"
             opt="TEST"
	     ;;
      *)     echo "--> 3rd Parameter is not correct ! "
	     usage
	     ;;
    esac
done


# !! reminder: $DB_AIDA_LOG not yet set !!

# ------------------------------------------------------------
# echo banner on stdout only 
# ------------------------------------------------------------
do_log "
------------------------------------------------------------------------
AIDA DB-Installer $DB_AIDA_VERSION [Option=$opt] : `date`
------------------------------------------------------------------------
"

# ------------------------------------------------------------
#  Is the script being run by a super user?
# ------------------------------------------------------------

# !! bug when executed as root !!

> /tmp/fil$$
INAME=`ls -l /tmp/fil$$ | awk '{print $3}'`
rm -f /tmp/fil$$
case $INAME in
  root) SUPER_USER=TRUE
       case $DB_AIDA_OWNER in
         "") echo "DB_AIDA_OWNER not set."
             echo "Set and export DB_AIDA_OWNER, then restart installation."
             do_log "Exiting AIDA DB-Installation."
             exit 1 ;;
       esac ;;
  *)    SUPER_USER=FALSE ;;
esac

# ------------------------------------------------------------
# enable logging
# ------------------------------------------------------------
#DB_AIDA_LOG="/tmp/dbinstall_${ORACLE_SID}${id}.log"
#DB_AIDA_LOG="/tmp/dbinstall_${TMP_ORACLE_SID}${id}.log"
DB_AIDA_LOG="/tmp/dbinstall_${id}.log"

# ------------------------------------------------------------
# save temp logfile setting for later logfile switch
# ------------------------------------------------------------
TMP_LOG=$DB_AIDA_LOG


# ------------------------------------------------------------
# start installation
# ------------------------------------------------------------

echo "
------------------------------------------------------------------------
AIDA DB-Installer $DB_AIDA_VERSION [Option=$opt] : `date`
------------------------------------------------------------------------
" >>  $DB_AIDA_LOG 2>&1

# ------------------------------------------------------------
#  Get temporary HOSTNAME info 
# ------------------------------------------------------------

TMP_DB_AIDA_HOSTNAME=`uname -a | awk  '{print $2}'`

# ------------------------------------------------------------
#  Check if configuration file is present
# ------------------------------------------------------------

DB_AIDA_ENVDIR="$HOME"
DB_AIDA_ENVFILE="dbinstallenv"
#echo "$HOME/$DB_AIDA_ENVFILE"

if [ ! -f "$DB_AIDA_ENVDIR/$DB_AIDA_ENVFILE" ]; then
   #
   #  Get name of default environment directory.
   #
   echo ""
   echo $N "Enter full pathname for the configuration file = $N"
   DEFLT="$DB_AIDA_ENVDIR"; do_read; DB_AIDA_ENVDIR=$RDVAR
   if [ ! -r "$DB_AIDA_ENVDIR/$DB_AIDA_ENVFILE" ]; then
      echo ""
      do_log "Configuration file not found in $DB_AIDA_ENVDIR !" 
       
      echo "Install configuration file, then restart installation."
      do_log "Exiting AIDA DB-Installation."
      exit 1
   fi
   RESET_VARS="Y"
   WRITE_ENVFILE="Y"
else
   #
   #  Custom environment file found.
   #
   #DB_AIDA_ENVDIR="$HOME/bin"
   DB_AIDA_ENVDIR="$HOME"
   if [ ! -w "$DB_AIDA_ENVDIR/$DB_AIDA_ENVFILE" ]; then
      echo ""
      do_log "Configuration file not found in $DB_AIDA_ENVDIR !"
      echo $N "Enter full pathname for the configuration file = $N"
      DEFLT="$DB_AIDA_ENVDIR"; do_read; DB_AIDA_ENVDIR=$RDVAR
      if [ ! -r "$DB_AIDA_ENVDIR/$DB_AIDA_ENVFILE" ]; then
         echo ""
         do_log "Configuration file not found in $DB_AIDA_ENVDIR !" 
         echo "Provide configuration file, then restart installation."
	 do_log "Exiting AIDA DB-Installation."
         exit 1
      fi
   fi
   RESET_VARS="N"
   WRITE_ENVFILE="N"
fi

# --------------------------------------------------------------------------
# set up ORACLE/DBINSTALL environment
# --------------------------------------------------------------------------

. $DB_AIDA_ENVDIR/dbinstallenv

#  - check difference between environment setting and -sid parameter
if [ ! "$TMP_ORACLE_SID" = "$ORACLE_SID" ]; then
   do_log "ORACLE_SID differs from default environment settings"
   RESET_VARS="Y"
else
   RESET_VARS="N"
fi
ORACLE_SID="$TMP_ORACLE_SID"

#  - check difference between environment and default setting
DB_AIDA_HOSTNAME_DEF="hostname"

if [ ! "$TMP_DB_AIDA_HOSTNAME" = "$DB_AIDA_HOSTNAME" -a \
     ! "$TMP_DB_AIDA_HOSTNAME" = "$DB_AIDA_HOSTNAME_DEF" ]; then
   do_log "HOSTNAME differs from AIDA DB-Installer environment setting:
"
   do_log "- DB_AIDA_HOSTNAME = $DB_AIDA_HOSTNAME"
   do_log "- System information = $TMP_DB_AIDA_HOSTNAME
"
   echo "Continue installation processing (Y/N)? $C"
   DEFLT="Y"; do_read; ANSWER=$RDVAR
   case $ANSWER in
       N|n) do_log "Exiting AIDA DB-Installation."
            exit 1 ;;
       *)   # RESET_VARS="Y";;
            ;;
   esac
else
   DB_AIDA_HOSTNAME="$TMP_DB_AIDA_HOSTNAME"
   RESET_VARS="N"
fi

case $DB_AIDA_HOSTNAME in
  "") echo "DB_AIDA_HOSTNAME not set in 'dbinstallenv'."
      echo "Set and export DB_AIDA_HOSTNAME, then restart installation."
      do_log "Exiting AIDA DB-Installation."
      exit 1 ;;
  *)  do_log "DB_AIDA_HOSTNAME -> $DB_AIDA_HOSTNAME"
esac

# -----------------------------------------------------------------------------
#  Get all information on external DB structures (data/control/redo log files)
# -----------------------------------------------------------------------------
while : ; do

  if [ "$RESET_VARS" = "Y" ]; then
     
     WRITE_ENVFILE="Y"
     echo " "
     echo $N "Enter ORACLE_HOME directory = $N"
     DEFLT=${ORACLE_HOME}; do_read; ORACLE_HOME=$RDVAR
     if [ ! -d "$ORACLE_HOME" ]; then
        echo ""
        do_log "ORACLE_HOME=$ORACLE_HOME not found !"
        echo ""
        echo "Check ORACLE_HOME path, then restart installation."
        do_log "Exiting AIDA DB-Installation."
        exit 1
     fi

     #  Get name of Oracle Database identifier
     echo " "
     echo $N "Enter database identifier ORACLE_SID = $N"
     DEFLT=${ORACLE_SID}; do_read; ORACLE_SID=$RDVAR

     #  Get name of DB-Install base directory.
     do_checkdir "$DB_AIDA_BASE" "DB_AIDA_BASE" "base" "CHECK"
     DB_AIDA_BASE=$CHECKDIR

     #  Get name of temporary directory.
     do_checkdir "$DB_AIDA_TMPDIR" "DB_AIDA_TMPDIR" "temporary" "CREATE"
     DB_AIDA_TMPDIR=$CHECKDIR

     #  Get name of log directory.
     do_checkdir "$DB_AIDA_LOGDIR" "DB_AIDA_LOGDIR" "log" "CREATE"
     DB_AIDA_LOGDIR=$CHECKDIR

     #  Get name of template directory.
     do_checkdir "$DB_AIDA_ADMDIR" "DB_AIDA_ADMDIR" "template" "CHECK"
     DB_AIDA_ADMDIR=$CHECKDIR

     #  Get name of loader script directory.
     do_checkdir "$DB_AIDA_LOADDIR" "DB_AIDA_LOADDIR" "loader" "CHECK"
     DB_AIDA_LOADDIR=$CHECKDIR

     #  Get name of DB data directory.
     do_checkdir "$DB_AIDA_DATADIR" "DB_AIDA_DATADIR" "data" "CREATE"
     DB_AIDA_DATADIR=$CHECKDIR

     #  Get name of DB redo log directory.
     do_checkdir "$DB_AIDA_REDODIR" "DB_AIDA_REDODIR" "redo log" "CREATE"
     DB_AIDA_REDODIR=$CHECKDIR

     #  Get name of DB mirror directory.
     do_checkdir "$DB_AIDA_MIRRDIR" "DB_AIDA_MIRRDIR" "mirror" "CREATE"
     DB_AIDA_MIRRDIR=$CHECKDIR

     #  Get name of DB archive log directory.
     do_checkdir "$DB_AIDA_ARCHDIR" "DB_AIDA_ARCHDIR" "archive" "CREATE"
     DB_AIDA_ARCHDIR=$CHECKDIR

     #  Get name of DB spool directory (UTL_FILE processing) .
     do_checkdir "$DB_AIDA_SPOOLDIR" "DB_AIDA_SPOOLDIR" "spool" "CREATE"
     DB_AIDA_SPOOLDIR=$CHECKDIR

     # ------------------------------------------------------------
     #  Check if import file is present (-> full DB export file)
     # ------------------------------------------------------------

     #  Get name of DB export/import directory
     echo " "
     echo $N "Enter dump directory = $N"
     DEFLT=${DB_AIDA_DUMPDIR}; do_read; DB_AIDA_DUMPDIR=$RDVAR

     #  Get name of DB import file
     echo " "
     echo $N "Enter import file = $N"
     DEFLT=${DB_AIDA_IMPFILE}; do_read; DB_AIDA_IMPFILE=$RDVAR

     if [ ! -r "$DB_AIDA_DUMPDIR/$DB_AIDA_IMPFILE" -a ! "$act" = "BASE" ]
     then
       echo ""
       echo "Import file <$DB_AIDA_IMPFILE> not found in $DB_AIDA_DUMPDIR !"
       echo $N "Enter full pathname for the import file = $N"
       DEFLT="$DB_AIDA_DUMPDIR"; do_read; DB_AIDA_DUMPDIR=$RDVAR

       echo " "
       echo $N "Enter the name of the import file = $N"
       DEFLT="$DB_AIDA_IMPFILE"; do_read; DB_AIDA_IMPFILE=$RDVAR

       if [ ! -r "$DB_AIDA_DUMPDIR/$DB_AIDA_IMPFILE" ]; then
          echo ""
          do_log "Import file <${DB_AIDA_IMPFILE}> not found !" 
          echo "Provide import file, then restart installation."
 	  do_log "Exiting AIDA DB-Installation."
          exit 1
       fi
     fi

     #  Get name of DB export file
     echo " "
     echo $N "Enter export file = $N"
     DEFLT=${DB_AIDA_EXPFILE}; do_read; DB_AIDA_EXPFILE=$RDVAR

     #  Get name of AIDA application owner
     echo " "
     echo $N "Enter AIDA owner (Oracle DB) = $N"
     DEFLT=${DB_AIDA_OWNER}; do_read; DB_AIDA_OWNER=$RDVAR

     #  Get password of AIDA application owner
     echo " "
     echo $N "Enter password for AIDA owner (Oracle DB)  = $N"
     DEFLT=${DB_AIDA_PWOWNER}; do_read "NOECHO"; DB_AIDA_PWOWNER=$RDVAR

     #  Get password of SYS owner
     echo " "
     echo $N "Enter password for SYS owner (Oracle DB)  = $N"
     DEFLT=${DB_AIDA_PWSYS}; do_read "NOECHO"; DB_AIDA_PWSYS=$RDVAR

     #  Get password of SYSTEM owner
     echo " "
     echo $N "Enter password for SYSTEM owner (Oracle DB)  = $N"
     DEFLT=${DB_AIDA_PWSYSTEM}; do_read "NOECHO"; DB_AIDA_PWSYSTEM=$RDVAR

     #  Get hostname for SQL*Net2 control files
     echo " "
     echo $N "Enter Host Name for SQL*Net control files = $N"
     DEFLT=${DB_AIDA_HOSTNAME}; do_read; DB_AIDA_HOSTNAME=$RDVAR

     #  Get Database blocksize
     echo " "
     echo $N "Enter database blocksize DB_AIDA_BLOCKSIZE = $N"
     DEFLT=${DB_AIDA_BLOCKSIZE}; do_read; DB_AIDA_BLOCKSIZE=$RDVAR

  else
     WRITE_ENVFILE="N"
  fi

# ------------------------------------------------------------
# Give user the chance to confirm/modify these values.
# ------------------------------------------------------------
  clear
  do_log "
--------------------------------------------------------------------
AIDA DB-Installer environment variables are set as:

  ORACLE_HOME         =  $ORACLE_HOME
  ORACLE_SID          =  $ORACLE_SID

  DB_AIDA_DATADIR   =  $DB_AIDA_DATADIR
  DB_AIDA_REDODIR   =  $DB_AIDA_REDODIR
  DB_AIDA_ARCHDIR   =  $DB_AIDA_ARCHDIR
  DB_AIDA_MIRRDIR   =  $DB_AIDA_MIRRDIR
  DB_AIDA_SPOOLDIR  =  $DB_AIDA_SPOOLDIR

  DB_AIDA_BASE      =  $DB_AIDA_BASE
  DB_AIDA_ENVDIR    =  $DB_AIDA_ENVDIR
  DB_AIDA_ENVFILE   =  $DB_AIDA_ENVDIR/$DB_AIDA_ENVFILE
  DB_AIDA_ADMDIR    =  $DB_AIDA_ADMDIR
  DB_AIDA_TMPDIR    =  $DB_AIDA_TMPDIR
  DB_AIDA_LOGDIR    =  $DB_AIDA_LOGDIR
  DB_AIDA_LOADDIR   =  $DB_AIDA_LOADDIR
  DB_AIDA_DUMPDIR   =  $DB_AIDA_DUMPDIR
  DB_AIDA_IMPFILE   =  $DB_AIDA_IMPFILE
  DB_AIDA_EXPFILE   =  $DB_AIDA_EXPFILE

  DB_AIDA_OWNER     =  $DB_AIDA_OWNER
  DB_AIDA_PWOWNER   =  $DB_AIDA_PWOWNER
  DB_AIDA_PWSYS     =  $DB_AIDA_PWSYS
  DB_AIDA_PWSYSTEM  =  $DB_AIDA_PWSYSTEM

  DB_AIDA_HOSTNAME  =  $DB_AIDA_HOSTNAME
  DB_AIDA_BLOCKSIZE =  $DB_AIDA_BLOCKSIZE
--------------------------------------------------------------------"

  echo "Are these settings correct (Y/N)? $C"
  DEFLT="Y"; do_read; ANSWER=$RDVAR
  case $ANSWER in
      Y|y) break;;
      *)   RESET_VARS="Y";;
  esac
done

# ------------------------------------------------------------
# Last chance for the user to confirm these values.
# ------------------------------------------------------------
echo $N "Run installation with these settings (Y/N)? $C"
DEFLT="Y"; do_read; ANSWER=$RDVAR
case $ANSWER in
    Y|y) if [ "$act" = "CLR" ]; then
            echo "Delete all existing <$ORACLE_SID> files (Y/N)? $C"
            DEFLT="Y"; do_read; CLR_ANSWER=$RDVAR
            case $CLR_ANSWER in
                Y|y) ;;
                *)   do_log "Exiting AIDA DB-Installation."  
                     exit 0 ;;
            esac
         fi 
         ;;
    *)   do_log "Exiting AIDA DB-Installation."  
         exit 0 ;;
esac

# ------------------------------------------------------------
# write customized environment file for re-use
# ------------------------------------------------------------
if [ "$WRITE_ENVFILE" = "Y" ]; then
   do_write_env
fi

# ------------------------------------------------------------
# export environment
# ------------------------------------------------------------
do_export_env

# ------------------------------------------------------------
# switch logfile (from tmp filename to selected log directory)
# - due to the fact that before this step
#   we dont't have yet all the necessary info
# ------------------------------------------------------------
DB_AIDA_LOG="$DB_AIDA_LOGDIR/dbinstall_${ORACLE_SID}${id}.log"
cat < $TMP_LOG >> $DB_AIDA_LOG 2>&1
rm "$TMP_LOG" >> $DB_AIDA_LOG 2>&1

do_log "
--------------------------------------------------------------------
Log information will be written to: \n $DB_AIDA_LOG
--------------------------------------------------------------------
"

# ------------------------------------------------------------
# compute suffix for temp file name
# ------------------------------------------------------------

doy=`date '+%j'`       # day of the year
switch=`expr $doy % 2`

case $switch in
  0 ) suffix=0a ;;
  1 ) suffix=0b ;;
esac

# ------------------------------------------------------------
# use timestamp file 
# ------------------------------------------------------------

tsfile=$DB_AIDA_ADMDIR/ADATE$ORACLE_SID

# ------------------------------------------------------------
# Before starting the installation, 
# check to make sure that the base variables are set.
# If they are not, prompt user to set them and restart install.
# ------------------------------------------------------------
case $ORACLE_HOME in
    "") echo "ORACLE_HOME not set."
        echo "Set and export ORACLE_HOME, then restart installation."
        exit 1 ;;
esac

case $ORACLE_SID in
    "") echo "ORACLE_SID not set."
        echo "Set and export ORACLE_SID, then restart installation."
        exit 1 ;;
esac

# ------------------------------------------------------------
# If DB_AIDA_LOG is not set, then send output to /dev/null.
# ------------------------------------------------------------
if [ "$DB_AIDA_LOG" = "" ]; then
  DB_AIDA_LOG="/dev/null"
  echo ""
  echo "Note:  To have diagnostic output from your operations logged, set the"
  echo "       environment or export variable DB_AIDA_LOG " 
  echo "       to a file name to contain the output."
fi


# =========================================================================
# begin installation
# =========================================================================

do_log "
------------------------------------------------------------------------
Begin AIDA DB-Installation 
------------------------------------------------------------------------
" 

# ------------------------------------------------------------
# Test mode
# ------------------------------------------------------------

if [ "$act" = "TEST" ]
 then
   do_debug $act
   do_test
fi

# ------------------------------------------------------------
# remove old files
# ------------------------------------------------------------

if [ "$act" = "STD" -o "$act" = "BASE" -o "$act" = "CRE" -o "$act" = "CLR" ]
 then
   do_debug $act
   do_cleanup
fi

# ------------------------------------------------------------
# create DB 
# ------------------------------------------------------------

if [ "$act" = "STD" -o "$act" = "BASE" -o "$act" = "CRE" ]
 then
   do_debug $act
   do_patch
   do_create
fi

# ------------------------------------------------------------
# import into new DB
# ------------------------------------------------------------

if [ "$act" = "STD" -o "$act" = "IMP" ]
 then
   do_debug $act
   do_import
fi

# ------------------------------------------------------------
# export from new DB
# ------------------------------------------------------------

if [ "$act" = "EXP" ]
 then
   do_debug $act
   do_export
fi

# ------------------------------------------------------------
# load basic data
# ------------------------------------------------------------

if [ "$act" = "BASE" -o "$act" = "LDR" ]
 then
   do_debug $act
   do_load
fi

# ------------------------------------------------------------
# delete all data and reload from import file
# ------------------------------------------------------------

if [ "$act" = "REINIT" ]
 then
   do_debug $act
   do_delete
   do_import
fi

# ------------------------------------------------------------
# generate SQL*Net control files 
# ------------------------------------------------------------

if [ "$act" = "STD" -o "$act" = "NET" ]
 then
   do_debug $act
   do_sqlnet
fi

# ------------------------------------------------------------
# check for installation error 
# ------------------------------------------------------------

if [ ! "$DB_AIDA_ERR" = "Y" ]
then
   do_log "
Installation completed.
Please see $DB_AIDA_LOG for further information.
" 
else
   do_log "
Installation completed with errors/warnings.
Please see $DB_AIDA_LOG for further information.
" 
fi     

do_log "
------------------------------------------------------------------------
End of AIDA DB-Installation [Option=$opt] : `date`
------------------------------------------------------------------------
" 
exit 0

# ------------------------------------------------------------
# end of file
# ------------------------------------------------------------
