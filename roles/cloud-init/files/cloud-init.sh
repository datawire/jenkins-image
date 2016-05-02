#!/usr/bin/env bash
set -e
set -u

arw_msg() {
  content=${1:?Message content not specified!}
  printf "%s\n" "--> $content"
}

arw_msg "Adding GitHub to SSH known hosts"
ssh-keyscan -H github.com > /etc/ssh/ssh_known_hosts

# TODO(@plombardi): This is where Jenkins master backup restoration logic should go...

arw_msg "Done!"
