#!/usr/bin/env bash
mkdir tarantool_data
docker run --rm -t -i \
             -v `pwd`/:/opt/tarantool/ \
             -v `pwd`/tarantool_data:/var/lib/tarantool \
             --name tarantool \
             tarantool/tarantool:2 \
             tarantool /opt/tarantool/main.lua
