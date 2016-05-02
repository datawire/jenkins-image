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
set -e

arw_msg() {
  printf "%s\n" "--> $1"
}

is_baked() {
  commit_hash=${1:?Commit hash not specified}
  result=""

  if [ "$commit_hash" != "unknown" ]; then
    result=$(aws ec2 describe-images \
             --owner self \
             --filters Name=tag:Commit,Values=${commit_hash} \
             --region us-east-1 \
             --query 'Images[*].ImageId' \
             --output text)
  fi

  printf "${result}"
}