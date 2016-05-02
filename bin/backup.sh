#!/usr/bin/env bash
set -e
set -u

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

build_id=${BUILD_ID:?Jenkins Build ID not set!}
jenkins_home=${JENKINS_HOME:?Jenkins home directory not set!}

# Delete all files in the workspace and then copy global configuration back into the workspace
rm -rf *
mkdir -p ${build_id}/jobs

# Copy keys and secrets into the workspace.
cp ${jenkins_home}/*.xml ${build_id}
cp ${jenkins_home}/identity.key ${build_id}/
cp ${jenkins_home}/secret.key ${build_id}/
cp ${jenkins_home}/secret.key.not-so-secret ${build_id}/
cp -r ${jenkins_home}/secrets ${build_id}/

# Copy user and job configuration into the workspace.
cp -r ${jenkins_home}/users ${build_id}/
rsync -am --include='config.xml' --include='*/' --prune-empty-dirs --exclude='*' ${jenkins_home}/jobs/ ${build_id}/jobs/

# Create an archive of all the copied configuration and then remove the directory.
tar czf ${build_id}.tar.gz ${build_id}/
rm -rf ${build_id}