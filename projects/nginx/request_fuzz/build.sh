#!/bin/bash -eu
# Copyright 2020 Google Inc.
# Modifications copyright (C) 2024 ISP RAS
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
################################################################################

cd /nginx

# Apply diff for libFuzzer and AFL++ builds
hg import src/request_fuzz/add_fuzzers.diff --no-commit
cp src/request_fuzz/make_fuzzers auto/make_fuzzers

# Build targets for libfuzzer
export CC=clang
export CXX=clang++
export CFLAGS="-g -fsanitize=fuzzer-no-link,address,integer,bounds,null,undefined,float-divide-by-zero"
export CXXFLAGS="-g -fsanitize=fuzzer-no-link,address,integer,bounds,null,undefined,float-divide-by-zero"

auto/configure \
    --with-http_v2_module
make -j$(nproc) -f objs/Makefile modules

export CC=clang
export CXX=clang++
export CFLAGS="-g -fsanitize=fuzzer,address,integer,bounds,null,undefined,float-divide-by-zero"
export CXXFLAGS="-g -fsanitize=fuzzer,address,integer,bounds,null,undefined,float-divide-by-zero"
make -j$(nproc) -f objs/Makefile fuzzers

for fuzzer in objs/*_fuzzer;
do
    fuzzer_name=$(basename -s _fuzzer $fuzzer)
    cp $fuzzer /${fuzzer_name}_lf
done

# Build targets for AFL++
export CC=afl-clang-fast
export CXX=afl-clang-fast++
export CFLAGS="-g -fsanitize=address,integer,bounds,null,undefined,float-divide-by-zero"
export CXXFLAGS="-g -fsanitize=address,integer,bounds,null,undefined,float-divide-by-zero"

auto/configure \
    --with-http_v2_module
make -j$(nproc) -f objs/Makefile modules

export CC=afl-clang-fast
export CXX=afl-clang-fast++
export CFLAGS="-g -fsanitize=fuzzer,address,integer,bounds,null,undefined,float-divide-by-zero"
export CXXFLAGS="-g -fsanitize=fuzzer,address,integer,bounds,null,undefined,float-divide-by-zero"

make -j$(nproc) -f objs/Makefile fuzzers

for fuzzer in objs/*_fuzzer;
do
    fuzzer_name=$(basename -s _fuzzer $fuzzer)
    cp $fuzzer /${fuzzer_name}_afl++
done

# Apply diff for Sydr and cov builds
hg revert --all
hg import src/request_fuzz/add_sydr.diff --no-commit
cp src/request_fuzz/make_sydr auto/make_sydr

# Build targets for Sydr
export CC=clang
export CXX=clang++
export CFLAGS="-g -fPIE"
export CXXFLAGS="-g -fPIE"

auto/configure \
    --with-http_v2_module

make -j$(nproc) -f objs/Makefile fuzzers

for fuzzer in objs/*_fuzzer;
do
    fuzzer_name=$(basename -s _fuzzer $fuzzer)
    cp $fuzzer /${fuzzer_name}_sydr
done

# Build targets for cov
export CC=clang
export CXX=clang++
export CFLAGS="-g -fprofile-instr-generate -fcoverage-mapping -fPIE"
export CXXFLAGS="-g -fprofile-instr-generate -fcoverage-mapping -fPIE"

auto/configure \
    --with-http_v2_module

make -j$(nproc) -f objs/Makefile fuzzers

for fuzzer in objs/*_fuzzer;
do
    fuzzer_name=$(basename -s _fuzzer $fuzzer)
    cp $fuzzer /${fuzzer_name}_cov
done

hg revert --all
