#!/bin/sh

READ_ONLY_FLAG='
on
off
'

SCHEDULER_LIST='
cfq
deadline
noop
'

THREAD_LIST='
1
2
4
8
16
32
64
128
256
512
1024
'

ROWS_LIST='
10000000
1000000
'

#TYPE='special'
TYPE_LIST='
uniform
'

USER='sysbench_user'
PASSWORD='sysbench_pwd'
HOST='127.0.0.1'
PORT=3306
DB='sbtest'
MODE='complex'

# main

for TYPE in ${TYPE_LIST}; do
for ROWS in ${ROWS_LIST}; do
for READ_ONLY in ${READ_ONLY_FLAG}; do
for SCHEDULER in ${SCHEDULER_LIST}; do
for THREAD in ${THREAD_LIST}; do

    echo "------ TYPE:${TYPE} ROWS:${ROWS} SCHEDULER:${SCHEDULER} READ_ONLY:${READ_ONLY} THREAD:${THREAD} ------"

    # preapare
    echo "prepare...."
    echo ${SCHEDULER}  > /sys/block/sda/queue/scheduler
    /usr/local/sysbench/bin/sysbench \
        --test=oltp \
        --db-driver=mysql \
        --oltp-table-size=${ROWS} \
        --mysql-user=${USER} \
        --mysql-password=${PASSWORD}  \
        --mysql-host=${HOST} \
        --mysql-port=${PORT} \
        --mysql-db=${DB} \
        prepare

    echo "done...."

    # run
    echo "running test...."
    /usr/local/sysbench/bin/sysbench \
        --test=oltp \
        --db-driver=mysql \
        --oltp-test-mode=${MODE} \
        --oltp-table-size=${ROWS} \
        --mysql-user=${USER} \
        --mysql-password=${PASSWORD}  \
        --mysql-host=${HOST} \
        --mysql-port=${PORT} \
        --mysql-db=${DB} \
        --max-time=60 \
        --max-requests=0 \
        --oltp-read-only=${READ_ONLY} \
        --oltp-dist-type=${TYPE} \
        --init-rng=on \
        --num-threads=${THREAD} \
        run
    echo "done...."

    # cleanup
    echo "clean up...."
    /usr/local/sysbench/bin/sysbench \
        --test=oltp \
        --db-driver=mysql \
        --oltp-table-size=${ROWS} \
        --mysql-user=${USER} \
        --mysql-password=${PASSWORD}  \
        --mysql-host=${HOST} \
        --mysql-port=${PORT} \
        --mysql-db=${DB} \
        cleanup
    echo "done...."

done
done
done
done
done

# set default scheduler
echo "cfq"  > /sys/block/sda/queue/scheduler

