#!/usr/bin/env bash
mapfile -t CREDS < <(credhub find -n c | grep "name:")

for CRED in "${CREDS[@]}"
do
   CRED=${CRED/- name: /}
   OUTPUT="$(credhub get -n ${CRED})"

   if [[ $OUTPUT == *"type: ssh"* ]]; then
      PUBLIC="$(credhub get -q -n ${CRED} -k public_key)"
      PRIVATE="$(credhub get -q -n ${CRED} -k private_key)"
      echo "credhub set -n ${CRED} --type ssh --public \"${PUBLIC}\" --private \"${PRIVATE}\""
   elif [[ $OUTPUT == *"type: user"* ]]; then
      USERNAME="$(credhub get -q -n ${CRED} -k username)"
      PASSWORD="$(credhub get -q -n ${CRED} -k password)"
      echo "credhub set -n ${CRED} --type user --username \"${USERNAME}\" --password \"${PASSWORD}\""
   elif [[ $OUTPUT == *"type: value"* ]]; then
      VALUE="$(credhub get -q -n ${CRED})"
      echo "credhub set -n ${CRED} --type value --value \"${VALUE}\""
   fi

done
