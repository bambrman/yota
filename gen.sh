#/bin/bash

if [ $# != "2" ]
then
	echo "Usage: `basename $0` login password"
	exit 1
fi 

pr=`curl -c cook.txt  -s -k -L -d "IDToken1=$1&IDToken2=$2&IDToken3=$2&goto=https%3A%2F%2Fmy.yota.ru%3A443%2Fselfcare%2FloginSuccess&gotoOnFail=https%3A%2F%2Fmy.yota.ru%3A443%2Fselfcare%2FloginError&old-token=&org=customer" https://login.yota.ru/UI/Login | grep "Yota - Р’С…РѕРґ РІ Р›РёС‡РЅС‹Р№ РєР°Р±РёРЅРµС‚/Р РµРіРёСЃС‚СЂР°С†РёСЏ"`

if [ ${#pr} -eq 0 ]
then
 echo "Login OK"
 pr=`curl -b cook.txt  -s -k -L https://my.yota.ru/selfcare/devices | grep "\"product\" va"`

 if [ ${#pr} -eq 0 ]
  then
	 echo "Personal cabinet error!!!"
	 logger -t YOTA "Personal cabinet error!!!"
	 exit 1	
  fi
else
 echo "Login error!!!"
 logger -t YOTA "Login error!!!"
 exit 1
fi

echo "Personal cabinet OK"
x=`curl -b cook.txt  -s -k -L https://my.yota.ru/selfcare/devices`
# x=$(cat $1)

y=${x#*\"steps\":}
y=${y%\"optionList\"*}

y=${y#*\"code\":\"}
y=${y#*speedNumber\":\"}

i=0
acod=""
asn=""	

while [ true ]; do

	y1=${y#*\"code\":\"}
	if [ "$y1" = "$y" ]; then 
		break
	fi
 	y=$y1
	cod=${y%%\"*}
	y=${y#*speedNumber\":\"}
	sn=${y%%\"*}	

	if [ "$sn" = "<div class=\\" ]; then 
		sn="max"
	fi
	acod="$acod"" ""$cod"
	asn="$asn"" ""$sn"
done

#---------------------------------------------------------
#---------------------------------------------------------
#---------------------------------------------------------


echo "#!/bin/bash" > n_yota.sh
echo "" >> n_yota.sh
echo "Number_of_expected_args=3" >> n_yota.sh
echo "E_WRONG_ARGS=85" >> n_yota.sh
echo "" >> n_yota.sh
echo "script_usage=\"<login> <passwd> <speed>" >> n_yota.sh
echo "<speed in kbps>""$asn"")\"" >> n_yota.sh
echo "if [ \$# != \$Number_of_expected_args ]" >> n_yota.sh
echo "then" >> n_yota.sh
echo "echo \"Usage:\`basename \$0\` \$script_usage\"" >> n_yota.sh
echo "exit \$E_WRONG_ARGS" >> n_yota.sh
echo "fi " >> n_yota.sh
echo "" >> n_yota.sh 
echo "case \$3 in" >> n_yota.sh

i_num=1
for q in $asn; do
	p=$(echo $acod | awk '{print  $'"${i_num}"' }')
        if [  "$i_num"  = "1" ]; then 
		pd=$p
	fi
	echo $q") TARIF=\""$p"\";;" >> n_yota.sh
	let i_num++
done

echo "*) TARIF=\"$pd\";;">>n_yota.sh
echo "esac" >> n_yota.sh

echo "pr=\`curl -c cook.txt  -s -k -L -d \"IDToken1=\$1&IDToken2=\$2&IDToken3=\$2&goto=https%3A%2F%2Fmy.yota.ru%3A443%2Fselfcare%2FloginSuccess&gotoOnFail=https%3A%2F%2Fmy.yota.ru%3A443%2Fselfcare%2FloginError&old-token=&org=customer\" https://login.yota.ru/UI/Login | grep \"Yota - Р’С…РѕРґ РІ Р›РёС‡РЅС‹Р№ РєР°Р±РёРЅРµС‚/Р РµРіРёСЃС‚СЂР°С†РёСЏ\"\`">>n_yota.sh

echo "" >> n_yota.sh 

echo "if [ \${#pr} -eq 0 ]" >> n_yota.sh 

echo "then" >> n_yota.sh 
echo "pr=\`curl -b cook.txt  -s -k -L https://my.yota.ru/selfcare/devices | grep \"\\\"product\\\" va\"\`" >> n_yota.sh 
echo " if [ \${#pr} -eq 0 ]" >> n_yota.sh 
echo " then" >> n_yota.sh 
echo "echo \"Personal cabinet error!!!\"" >> n_yota.sh 
echo "logger -t YOTA \"Personal cabinet error!!!\"" >> n_yota.sh 
echo "exit 1" >> n_yota.sh
echo "fi" >> n_yota.sh
echo "else
 echo \"Login error!!!\"
 logger -t YOTA \"Login error!!!\"
 exit 1
fi
pr=\${pr#*value=\\\"}
pr=\${pr%\\\" />}

OCODE=\$TARIF" >> n_yota.sh
echo  "od=\`curl -b cook.txt  -s -k -L -d \"product=\$pr&offerCode=\$OCODE&homeOfferCode=&areOffersAvailable=false&period=&status=custom&autoprolong=0&isSlot=false&resourceId=&currentDevice=1&username=&isDisablingAutoprolong=false\" https://my.yota.ru/selfcare/devices/changeOffer | grep \"offerDisabled\"\`">>n_yota.sh

echo "
if [ \${#od} -eq 0 ]
then
 echo \"ChangeOffer Error!!!\"
 logger -t YOTA \"ChangeOffer Error!!!\"
 exit 1
fi " >> n_yota.sh

echo "
od=\${od#*offerDisabled}
od=\${od%%amountNumber*}
dn=\${od##*:}
dn=\$\"Days: \"\${dn%,*}
" >> n_yota.sh

echo "
speed=\${od#*speedNumber\\\":}
speed=\$\"Speed: \"\${speed%%,*}

echo \$speed  \$dn
logger -t YOTA \$speed  \$dn
exit 0

" >> n_yota.sh
echo "n_yota.sh created"
exit 0
