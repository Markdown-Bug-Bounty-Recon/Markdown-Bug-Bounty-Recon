#!/bin/bash
SLACK_WEBHOOK_URL=$("${SLACK_WEBHOOK_URL}")
function push {
  RESPONSE=$(curl -X POST -H 'Content-type: application/json' --data '{"text":${1}' "${YOUR_WEBHOOK_URL}")
  echo $RESPONSE
}


exit 0
