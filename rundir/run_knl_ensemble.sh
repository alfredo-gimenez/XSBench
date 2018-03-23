#!/usr/bin/env bash

function xsrun () {
    RUN="s_$1-l_$2"

    CALI_RECORDER_FILENAME=${CALI_CONFIG_PROFILE}-${RUN}-NoHBM.cali \
        ./XSBench -s $1 -l $2 

    CALI_RECORDER_FILENAME=${CALI_CONFIG_PROFILE}-${RUN}-FullHBM.cali \
        numactl --membind=1 ./XSBench -s $1 -l $2 
}

if [ "$#" -ne 1 ]
then
    echo "Usage: $0 <cali-config-profile-name>"
    exit 1
fi

# Warmup
export CALI_CONFIG_PROFILE=""
./XSBench -s small -l 10000

# Set cali config profile here
export CALI_CONFIG_PROFILE=$1

for size in small large
do
    for lookups in 10000000 20000000 40000000 80000000
    do
        xsrun $size $lookups
    done
done

cali-query -q "SELECT *,sum(time.duration),percentage(libpfm.counter.MEM_UOPS_RETIRED:L2_MISS_LOADS,libpfm.counter.MEM_UOPS_RETIRED:ALL_LOADS) WHERE annotation GROUP BY annotation,problem_size,problem_lookups FORMAT JSON(quote-all) ORDER BY annotation,problem_lookups,problem_size" ${CALI_CONFIG_PROFILE}*NoHBM.cali > ensemble-NoHBM-${CALI_CONFIG_PROFILE}.json

cali-query -q "SELECT *,sum(time.duration),percentage(libpfm.counter.MEM_UOPS_RETIRED:L2_MISS_LOADS,libpfm.counter.MEM_UOPS_RETIRED:ALL_LOADS) WHERE annotation GROUP BY annotation,problem_size,problem_lookups FORMAT JSON(quote-all) ORDER BY annotation,problem_lookups,problem_size" ${CALI_CONFIG_PROFILE}*FullHBM.cali > ensemble-FullHBM-${CALI_CONFIG_PROFILE}.json
