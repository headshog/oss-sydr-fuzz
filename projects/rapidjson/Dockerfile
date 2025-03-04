# Copyright 2019 Google Inc.
# Modifications copyright (C) 2021 ISP RAS
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

ARG BASE_IMAGE="sydr/ubuntu20.04-sydr-fuzz"
FROM $BASE_IMAGE

# Set author of this docker container.
MAINTAINER Andrey Fedotov

# Install dependencies for build and analysis.
RUN apt-get update && \
    apt-get -y install autoconf automake libtool zip

# Clone target from github.
RUN git clone  https://github.com/Tencent/rapidjson.git rapidjson
RUN git clone  https://github.com/guidovranken/rapidjson-fuzzers.git rapidjson-fuzzers
RUN git clone  https://github.com/guidovranken/fuzzing-headers.git

# Fix commit. It could be updated.
RUN cd rapidjson && git checkout 4d6cb08189cf7336821f04090b612baa2ca6a90d && cd /

RUN mkdir /rapidjson-sydr && mkdir /rapidjson-fuzzer && mkdir /rapidjson-afl && \
    mkdir /rapidjson-cov && mkdir corpus

WORKDIR rapidjson-fuzzers

# Copy modified build scripts for fuzz targets.
COPY ./build.sh .

# Copy target for sydr
COPY ./rapidjson-sydr.cpp .

COPY afl.cc /

#  Build targets.
RUN ./build.sh

WORKDIR /corpus

RUN unzip /rapidjson-fuzzers/fuzzer_seed_corpus.zip

WORKDIR ..
