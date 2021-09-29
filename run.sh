#!/bin/bash

set -e

[[ $# -ne 1 ]] && echo "duration(in seconds) is missing" && exit 1

rootdir=$(dirname $0)

cd $rootdir

if [[ ! -d FlameGraph ]]
then
	git clone --depth=1 https://github.com/brendangregg/FlameGraph.git
else
	cd FlameGraph
	git pull
	cd -
fi

datadir=$rootdir/data

mkdir -p $datadir

set -x

cd $datadir

rm -f perf.*

touch perf.data # so that it won't be created as root

sudo perf record -F 99 -a --call-graph dwarf sleep $1

perf script | ./../FlameGraph/stackcollapse-perf.pl > perf.stacks

./../FlameGraph/flamegraph.pl --inverted perf.stacks > perf.svg

firefox perf.svg