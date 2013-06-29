#!/bin/ash

Number_of_expected_args=3
E_WRONG_ARGS=85

script_usage="<login> <passwd> <speed>
<speed in kbps> 320, 512, 1000, 1400, 1800, 2200, 2900, 3600, 4300,
4800, 5000, 6100, 7200, 9300, 10000, 12000, 15000, max)"

if [ $# != $Number_of_expected_args ]
then
echo "Usage: `basename $0` $script_usage"
 exit $E_WRONG_ARGS
fi

case $3 in
 320) TARIF="02";;
 512) TARIF="03";;
1000) TARIF="04";;
1400) TARIF="05";;
1800) TARIF="06";;
2200) TARIF="07";;
2900) TARIF="08";;
3600) TARIF="09";;
4300) TARIF="10";;
4800) TARIF="11";;
5000) TARIF="11";;
6100) TARIF="12";;
7200) TARIF="13";;
10000) TARIF="14";;
15000) TARIF="15";;
max) TARIF="16";;
*) TARIF="02";;
esac

pr=`curl -c cook.txt -s -k -L -d "IDToken1=$1&IDToken2=$2&IDToken3=$2&goto=https%3A%2F%2Fmy.yota.ru%3A443%2Fselfcare%2FloginSuccess&gotoOnFail=https%3A%2F%2Fmy.yota.ru%3A443%2Fselfcare%2FloginError&old-token=&org=customer" https://login.yota.ru/UI/Login | grep "Yota - Вход в Профиль/Регистрация"`

if [ ${#pr} -eq 0 ]
then
pr=`curl -b cook.txt -s -k -L https://my.yota.ru/selfcare/devices | grep "\"product\" va"`
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
#OCODE="POS-MA14-00"$TARIF
OCODE="POS-MA13-00"$TARIF


od=`curl -b cook.txt -s -k -L -d "product=$pr&offerCode=$OCODE&homeOfferCode=&areOffersAvailable=false&period=&status=custom&autoprolong=0&isSlot=false&resourceId=&currentDevice=1&username=&isDisablingAutoprolong=false" https://my.yota.ru/selfcare/devices/changeOffer | grep "offerDisabled"`

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

echo $speed $dn
logger -t YOTA $speed $dn
exit 0
