#!/usr/bin/env bash

apt-get update && apt-get install -y -f ssh vim git dh-autoreconf \
      pkg-config build-essential cmake coreutils sed libreadline-dev \
      libncurses5-dev libyaml-dev libssl-dev libcurl4-openssl-dev \
      libunwind-dev python python-pip python-setuptools python-dev \
      python-msgpack python-yaml python-argparse python-six python-gevent

# Build Tarantool
git clone --recursive https://github.com/tarantool/tarantool.git -b 1.8 tarantool
cd tarantool; cmake . -DENABLE_DIST=ON ; make; make install; cd ..;

# Build tarantool-c
git clone --recursive https://github.com/tarantool/tarantool-c tarantool-c
cd tarantool-c/third_party/msgpuck/; cmake . ; make; make install; cd ../../..;
cd tarantool-c; cmake . ; make; make install; cd ..;

# Build SysBench
./autogen.sh; ./configure --with-tarantool --without-mysql; make; make install;

# Run Tarantool
tarantool start-server.lua > /dev/null &
sleep 2; TNT_PID=$!

# Run SysBench, Print results to screen, Save results to results.txt
apt-get install -y -f gdb
echo "test_name:result[trps]"
./testing-tnt.sh --port=3301 --threads=1 | tee result.txt

# Clear
kill $TNT_PID ; rm -f *.xlog ; rm -f *.snap