#!/usr/bin/env bash

let threads=1
let port=3301

for i in "$@"
do
case $i in
    --threads=*)
    threads="${i#*=}"
    ;;

    --port=*)
    port="${i#*=}"
    ;;

    *)
            # unknown option
    ;;
esac
done

ARRAY_TESTS=(
    "oltp_read_only"
    "oltp_point_select"
    "oltp_insert"
    "oltp_update_index"
    "oltp_update_non_index"
    "select_random_points"
    "select_random_ranges"
    "bulk_insert"
    "oltp_write_only"
    "oltp_read_write"
    "oltp_delete"
)

for test in "${ARRAY_TESTS[@]}"; do
    echo -n $test":"
    ./src/sysbench $test --db-driver=tarantool --threads=$threads cleanup > /dev/null
    ./src/sysbench $test --db-driver=tarantool --threads=$threads prepare > /dev/null
    ./src/sysbench $test --db-driver=tarantool --threads=$threads run | grep -e 'transactions:' | grep -oP '\(\K\S*'
    ./src/sysbench $test --db-driver=tarantool --threads=$threads cleanup > /dev/null
done