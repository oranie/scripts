#!/bin/sh

SCHEDULER_LIST='
cfq
deadline
noop
'


TEST_MODE_LIST='
rndwr
rndrw
rndrd
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
2048
'

BLOCK_SIZE_LIST='
16384
'

FILE_SIZE_TOTAL='16G'

# main

for SCHEDULER in ${SCHEDULER_LIST}; do
for TEST_MODE in ${TEST_MODE_LIST}; do
for THREAD in ${THREAD_LIST}; do
for BLOCK_SIZE in ${BLOCK_SIZE_LIST}; do

    echo "------- SCHEDULER:${SCHEDULER} MODE:${TEST_MODE} THREAD:${THREAD} BLOCK:${BLOCK_SIZE} -------"

    # delete cache 
    echo "prepare...."
    sleep 3
    sync
    echo 3 > /proc/sys/vm/drop_caches

    # preapare
    echo ${SCHEDULER}  > /sys/block/sda/queue/scheduler
    /usr/local/sysbench/bin/sysbench --test=fileio --file-total-size=${FILE_SIZE_TOTAL} prepare
    echo "done...."

    # run
    echo "running test...."
    /usr/local/sysbench/bin/sysbench --test=fileio --file-total-size=${FILE_SIZE_TOTAL} \
        --file-test-mode=${TEST_MODE} \
        --num-threads=${THREAD} \
        --file-block-size=${BLOCK_SIZE} \
        --init-rng=on --max-time=60 --max-requests=0 run
    echo "done...."

    # cleanup
    echo "clean up...."
    /usr/local/sysbench/bin/sysbench --test=fileio --file-total-size=${FILE_SIZE_TOTAL} cleanup
    echo "done...."

done
done
done
done

# set default scheduler
echo "cfq"  > /sys/block/sda/queue/scheduler
