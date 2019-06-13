#!/usr/bin/env bash
mapfile -t CREDS < <(credhub find -n c | grep "name:")

for CRED in "${CREDS[@]}"
do
   echo "${CRED}"
done