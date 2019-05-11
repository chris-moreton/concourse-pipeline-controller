#!/usr/bin/env bash
mkdir ~/.ssh
cat deploy.key | sed -e 's/\(KEY-----\)\s/\1\n/g; s/\s\(-----END\)/\n\1/g' | sed -e '2s/\s\+/\n/g' > ~/.ssh/id_rsa
chmod 600 ~/.ssh/id_rsa
git clone $1 -key ~/.ssh/id_rsa