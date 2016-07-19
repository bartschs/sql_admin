#
# Functions
#
vilog ()
{
    if [ $# -ne 1 ] ; then
	echo "Ein Parameter notwendig!"
    else
	if [ -d log ]; then
	    /vobs/com_source/datenman/db-admin/Tools/common/chk_log.ksh "log/$1/*"
	else
	    echo "Kein Log-Directory vorhanden!"
	fi
    fi
}

clear_vosp ()
{
    rm -f /vobs/com_source/datenman/db-admin/build/admin/build_??_vosp*.sql
    find /vobs/com_source/datenman/db-admin/build/ke_collection -type f | xargs rm
}

mk_tmp_label ()
{
    if [ $# -ne 1 ] ; then
	echo "Ein Parameter notwendig!"
    else
	TMP_KE=$(basename $(pwd))
	cleartool mklabel $1 . db db/vo_sp db/vo_sp/_${TMP_KE}_vosp.ord
    fi
}

rm_tmp_label ()
{
    if [ $# -ne 1 ] ; then
	echo "Ein Parameter notwendig!"
    else
	TMP_KE=$(basename $(pwd))
	cleartool rmlabel $1 db/vo_sp/_${TMP_KE}_vosp.ord db/vo_sp db .
    fi
}

deliver_file ()
{
    if [ $# -ne 1 ] ; then
	echo "Ein Parameter notwendig!"
    else
	if [ -d $1 ] ; then
	    ARCHDIR=~g_dmint/build_tarfiles
	    echo ""
	    echo "tar-File erzeugen...\c"
	    tar cf $1.tar $1
	    echo "fertig"
	    echo ""
	    ftp ds1830.mspr.detemobil.de << EOT
cd /appl/ds1830/user1/hartjes/iv98/transfer
bin
put $1.tar
ls -lrt
bye
EOT
	    echo ""
	    echo "lokales tar-File"
	    echo ""
	    ls -l $1.tar
	    compress $1.tar
	    if [ -d $ARCHDIR ] ; then
		mv $1.tar.Z $ARCHDIR
		if [ -f $ARCHDIR/$1.tar.Z ] ; then
		    echo ""
		    echo "Directory $1 wird geloescht...\c"
		    rm -rf $1
		    echo "fertig"
		    echo ""
		else
		    echo "Probleme beim Verschieben von $1.tar.Z aufgetreten!"
		    echo "Directory $1 wird nicht geloescht!"
		fi
	    else
		echo "Directory $ARCHDIR existiert nicht!"
	    fi
	    unset ARCHDIR
	else
	    echo "Directory $1 existiert nicht!"
	fi
    fi
}

archive_file ()
{
    if [ $# -ne 1 ] ; then
	echo "Ein Parameter notwendig!"
    else
	if [ -d $1 ] ; then
	    ARCHDIR=~g_dmint/build_tarfiles
	    echo ""
	    echo "tar-File erzeugen...\c"
	    tar cf $1.tar $1
	    echo "fertig"
	    echo ""
	    echo "lokales tar-File"
	    echo ""
	    ls -l $1.tar
	    compress $1.tar
	    if [ -d $ARCHDIR ] ; then
		mv $1.tar.Z $ARCHDIR
		if [ -f $ARCHDIR/$1.tar.Z ] ; then
		    echo ""
		    echo "Directory $1 wird geloescht...\c"
		    rm -rf $1
		    echo "fertig"
		    echo ""
		else
		    echo "Probleme beim Verschieben von $1.tar.Z aufgetreten!"
		    echo "Directory $1 wird nicht geloescht!"
		fi
	    else
		echo "Directory $ARCHDIR existiert nicht!"
	    fi
	    unset ARCHDIR
	else
	    echo "Directory $1 existiert nicht!"
	fi
    fi
}

ls_transfer ()
{
	    ftp ds1830.mspr.detemobil.de << EOT
cd /appl/ds1830/user1/hartjes/iv98/transfer
ls -lrt
bye
EOT
}

untar_file ()
{
    if [ $# -ne 1 ] ; then
	echo "Ein Parameter notwendig!"
    else
	if [ -f $1.tar.Z ] ; then
	    if [ ! -d $1 ] ; then
		mkdir $1
	    fi
	    if [ -d $1 ] ; then
		echo ""
		echo "Datei $1.tar.Z entpacken...\c"
		zcat $1.tar.Z | ( cd $1 ; tar xf - )
		echo "fertig"
		echo ""
	    else
		echo "Directory $1 konnte nicht angelegt werden!"
	    fi
	else
	    echo "Datei $1.tar.Z existiert nicht!"
	fi
    fi
}

ch_root ()
{
    ROOTDIR=$(dirname $(pwd))
    if [ -f defines_??_???.sql ] ; then
    chmod -R 755 $ROOTDIR
    for FILE in `grep -l '^DEFINE ROOT = ' defines_*.sql` ; do
	ex $FILE << EOT
/^DEFINE ROOT = /
:s#/.*/#$ROOTDIR/#
wq
EOT
    done
    unset ROOTDIR
    else
	echo "defines_??_???.sql nicht vorhanden! Falsches Directory?"
    fi
}

alias build_files='/vobs/com_source/datenman/db-admin/Tools/Build/build_files.pl'
alias build_prep='/vobs/com_source/datenman/db-admin/Tools/Build/build_prep.pl'
alias calltree='/vobs/com_source/datenman/db-admin/Tools/CC_Label/calltree.prl'
alias collect_vosp='/vobs/com_source/datenman/db-admin/Tools/Build/collect_vosp.pl'
alias exp_error='/vobs/com_source/datenman/db-admin/Tools/Build/exp_error.pl'
alias prep_dat='/vobs/com_source/datenman/db-admin/Tools/CC_Label/prep_dat.ksh'
