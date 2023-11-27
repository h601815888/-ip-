#!/bin/sh
mkdir -p ./pbr
cd ./pbr

# AS4809 BGP
wget --no-check-certificate -c -O CN.txt https://raw.githubusercontent.com/mayaxcn/china-ip-list/master/chnroute.txt
wget --no-check-certificate -c -O CN6.txt https://raw.githubusercontent.com/mayaxcn/china-ip-list/master/chnroute_v6.txt

{
echo "/ip firewall address-list"

for net in $(cat CN.txt) ; do
  echo "add list=CN address=$net comment=AS4809"
done

} > ../CN.rsc

{
echo "/ip firewall address6-list"

for net in $(cat CN6.txt) ; do
  echo "add list=CN address=$net comment=AS4809"
done

} > ../CN6.rsc

cd ..
rm -rf ./pbr
