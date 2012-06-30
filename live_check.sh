#!/bin/sh
#
# This script discovers alive hosts by using GNU Parallel
#

segment=$1

fnum=`echo $segment | awk -F\. '{print NF}'`

if [ $fnum -ne 3 ]; then
    echo "ERROR"
    echo "usage: sh live_check.sh xx.xx.xx"
    echo "ex): live_check.sh 192.168.1"
    echo "     Check 192.168.1.1 - 192.168.1.254 are dead or alive"
    exit 1
fi

cmd_gnu_parallel="/usr/local/parallel/bin/parallel"

ping_ok_list=`${cmd_gnu_parallel} -j 40 -k "ping -w 1 -c 1 {1} | tr -d '\n' | sed -e 's/$/\n/' | grep -v '100% packet loss'" ::: $(seq 1 254 | sed -e "s%^%${segment}.%") | awk '{print $2}'`

for ip in ${ping_ok_list}; do
    echo ${ip}
done

