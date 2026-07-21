#!/bin/bash
# check-ssl.sh - SSL expiry monitoring <7 days alert Slack - GAP Fixed

DOMAIN="api.grosirun.id"
DAYS_THRESHOLD=7

EXPIRY=$(echo | openssl s_client -servername $DOMAIN -connect $DOMAIN:443 2>/dev/null | openssl x509 -noout -enddate | cut -d= -f2)
EXPIRY_EPOCH=$(date -d "$EXPIRY" +%s)
NOW_EPOCH=$(date +%s)
DAYS_LEFT=$(( (EXPIRY_EPOCH - NOW_EPOCH) / 86400 ))

echo "SSL $DOMAIN expires $EXPIRY ($DAYS_LEFT days left)"

if [ $DAYS_LEFT -lt $DAYS_THRESHOLD ]; then
  echo "ALERT: SSL expires soon!"
  if [ ! -z "$SLACK_WEBHOOK" ]; then
    curl -X POST -H 'Content-type: application/json' --data "{\"text\":\"ALERT: SSL $DOMAIN expires in $DAYS_LEFT days! $EXPIRY - Renew ASAP\"}" $SLACK_WEBHOOK
  fi
  exit 1
else
  echo "OK SSL >$DAYS_THRESHOLD days"
fi
