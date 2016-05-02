#!/usr/bin/env bash
set -u

arw_msg() {
  content=${1:?Message content not specified!}
  printf "%s\n" "--> $content"
}

config_bucket=${1:?Jenkins config bucket not specified!}
jenkins_home=${2:-/var/lib/jenkins}

arw_msg "Adding GitHub to SSH known hosts"
ssh-keyscan -H github.com > /etc/ssh/ssh_known_hosts

latest_backup="$(aws s3 ls s3://${config_bucket}/jenkins/backup --recursive | tail -n1 | rev | cut -d' ' -f1 | rev)"

if [ "$latest_backup" != "jenkins/backup/" ]; then
    arw_msg "Restoring from latest backup... (backup: ${latest_backup}"
    rm -rf ${jenkins_home}/*
    mkdir -p ${jenkins_home}

    latest_backup_file="$(echo ${latest_backup} | rev | cut -d'/' -f1 | rev)"
    arw_msg "Download latest Jenkins backup (file: ${latest_backup_file})"
    aws s3 cp "s3://${config_bucket}/${latest_backup}" /tmp/${latest_backup_file}

    service jenkins stop
    arw_msg "Extracting Jenkins backup (into: $jenkins_home)"
    cd ${jenkins_home}
    cp /tmp/${latest_backup_file} ${jenkins_home}/${latest_backup_file}
    tar -xzvf ${latest_backup_file} --strip 1
    rm ${latest_backup_file}

    chown -R jenkins:jenkins ${jenkins_home}
else
    arw_msg "No backup found to restore from; Clean install."
fi

service jenkins restart
arw_msg "Done!"