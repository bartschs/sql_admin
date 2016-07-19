###############################################################################
# Die .profile Datei dient zur Basiskonfiguration Ihres Unix-Accounts.        #
# Als Default-Shell bei Ihrer Usereinrichtung wird immer /bin/sh eingetragen, #
# die Steuerung, mit welcher Shell sie dann spaeter tatsaechlich arbeiten     #
# geschieht ueber die Datei                                                   #
# 'shell' in dem Verzeichnis '.settings'.                                     #
#                                                                             #
# Persoenliche Einstellungen werden ebenfalls ueber Dateien im Verzeichnis    #
# '.settings' verwaltet.                                                      #
#                                                                             #
# WICHTIG                                                                     #
# WICHTIG Diese Datei wird bei jedem login ueberschrieben! Nutzen Sie das     #
# WICHTIG .settings Verzeichnis fuer Ihre persoenlichen Einstellungen         #
# WICHTIG                                                                     #
#                                                                             #
###############################################################################
###############################################################################

# Subversion meta information for this file.
# $Id: profile 3307 2013-08-22 17:26:38Z jans $
# $HeadURL: https://svn.devlab.de.tmo/devlab/svn/common/trunk/appl_common/startup/default/profile $

if [ -z "$DOT_PROFILE_WAS_EXECUTED" ] 
then
   DOT_PROFILE_WAS_EXECUTED=yes
   export DOT_PROFILE_WAS_EXECUTED
fi

#
# Update startup files if necessary
#
for file in kshrc bashrc profile startwm.sh; do
        if [ -f /appl/common/startup/default/$file ]; then
                /usr/bin/diff /appl/common/startup/default/$file $HOME/.$file >/dev/null 2>/dev/null
                if [ "$?" != "0" ]; then
			# Make the script quota-save
                        echo "Copying new version of .$file"
                        cp /appl/common/startup/default/$file $HOME/.$file.new
                        if [ -s  $HOME/.$file.new ]; then
				chmod 644 $HOME/.$file 2>/dev/null
                                cp $HOME/.$file.new $HOME/.$file
				chmod 444 $HOME/.$file
                        	if [ "$file" = "profile" ]; then
                                        rm -f $HOME/.$file.new 2>/dev/null
                                        . $HOME/.profile
                                        exit
                                fi
                        fi
			chmod 555 $HOME/.startwm.sh
			chmod 644 $HOME/.$file.new 2>/dev/null
                        rm $HOME/.$file.new 2>/dev/null
                fi
        fi
done

# This Script sets PATH and MANPATH due to installed software
# Note that this Script must be updated every time, when new
# software is installed. It is therefore very important, that
# the pathnames are the same on all machines.

############################################################################
####   Mit der folgenden Funktion wird auf Existenz eines Pfades geprueft  #
####   und entsprechend der angegebene Pfad erweitert                      #
############################################################################

SetPath() {
	THEPOS=right
	case $1 in
		-f|--first)	THEPOS=left ; shift ;;
		-l|--last)	THEPOS=right ; shift ;;
		-k|--kill)	THEPOS=kill ; shift ;;
	esac

	VAR=$1
	DIR=$2

	if [ -d "$DIR" ]; then
		DIR=":${DIR}:"
		eval "THEPATH=\":\$$VAR:\""
		THEPATH=`/bin/echo $THEPATH | /bin/sed "s,$DIR,::,g"`
		case $THEPOS in 
			left)	THEPATH=$DIR$THEPATH ;;
			right)	THEPATH=$THEPATH$DIR ;;
		esac
		THEPATH=`/bin/echo $THEPATH | /bin/sed -e 's,^::*,,g' -e 's,::*$,,g' -e 's,::*,:,g'`
		eval "$VAR=$THEPATH"
	fi
}

############################################################################
####   Mit der folgenden Funktion wird auf Existenz einer Reihe von Pfaden #
####   geprueft und der letzte der existiert zurueckgegeben                #
############################################################################

ChooseVersion() {
	RESULTVAR=$1
	shift
	for directoryname in $*; do
		if [ -d $directoryname ]; then
			eval "$RESULTVAR=$directoryname"
		fi
	done
}

############################################################################
####   Mit der folgenden Funktion wird auf Existenz eines Pfades geprueft  #
####   der in einer Datei liegt. Existiert er, wird er zurueckgegeben      #
############################################################################

ChooseDefault() {
	RESULTVAR=$1
	defaultfile=$2
	if [ -f $defaultfile ]; then
		RESULT=`cat $defaultfile | grep -i "default=" | cut -f2 -d"="`
	fi
	if [ -n "$RESULT" ]; then
		eval "$RESULTVAR=$RESULT"
	fi
}

findshell() {
        unset __NEWSHELL
        while [ -z "$__NEWSHELL" -a -n "$1" ]; do
                __NEWSHELL=`type $1 | grep $1 | awk '{ print $NF }' 2>/dev/null`
                echo $__NEWSHELL | grep "no .* in " >/dev/null
                if [ "$?" = "0" ]; then
                       unset __NEWSHELL
                fi
                echo $__NEWSHELL | grep "not found" >/dev/null
                if [ "$?" = "0" ]; then
                        unset __NEWSHELL
                fi
                shift
        done
        if [ -z "$__NEWSHELL" ]; then
                __NEWSHELL=/bin/sh
        fi
        echo $__NEWSHELL
}

AddProjectSettings() {
	if [ -f /appl/common/startup/default/$1 ]; then
		__PROJECT=$1
		shift
		. /appl/common/startup/default/$__PROJECT $*
	fi
}

SwitchOracle() {
	__VERSION=$1
	shift
	echo $* | egrep "$CLUSTERALIAS|$HOSTNAME" >/dev/null
	if [ "$?" = "0" ]; then
		if [ -d /appl/local/oracle/$__VERSION ]; then
			if [ -n "$ORACLE_HOME" ]; then
				SetPath --kill PATH $ORACLE_HOME/bin
				SetPath --kill LD_LIBRARY_PATH $ORACLE_HOME/lib
                                SetPath --kill LD_LIBRARY_PATH $ORACLE_HOME/lib32
			fi
			ORACLE_HOME=/appl/local/oracle/$__VERSION
			SetPath PATH $ORACLE_HOME/bin
			SetPath LD_LIBRARY_PATH $ORACLE_HOME/lib
                        SetPath LD_LIBRARY_PATH $ORACLE_HOME/lib32
		else
			echo "***** Warning: SwitchOracle() "
			echo "***** Version $__VERSION does not exist on machine $CLUSTERALIAS / $HOSTNAME"
			echo "***** Please correct file $HOME/.settings/oracle"
		fi
	fi
}


##################################################################
##################                                 ###############
##################       Allgemeiner Teil          ###############
##################                                 ###############
##################################################################

######### PATH allgemein       ###########
echo "********** setting system specific values"

OS=`uname -s`
case "$OS" in 
	CYGWIN*)
		# Use Path from NT together with Cygwin
		PATH=/bin:/usr/bin:/usr/sbin:$PATH
		;;
	Linux)	# Use Path from Linux profile
                # Special case for execution of startkde on Linux: add /opt/kde3/bin path to PATH var.
                if [ -d /opt/kde3/bin ]
                then
                   PATH=$PATH:/opt/kde3/bin
                fi
                export PATH
                # Default MANPATH on Linux systems, at least relevant for RedHat systems, A200909162.
                MANPATH=/usr/share/man:/usr/man:/usr/local/share/man:/usr/local/man
                ;;
	AIX)	PATH=/usr/bin:/usr/sbin:/usr/ucb:/usr/bin/X11
		;;
	*)
		PATH=/bin:/usr/bin:/usr/sbin
		MANPATH=/usr/man
		;;
esac

######### Operating System     ###########
stty erase "^H" kill "^U" intr "^C" eof "^D" susp "^Z" 2>/dev/null

ENV=$HOME/.kshrc

HOSTNAME=`hostname | cut -f1 -d"." | tr '[A-Z]' '[a-z]'`
COMPUTERNAME=$HOSTNAME

CLUSTERALIAS=$HOSTNAME
case $OS in
	SunOS)
		OSNAME=sunos
		OSVER=`uname -sr | sed -e 's/\ /-/g'`
		# Find Cluster alias by checking if interfaces for cluster exist
		for word in `/usr/sbin/ifconfig -a |  awk '/:[0-9]:/ && /UP/ { F=1; next }F==1 && /netmask ffffc00/ {F=0; print $2}'`; do
			CLUSTERNAME=`/usr/sbin/nslookup $word | grep "Name:" | cut -f2 -d: | cut -f1 -d.`
			CLUSTERNAME=`echo $CLUSTERNAME`
			CLUSTERALIAS="$CLUSTERALIAS|$CLUSTERNAME"
		done
		CLUSTERALIAS=`echo $CLUSTERALIAS | cut -f2-99 -d\|`

		if [ ! "$DT" ] ; then
			stty istrip
		fi
		;;
	OSF1)
		OSNAME=decux
		TEMPVAR=`/usr/sbin/sizer -v | sed "s/^.* \(V[0-9.]*[A-Z]*\) .*$/\1/g"`
		OSVER="`uname`-$TEMPVAR"

		# Find Cluster alias by checking if fstab has entries for cluster
		if [ -d /var/ase/config/fstabs.running ]; then
			for word in `ls  /var/ase/config/fstabs.running/*`; do
				CLUSTERNAME=`basename $word`
				CLUSTERALIAS="$CLUSTERALIAS|$CLUSTERNAME"
			done
			CLUSTERALIAS=`echo $CLUSTERALIAS | cut -f2-99 -d\|`
		fi

		if [ ! "$DT" ]; then
			stty dec
			tset -I -Q
		fi
		;;
	HP-UX)
		OSNAME=hpux
		OSVER=$OSNAME-`uname -r | sed "s/B\./V/g"` 
		# No Cluster-Support implemented
		;;
	Linux)
		OSNAME=linux
		OSVER=$OSNAME-`uname -r | cut -f 1-2 -d"."` 
		# No Cluster-Support implemented
		;;
	CYGWIN*)
		OSNAME=cygwin
		OSVER=`uname -r | cut -f1 -d"("`
		OSVER=`echo $OSVER`
		OSVER=CYGWIN-$OSVER
		# No Cluster-Support implemented
		;;
esac

######### User specific        ###########

umask 002

if [ -f /usr/ucb/whoami ]; then
        USER=`/usr/ucb/whoami`
else
        USER=`whoami`
fi

PS1="$USER@$CLUSTERALIAS> "

################################################################
##################### System global Path    ####################
################################################################

SetPath PATH /usr/ccs/bin
SetPath LD_LIBRARY_PATH /usr/ccs/lib

################################################################
##################### License Server        ####################
################################################################

LM_LICENSE_FILE=1726@license1:1726@license2


################################################################
##################### ClearCase             ####################
################################################################

SetPath PATH /usr/atria/bin
SetPath MANPATH /usr/atria/doc/man

###############################################################
################## Sun Workshop Compiler    ###################
###############################################################

ChooseVersion WORKSHOPDIR \
	/opt/SUNWspro/SC4.0 \
	/opt/SUNWspro/SC4.2 \
	/opt/SUNWspro/SC5.0 \
	/opt/SUNWspro

ChooseDefault WORKSHOPDIR /opt/SUNWspro/SC.default

SetPath PATH $WORKSHOPDIR/bin
SetPath MANPATH $WORKSHOPDIR/man

###############################################################
#####################  TERMINAL/X11         ###################
###############################################################

SetPath PATH /usr/bin/X11
SetPath LD_LIBRARY_PATH /usr/shlib/X11
SetPath LD_LIBRARY_PATH /usr/lib/X11

SetPath PATH /usr/X11R6/bin
SetPath LD_LIBRARY_PATH /usr/X11R6/lib
SetPath MANPATH /usr/X11R6/man


if [ -d /usr/openwin ]; then
	OPENWINHOME=/usr/openwin
	SetPath PATH $OPENWINHOME/bin
	SetPath LD_LIBRARY_PATH $OPENWINHOME/lib
fi
if [ -d /usr/dt ]; then
	SetPath PATH /usr/dt/bin
	SetPath LD_LIBRARY_PATH /usr/dt/lib
	SetPath MANPATH /usr/openwin/man
fi

###############################################################
#####################      ddts             ###################
###############################################################

SetPath PATH /appl/local/rational/ddts/bin
SetPath MANPATH /appl/local/rational/ddts/doc/man

###############################################################
################## Sun Java Development Kit ###################
###############################################################

ChooseVersion JDKDIR \
	/usr/java1.1 \
	/usr/java1.2 \
	/usr/java1.3 \
	/usr/java1.4 \
	/usr/java1.5 \
	/appl/local/sun/jdk-1.1 \
	/appl/local/sun/jdk-1.2 \
	/appl/local/sun/jdk-1.3 \
	/appl/local/sun/jdk-1.4 \
        /appl/local/sun/jdk-1.5 \

# TODO: Sollte umbenannt werden, /appl/local/sun/jdk.default bei Nicht-Solaris hosts sinnvoll? SJ
ChooseDefault JDKDIR /appl/local/sun/jdk.default

if [ -n "$JDKDIR" ]; then
    # Anpassung fuer Carmen und Java1.5 fuer Carmen Release 7.2:
    # Falls /appl/local/sun/jdk.default existiert, so wird
    # Java _vorne_ an den PATH eingehaengt und nicht hinten. S. Jans, 20070328.
    if [ -r /appl/local/sun/jdk.default ] ;then
	SetPath -f PATH $JDKDIR/bin
	SetPath -f MANPATH $JDKDIR/man
	JAVA_HOME=$JDKDIR
    else
	SetPath PATH $JDKDIR/bin
	SetPath MANPATH $JDKDIR/man
	JAVA_HOME=$JDKDIR
    fi
fi

###############################################################
#####################       Totalview       ###################
###############################################################

SetPath PATH /appl/local/etnus/totalview/bin

################################################################
################## Oracle                     ##################
################################################################

ChooseVersion ORACLE_HOME \
	/appl/local/oracle/8.1.7 \
	/appl/local/oracle/9.2.0 \
        /appl/local/oracle/10.2.0 \
        /appl/local/oracle/11.1.0 \
        /appl/local/oracle/11.2.0

# ChooseDefault ORACLE_HOME /appl/local/oracle/oracle.default

if [ -n "$ORACLE_HOME" ]; then
	SetPath PATH $ORACLE_HOME/bin
	SetPath LD_LIBRARY_PATH $ORACLE_HOME/lib
        SetPath LD_LIBRARY_PATH $ORACLE_HOME/lib32
	NLS_LANG=GERMAN_GERMANY.WE8ISO8859P15
	if [ "$OS" = "Linux" ]; then
		# Special hack for Susi Linux, sqlplus breaks if http_proxy is set
		unset http_proxy
	fi
fi

################################################################
##################### ClearCase tools       ####################
################################################################

case $OS in
Linux)
	CMHOME=`getent passwd vobadmin| cut -f6 -d":"`/ClearMobil
	;;
SunOS)
	CMHOME=`getent passwd vobadmin| cut -f6 -d":"`/ClearMobil
	;;
CYGWIN*)
	CMHOME=/cygdrive/w/Tools/ClearMobil
	;;
AIX)
        CMHOME=`lsuser -a home vobadmin | cut -f2 -d"="`/ClearMobil
        ;;
*)
	CMHOME=`getent passwd vobadmin| cut -f6 -d":"`/ClearMobil
	;;
esac

SetPath PATH $CMHOME/bin



#################################################################
################## Profile der Freeware       ###################
#################################################################

PREFIX=/appl/local/OpenSource
# Update: A201308373: use OpenCSW starting from Solaris 11 instead of OpenSource. Soenke Jans, 2013.08.22
# Essentially here we decide whether to use /appl/local/OpenSource or /opt/csw, this overrides version in .settings/opensourceversion
if [ "`uname`" = "SunOS" -a "`uname -r`" = "5.11" ]
then
   if [ -d "/opt/csw" ]
   then
      PREFIX=/opt/csw
   else
      echo 'Solaris 11: note: could not find directory /opt/csw (OpenCSW is not installed), please contact Devlab.Support@telekopm.de about this.' 
   fi
fi

# Update: only parse version from opensourceversion if we use /appl/local/OpenSource for A201308373.
if [ "$PREFIX" = "/appl/local/OpenSource" ]
then
   if [ -f $HOME/.settings/opensourceversion ]
   then
      # Change PREFIX to include specific version of /appl/local/OpenSource  
      FREEWARE_VERSION="`cat $HOME/.settings/opensourceversion`"
      if [ -n "$FREEWARE_VERSION" ]
      then
         # Only use this if we can offer a bash shell.
         if [ -f /appl/local/OpenSource/$FREEWARE_VERSION/bin/bash ]
         then
            PREFIX=/appl/local/OpenSource/$FREEWARE_VERSION
            SetPath PATH $PREFIX/usr/bin
            SetPath PATH $PREFIX/bin
         fi
      fi
   fi
else
   # Update: A201308373: use OpenCSW starting from Solaris 11 instead of /appl/local/OpenSource
   if [ "$PREFIX" = "/opt/csw" ]
   then
      # OpenCSW asks to be put in front.
      SetPath -f PATH /opt/csw/bin 
   fi
fi

# A201308373: This is obsolete and depends on whether we use OpenCSW or OpenSource, done in check above.
###SetPath PATH $PREFIX/usr/bin
###SetPath PATH $PREFIX/bin

case $PREFIX in
   /appl/local/OpenSource/4.2)
   # Update: OpenSource 4.2 does not depend on LD_LIBRARY_PATH anymore for Solaris.
   # S. Jans, 20090323.
      ;;
   /opt/csw)
      # We do not need to do anything special, PATH we set above already and we explicitly
      # state that OpenCSW does not need a set LD_LIBRARY_PATH, we do not unset it here since
      # software like Oracle might still need it..
      ;;
   *)
      SetPath LD_LIBRARY_PATH $PREFIX/usr/lib
      ;;
esac

# Dir does not exist in OpenCSW
if [ "$PREFIX" != "/opt/csw" ]
then
   # specific for OpenSource
   SetPath MANPATH $PREFIX/usr/man
else
   # specific for OpenCSW
   SetPath MANPATH $PREFIX/gcc4/man
fi
# Common to all open source-based software catalogues:
SetPath MANPATH $PREFIX/man

#################################################################
################## View-Usage anzeigen        ###################
#################################################################

if [ -f /appl/common/startup/default/checkviews.sh ]; then
	/appl/common/startup/default/checkviews.sh
fi

#################################################################
################## Check quota                ###################
#################################################################

case "$OS" in
        Linux)  quota -q 2>/dev/null
                ;;
        SunOS)  quota
                ;;
        AIX)    quota -q 2>/dev/null
                ;;
esac

#################################################################
################## User-Konfiguration sourcen ###################
#################################################################

EDITOR=/usr/bin/vi

# It does not make sense to use this in an NT-environment
# besides that, ash is to dumb to expand * correctly

if [ "$OSNAME" != "cygwin" ]; then
	if [ ! -d $HOME/.settings ]; then
		mkdir -p $HOME/.settings 
		echo "********** Populiere .settings-Verzeichnis"
	fi

	if [ -d /appl/common/startup/default/settings ]; then
		for file in /appl/common/startup/default/settings/* ; do
			if [ ! -f $HOME/.settings/`basename $file` ]; then
				cp $file $HOME/.settings/
				echo "********** creating .settings/`basename $file`"
			fi
		done
	fi
fi

for file in shell printer editor terminal oracle project profile windowmanager; do
	if [ -f $HOME/.settings/$file ]; then
		. $HOME/.settings/$file
	fi
done

# Printer definieren
LPDEST=$PRINTER

export PATH MANPATH ENV ORACLE_HOME OS HOSTNAME CLUSTERALIAS OSNAME OSVERSION OSVER CMHOME USER PS1 LD_LIBRARY_PATH MAIL LM_LICENSE_FILE JAVA_HOME OPENWINHOME
export PRINTER LPDEST TERMINAL BEADIR COMPUTERNAME NLS_LANG WINDOWMANAGER EDITOR

# Editor
__NEWEDITOR=`type $EDITOR | grep $EDITOR | awk '{ print $NF }' 2>/dev/null`

echo $__NEWEDITOR | grep "no .* in " >/dev/null
if [ "$?" = "0" ]; then
	__NEWEDITOR=/usr/bin/vi
fi
echo $__NEWEDITOR | grep "not found" >/dev/null
if [ "$?" = "0" ]; then
	__NEWEDITOR=/usr/bin/vi
fi

EDITOR=$__NEWEDITOR
export EDITOR

ulimit -c unlimited > /dev/null 2>&1

# Shell finden
NEWSHELL=`findshell $MYSHELL`


# Erlaubt das sourcen der .profile aus Skripts heraus, sehr hilfreich fuer rsh/ssh2

if [ "x$NOSHELL" = "xYES" ]; then
	SHELLFOUND=$NEWSHELL
        unset NEWSHELL
fi

# Find out if we have been started by kdm, if so do not exec bash, simply start it

ps -p $$ | grep "session"
EXECSHELL="$?"

if [ "x$XSESSION_IS_UP" = "xyes" ]; then
	EXECSHELL=0
fi

# Kein exec wenn ueber NX gestartet.
if [ "$SSH_ORIGINAL_COMMAND" = "/usr/NX/bin/nxnode" ]; then
	EXECSHELL=0
fi

# Jetzt wird die gewuenschte Shell gestartet

if [ -n "$NEWSHELL" ]; then
       if [ -f $NEWSHELL ]; then
                SHELL=$NEWSHELL
                export SHELL
		if [ "$SHELL" != "/bin/sh" ]; then
			if [ "$EXECSHELL" = "1" ]; then
                                if [ "$OS" = "AIX" ]; then
                                        wait
                                fi
              			exec $SHELL
			else
              			$SHELL $HOME/.bashrc
			fi
		fi
        fi
fi


