#!/usr/bin/env bash

function xsrun () {
    RUN="s_$1-l_$2"

    CALI_CONFIG_PROFILE=load-counts-knl \
        CALI_RECORDER_FILENAME=counts-${RUN}-NoHBM.cali \
        CALI_REPORT_FILENAME=counts-${RUN}-NoHBM.json \
        ./XSBench -s $1 -l $2 

    CALI_CONFIG_PROFILE=load-samples-knl \
        CALI_RECORDER_FILENAME=samples-${RUN}-NoHBM.cali \
        CALI_REPORT_FILENAME=samples-${RUN}-NoHBM.json \
        ./XSBench -s $1 -l $2 

    CALI_CONFIG_PROFILE=load-counts-knl \
        CALI_RECORDER_FILENAME=counts-${RUN}-FullHBM.cali \
        CALI_REPORT_FILENAME=counts-${RUN}-FullHBM.json \
        numactl --membind=1 ./XSBench -s $1 -l $2 

    CALI_CONFIG_PROFILE=load-samples-knl \
        CALI_RECORDER_FILENAME=samples-${RUN}-FullHBM.cali \
        CALI_REPORT_FILENAME=samples-${RUN}-FullHBM.json \
        numactl --membind=1 ./XSBench -s $1 -l $2 
}

# warmup
./XSBench -s small -l 10000

for size in small large XL
do
    for lookups in 10000000 20000000 40000000 80000000
    do
        xsrun $size $lookups
    done
done

cali-query -q "SELECT *,sum(time.duration),sum(libpfm.counter.MEM_UOPS_RETIRED:ALL_LOADS),sum(libpfm.counter.MEM_UOPS_RETIRED:L2_MISS_LOADS) GROUP BY annotation,problem_size,problem_lookups FORMAT JSON(quote-all) ORDER BY problem_size,problem_lookups ASC,DESC" *.cali > xsbench_ensemble.json
