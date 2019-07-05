#!/usr/bin/env bash
mapfile -t CREDS < <(credhub find -n c | grep "name:")

for CRED in "${CREDS[@]}"
do
   CRED=${CRED/- name: /}

   if [[ ${CRED} == *"${1}"* ]]; then
      echo "Deleting ${CRED}"
      credhub delete -n ${CRED}
   fi

done

