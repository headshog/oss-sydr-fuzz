#!/bin/bash -ex
# Copyright 2024 ISP RAS
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


# Make directories for fuzzing and coverage (AFL++).
mkdir -p /afl_build_fuzz /afl_build_cov
cp /ProgramAFL.cs /fuzz.csproj /afl_build_fuzz
cp /ProgramAFL.cs /fuzz.csproj /afl_build_cov

# Make directories for fuzzing and coverage (libfuzzer).
mkdir -p /lf_build_fuzz /lf_build_cov
cp /ProgramLF.cs /fuzz.csproj /lf_build_fuzz
cp /ProgramLF.cs /fuzz.csproj /lf_build_cov

# Build target for fuzzing (AFL++).
cd /afl_build_fuzz
dotnet publish fuzz.csproj -c release -o bin
sharpfuzz bin/YamlDotNet.dll

# Build target for fuzzing (libfuzzer).
cd /lf_build_fuzz
dotnet publish fuzz.csproj -c release -o bin
sharpfuzz bin/YamlDotNet.dll

# Get corpus.
mkdir /corpus
cp /YamlDotNet/YamlDotNet.Test/files/*.yaml /corpus
