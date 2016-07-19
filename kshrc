###############################################################################
###############################################################################
# Die .kshrc Datei dient zur Basiskonfiguration Ihres Unix-Accounts.          #
#                                                                             #
# Persoenliche Einstellungen werden ueber Dateien im Verzeichnis              #
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
# $Id: kshrc 1353 2009-09-10 10:35:10Z jans $
# $HeadURL: https://svn.devlab.de.tmo/devlab/svn/common/trunk/appl_common/startup/default/kshrc $

SetView() {
        __VIEW=$1
        shift
        echo $* | egrep "$CLUSTERALIAS|$HOSTNAME" >/dev/null
        if [ "$?" = "0" ]; then
                if [ "`cleartool pwv -short`" != "$__VIEW" ]; then
                        cleartool lsview $__VIEW 2>/dev/null | grep $__VIEW >/dev/null
                        if [ "$?" = 0 ]; then
				echo "********** Der View $__VIEW wird gesetzt"
                                cleartool setview $__VIEW
                        else
                                echo "********** Der View $__VIEW existiert nicht!"
                                echo "********** Passen Sie die Datei .settings/clearcase an!"
                        fi
                fi
        fi
	unset __VIEW
}

#################################################################
################## Prompt setzen              ###################
#################################################################

if [ "x$TERM" = "xxterm" ]; then
	export PROMPT_COMMAND='echo "\033]0;${USER}@${CLUSTERALIAS} ${PWD} View: `echo ${CLEARCASE_ROOT} | sed s,/view/,,g`\007"'  
fi
PS1=`$PROMPT_COMMAND`'$USER@$CLUSTERALIAS{$PWD} '

#################################################################
################## Alias-Definitionen setzen  ###################
#################################################################

case "$OS" in
OSF1*)	alias ldd="/usr/bin/odump -Dl "
	;;
esac

alias ct='cleartool'
alias xc='xclearcase &'
alias xcc='xclearcase &'
alias sv='cleartool setview'

alias l='ls -l'
alias ll='ls -l'
alias la='ls -aF'
alias dir='ls -l'

alias xe='xemacs'
alias mc='mc -c -a'

# Carmen Produktion CC NGS RSK etc
alias   hs0110='ssh2 -l iv98supp hs0110.mspr.detemobil.de' 
alias   hs0210='ssh2 -l iv98supp hs0210.mspr.detemobil.de' 
alias   hs0310='ssh2 -l iv98supp hs0310.mspr.detemobil.de' 
alias   hs0410='ssh2 -l iv98supp hs0410.mspr.detemobil.de' 

# Carmen Produktion R&B
alias   es6201a='ssh2 -l iv98supp es6201a.mspr.detemobil.de' 
alias   es6202a='ssh2 -l iv98supp es6202a.mspr.detemobil.de' 

#################################################################
################## User-Konfiguration sourcen ###################
#################################################################
 
for file in clearcase alias kshrc ; do
        if [ -f $HOME/.settings/$file ]; then
                . $HOME/.settings/$file
        fi
done

if [ "$OS" = "SunOS" -o "$OS" = "OSF1" ]; then
	/appl/common/startup/default/checkload.sh
fi

