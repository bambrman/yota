#!/bin/bash

login="USER"
psw="PASSWORD" 
speedon="5500"
speedoff="320"

x=1
f=""

 for pr in $(strings pings)
   do
      ping -c 1 $pr
	    x=$(($x*$?))
   done

if [ $x -eq 1 ]
then
#повторно опросим на случай пропадания wifi  
  f=$(cat flag)
  	 if [ "$f" = "0" ]
		then
		  exit 0  # inet is down already
		fi
  sleep 180
  x=1;
 for pr in $(strings pings)
   do
	  ping -c 1 $pr
	  x=$(($x*$?))
   done
   if [ $x -eq 1 ]  
   then 
	    logger -t YOTA "Speed OFF"
	    i=`yota.sh $login $psw $speedoff`
	    RETVAL=$?
      echo $i
      if [ $RETVAL -eq 0 ]  
	    then
		    echo "0" > flag
	    fi
   fi 
else
  echo 'aps is here'
  f=$(cat flag)
  if [ "$f" = "0" ]
   then
        logger -t YOTA "Speed ON"
	i=`yota.sh $login $psw $speedon`
	RETVAL=$?       
	echo $RETVAL	
	echo $i
        		
            if [ $RETVAL -eq 0 ]  
            then
		    echo "1" > flag
	    fi
   fi
fi
