#!/usr/bin/env bash

# Copyright 2016 Datawire. All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

BIN_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. ${BIN_PATH}/functions.sh

install_packer() {
    local packer_architecture="$1_amd64"
    local packer_version=$2
    local packer_archive=packer_${packer_version}_${packer_architecture}.zip
    local packer_url=https://releases.hashicorp.com/packer/${packer_version}/${packer_archive}

    mkdir -p bin
    if [ ! -f /tmp/${packer_archive} ]; then
        wget -O /tmp/${packer_archive} ${packer_url}
    fi

    unzip -o -d bin /tmp/${packer_archive}
}

if ! command -v bin/packer >/dev/null 2>&1; then
  arw_msg "Installing Packer..."
  install_packer "$(uname -s | tr '[:upper:]' '[:lower:]')" "0.10.0"
fi