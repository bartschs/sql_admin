#! /bin/sh
 
cd `dirname $0`
BINDIR=`pwd`
 
cd $BINDIR
 
#DB="ACA71"
#DOMAIN="msta.detemobil.de"
DB="PCA"
DOMAIN="mspr.detemobil.de"
PWD_OLD="\$1\$YZIGHXSH_H\$2\$"
PWD_NEW="Z9Sylvie#NY1"
 
touch sqlplus.log
 
for i in RB1 RB2 RB3 RB4 XR1 XR2 SP1 SP2 SP3 SW SW2 IS DS
do
   echo "DB $DB$i.$DOMAIN..."
   {
      echo "connect bartschs_s@$DB$i.$DOMAIN"
      sleep 1
      echo "$PWD_OLD"
      sleep 1
      echo "$PWD_NEW"
      sleep 1
      echo "$PWD_NEW"
      sleep 2
      echo "quit;"
   } | sqlplus /nolog >> sqlplus.log
 # } | cat >> sqlplus.log
done
