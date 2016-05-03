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
set -u

BIN_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. ${BIN_PATH}/functions.sh

force_build="${FORCE_BUILD:=false}"
is_jenkins="${JENKINS:=false}"
is_travis="${TRAVIS:=false}"
packer_exec="${PACKER_EXEC:=bin/packer}"
packer_templates_root=.
packer_template_file="${1:?Packer template file not specified}"
packer_template_file_basename=${packer_template_file%.*}
packer_variables_file="${packer_template_file_basename}-variables.json"

if [ ! -f "$packer_templates_root/$packer_template_file" ]; then
    arw_msg "Packer template file does not exist (file: $packer_templates_root/$packer_template_file)"
    exit 1
fi

if [ -f "$packer_variables_file" ]; then
    arw_msg "Removing pre-existing variable file"
    rm -r "$packer_variables_file"
fi

build_number=0
builder="unknown"
branch="unknown"
commit="unknown"

if [ "$is_jenkins" = "true" ]; then
    arw_msg "Running on Jenkins CI"
    branch="${GIT_BRANCH:?Running on Jenkins CI, but GIT_BRANCH is not set}"
    build_number="${BUILD_NUMBER:?Running on Jenkins CI, but BUILD_NUMBER is not set}"
    builder=jenkins
    commit="${GIT_COMMIT:?Running on Jenkins CI, but GIT_COMMIT is not set}"
elif [ "$is_travis" = "true" ]; then
    arw_msg "Running on Travis CI"
    branch="${TRAVIS_BRANCH:?Running on ravis CI, but TRAVIS_BRANCH is not set}"
    build_number="${TRAVIS_BUILD_NUMBER:?Running on Travis CI, but TRAVIS_BUILD_NUMBER is not set}"
    builder=travis
    commit="${TRAVIS_COMMIT:?Running on Travis CI, but TRAVIS_COMMIT is not set}"
else
    arw_msg "Running on unidentified build machine!"
fi

existing_ami_id="$(is_baked ${commit})"
if [ "$force_build" != "true" ] && [ "$existing_ami_id" != "" ]; then
    arw_msg "AMI exists with same Git commit hash; Skipping bake (AMI: ${existing_ami_id})"
    exit 0
fi

cat << EOF > "$packer_variables_file"
{
  "branch": "${branch#*/}",
  "build_number": "${build_number}",
  "builder": "${builder}",
  "commit": "${commit}",
  "force_deregister": "${force_build}"
}
EOF

${packer_exec} validate -var-file=${packer_variables_file} ${packer_templates_root}/${packer_template_file}
${packer_exec} build -machine-readable -var-file=${packer_variables_file} ${packer_templates_root}/${packer_template_file} | tee packer.log