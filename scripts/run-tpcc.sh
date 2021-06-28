#!/bin/bash
#
# This script is based on the original:
# https://github.com/epfl-dias/trireme/blob/master/src/scripts/run-tpcc.sh

# benchmark options are:
# -a alpha value for zipf/probability for bernoulli
# -b type of benchmark (0 = micro, 1 = ycsb, 2 = tpcc)
# -c number of active servers (used in virt)
# -d ratio of distributed to local txns
# -f number of fibers per thread
# -h fraction of records to use for hot bernoulli range
# -i number of iterations
# -o ops per iteration
# -p #servers to use for holding hot bernoulli range
# -r nremote operations per txn
# -s number of servers / partitions
# -t max #records
# -v stats verbosity (0/1 log of access counts
# -w hash insert ratio over total number of queries

cores=( 64 32 16 8 4 2 1 )
max_trials=1

iterations=1000000
benchmark=1
op_per_iteration=10
max_records=$(expr 64 \* ${iterations})
hash_ratio=100

#################################################################

make clean
make CFLAGS="-DENABLE_WAIT_DIE_CC" CC=clang trireme

for core in ${cores[@]}; do
    for trial in $(seq 1 1 ${max_trials}); do
        log="tr.tpcc.b1.neworder.all-local-${core}-${trial}.log"
        echo ./trireme -s ${core} -d 100 -b ${benchmark} -i ${iterations} -o ${op_per_iteration} -t ${max_records} -w ${hash_ratio} >> ${log}
        ./trireme -s ${core} -d 100 -b ${benchmark} -i ${iterations} -o ${op_per_iteration} -t ${max_records} -w ${hash_ratio} >> ${log}
    done
done

for core in ${cores[@]}; do
    for trial in $(seq 1 1 ${max_trials}); do
        log="tr.tpcc.b4.neworder-with-batching-${core}-${trial}.log"
        echo ./trireme -s ${core} -d 0 -b 4 -i ${iterations} -o ${op_per_iteration} -t ${max_records} -w ${hash_ratio} >> ${log}
        ./trireme -s ${core} -d 0 -b 4 -i ${iterations} -o ${op_per_iteration} -t ${max_records} -w ${hash_ratio} >> ${log}
    done
done

#################################################################

make clean
make CFLAGS="-DSHARED_NOTHING -DPTHREAD_SPINLOCK" trireme CC=clang

for core in ${cores[@]}; do
    for trial in $(seq 1 1 ${max_trials}); do
        log="sn.tpcc.b1.neworder.all-local-${core}-${trial}.log"
        echo ./trireme -s $core -d 100 -b ${benchmark} -i ${iterations} -o ${op_per_iteration} -t ${max_records} -w ${hash_ratio} >> ${log}
        ./trireme -s $core -d 100 -b ${benchmark} -i ${iterations} -o ${op_per_iteration} -t ${max_records} -w ${hash_ratio} >> ${log}
    done
done

for core in ${cores[@]}; do
    for trial in $(seq 1 1 ${max_trials}); do
        log="sn.tpcc.neworder-${core}-${trial}.log"
        echo ./trireme -s $core -d 0 -b ${benchmark} -i ${iterations} -o ${op_per_iteration} -t ${max_records} -w ${hash_ratio} >> ${log}
        ./trireme -s $core -d 0 -b ${benchmark} -i ${iterations} -o ${op_per_iteration} -t ${max_records} -w ${hash_ratio} >> ${log}
    done
done

#################################################################

make clean
make CFLAGS="-DSHARED_EVERYTHING -DSE_LATCH -DPTHREAD_SPINLOCK -DENABLE_WAIT_DIE_CC " trireme CC=clang

for core in ${cores[@]}; do
    for trial in $(seq 1 1 ${max_trials}); do
        log="se.tpcc.b1.neworder.all-local-${core}-${trial}.log"
        echo ./trireme -s $core -d 100 -b ${benchmark} -i ${iterations} -o ${op_per_iteration} -t ${max_records} -w ${hash_ratio} >> ${log}
        ./trireme -s $core -d 100 -b ${benchmark} -i ${iterations} -o ${op_per_iteration} -t ${max_records} -w ${hash_ratio} >> ${log}
    done
done

for core in ${cores[@]}; do
    for trial in $(seq 1 1 ${max_trials}); do
        log="se.tpcc.neworder-${core}-${trial}.log"
        echo ./trireme -s $core -d 0 -b ${benchmark} -i ${iterations} -o ${op_per_iteration} -t ${max_records} -w ${hash_ratio} >> ${log}
        ./trireme -s $core -d 0 -b ${benchmark} -i ${iterations} -o ${op_per_iteration} -t ${max_records} -w ${hash_ratio} >> ${log}
    done
done
