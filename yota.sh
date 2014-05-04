#!/bin/ash

Number_of_expected_args=3
E_WRONG_ARGS=85

script_usage="<login> <passwd> <speed>
<speed in kbps> 320, 416, 512, 768, 1200, 1800, 2500, 3300, 4000, 4800, 5500,
                6300, 7000, 7800, 8500, 9300, 10000, 12000, 15000, 18000, max)"

if [ $# != $Number_of_expected_args ] 
then
 echo "Usage: `basename $0` $script_usage"
 exit $E_WRONG_ARGS
fi 

case $3 in
 320) TARIF="02";;
 416) TARIF="03";;
 512) TARIF="04";;
 768) TARIF="05";;
1200) TARIF="06";;
1800) TARIF="07";;
2500) TARIF="08";;
3300) TARIF="09";;
4000) TARIF="10";;
4800) TARIF="11";;
5500) TARIF="12";;
6300) TARIF="13";;
7000) TARIF="14";;
7800) TARIF="15";;
8500) TARIF="16";;
9300) TARIF="17";;
10000) TARIF="18";;
12000) TARIF="19";;
15000) TARIF="20";;
18000) TARIF="21";;
max) TARIF="22";;
*) TARIF="02";;
esac

pr=`curl -c cook.txt  -s -k -L -d "IDToken1=$1&IDToken2=$2&goto=https%3A%2F%2Fmy.yota.ru%3A443%2Fselfcare%2FloginSuccess&gotoOnFail=https%3A%2F%2Fmy.yota.ru%3A443%2Fselfcare%2FloginError&old-token=&org=customer" https://login.yota.ru/UI/Login | grep "РќРµРІРµСЂРЅРѕРµ РёРјСЏ РїРѕР»СЊР·РѕРІР°С‚РµР»СЏ РёР»Рё РїР°СЂРѕР»СЊ."`

if [ ${#pr} -eq 0 ]
then
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

pr=${pr#*value=\"}
pr=${pr%\" />}
OCODE="POS-MA14-00"$TARIF

od=`curl -b cook.txt  -s -k -L -d "product=$pr&offerCode=$OCODE&homeOfferCode=&areOffersAvailable=false&period=&status=custom&autoprolong=0&isSlot=false&resourceId=&currentDevice=1&username=&isDisablingAutoprolong=false" https://my.yota.ru/selfcare/devices/changeOffer | grep "offerDisabled"`

if [ ${#od} -eq 0 ]
then
 echo "ChangeOffer Error!!!"
 logger -t YOTA "ChangeOffer Error!!!"
 exit 1
fi

od=${od#*offerDisabled}
od=${od%%amountNumber*}
dn=${od##*:}
dn=$"Days: "${dn%,*}

speed=${od#*speedNumber\":}
speed=$"Speed: "${speed%%,*}

echo $speed  $dn
logger -t YOTA $speed  $dn
exit 0
