#!/usr/bin/env bash
echo "$2" | sed -e 's/\(KEY-----\)\s/\1\n/g; s/\s\(-----END\)/\n\1/g' | sed -e '2s/\s\+/\n/g' > ~/.ssh/deploy_key
chmod 600 ~/.ssh/deploy_key
git clone $1 -key ~/.ssh/deploy_key