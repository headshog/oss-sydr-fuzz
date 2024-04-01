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


# Make directories for fuzzing and coverage (XML).
mkdir -p /build_xml_fuzz /build_xml_cov
cp /ProgramXml.cs /fuzz.csproj /build_xml_fuzz
cp /ProgramXml.cs /fuzz.csproj /build_xml_cov

# Make directories for fuzzing and coverage (CSV).
mkdir -p /build_csv_fuzz /build_csv_cov
cp /ProgramCsv.cs /fuzz.csproj /build_csv_fuzz
cp /ProgramCsv.cs /fuzz.csproj /build_csv_cov

# Build target for fuzzing (XML).
cd /build_xml_fuzz
dotnet publish fuzz.csproj -c release -o bin
sharpfuzz bin/Sprache.dll

# Build target for fuzzing (CSV).
cd /build_csv_fuzz
dotnet publish fuzz.csproj -c release -o bin
sharpfuzz bin/Sprache.dll

# Get corpus (XML and CSV).
git clone https://github.com/dvyukov/go-fuzz-corpus.git /go-fuzz-corpus
cp -r /go-fuzz-corpus/xml/corpus /corpus_xml
cp -r /go-fuzz-corpus/csv/corpus /corpus_csv
rm -rf /go-fuzz-corpus
