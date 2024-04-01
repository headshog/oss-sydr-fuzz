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

FROM sydr/ubuntu20.04-sydr-fuzz

RUN git clone https://github.com/sprache/Sprache.git && \
	cd Sprache && git checkout 9d1721bb0dea638e35b9bbb2334fea6f99bf778e

COPY build.sh ProgramXml.cs ProgramCsv.cs fuzz.csproj xml.dict csv.dict /

WORKDIR /

RUN /build.sh
