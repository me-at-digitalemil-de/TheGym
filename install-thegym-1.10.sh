#!/bin/bash
export DCOS_URL=$(dcos config show core.dcos_url)
echo DCOS_URL: $DCOS_URL
dcos package install --yes --cli dcos-enterprise-cli

echo Determing public node ip...
export PUBLICNODEIP=$(./findpublic_ips.sh | head -1 | sed "s/.$//" )
echo Public node ip: $PUBLICNODEIP 
echo ------------------

if [ ${#PUBLICNODEIP} -le 6 ] ;
then
	echo Can not find public node ip. JQ in path?
	exit -1
fi

read -p "Install services? (y/n) " -n1 -s c
if [ "$c" = "y" ]; then
	echo yes
	 dcos package install --yes marathon-lb --package-version=1.10.1
     dcos package install --yes cassandra --package-version=2.0.0-3.0.14
     dcos package install --yes kafka --package-version=2.0.0-0.11.0.0
     dcos package install --yes elastic --package-version=2.0.0-5.5.1 --options=elastic-config.json
     dcos package install --options=kibana-config.json --yes kibana --package-version=2.0.0-5.5.1
	 dcos package install --yes zeppelin --package-version=0.6.0		
else
	echo no
fi

seconds=0
OUTPUT=0
while [ "$OUTPUT" -ne 1 ]; do 
  OUTPUT=`dcos marathon app list | grep kibana | awk '{print $5}' | cut -c1`;
  seconds=$((seconds+5))
  printf "Waiting %s seconds for Kibana to come up.  It normally takes about 400 seconds.\n" "$seconds"
  sleep 5
done


cp config.json config.tmp
sed -ie "s@PUBLICNODEIP@$PUBLICNODEIP@g;"  config.tmp
sed -ie "s@CLUSTER_URL_TOKEN@$DCOS_URL@g;"  config.tmp

cp setmodel.template setmodel.sh
sed -ie "s@PUBLIC_SLAVE_ELB_HOSTNAME@$PUBLICNODEIP@g" setmodel.sh
rm setmodel.she

cp clearmodel.template clearmodel.sh
sed -ie "s@PUBLIC_SLAVE_ELB_HOSTNAME@$PUBLICNODEIP@g" clearmodel.sh
rm clearmodel.she

dcos marathon group add config.tmp
until $(curl --output /dev/null --silent --head --fail http://$PUBLICNODEIP:10000); do
    printf '.'
    sleep 5
done
./permissions.sh ./config.json
open http://$PUBLICNODEIP:10000
rm config.tmpe config.tmp
