#!/usr/bin/env bash

#
# Usage:
#   DNSIMPLE_TOKEN=<token> ./dnslink.sh <domain> <hash>
#
# Example:
#   DNSIMPLE_TOKEN=trustno1 ./dnslink.sh website.protocol.ai Qmfoobar
#
# Dependencies:
# - bash
# - curl
# - jq
#
# From:
#   https://raw.githubusercontent.com/ipfs/infrastructure/master/scripts/dnslink.sh
#

set -e

ACCOUNT=70480

ZONE="$1"
HASH="$2"

([ ! -z "$DNSIMPLE_TOKEN" ] && [ ! -z "$ZONE" ] && [ ! -z "$HASH" ]) \
  || (echo "Usage: DNSIMPLE_TOKEN=<token> ./dnslink.sh <domain> <hash>" && exit 1)

RECORD_NAME="_dnslink"
RECORD_TTL=120

record_id=$(
  curl -s "https://api.dnsimple.com/v2/$ACCOUNT/zones/$ZONE/records?name=$RECORD_NAME&type=TXT" \
    -H "Authorization: Bearer $DNSIMPLE_TOKEN" \
    -H "Accept: application/json" \
    | jq -r '.data | .[] | .id'
)

if [ -z "$record_id" ]; then
  curl -s -X POST "https://api.dnsimple.com/v2/$ACCOUNT/zones/$ZONE/records" \
    -H "Authorization: Bearer $DNSIMPLE_TOKEN" \
    -H "Accept: application/json" \
    -H "Content-Type: application/json" \
    -d "{ \"name\":\"$RECORD_NAME\", \"type\":\"TXT\", \"content\":\"dnslink=/ipfs/$HASH\", \"ttl\":\"$RECORD_TTL\" }" \
      | jq -r '.data' \
      && printf "\\nCreated: It looks like we're good: https://ipfs.io/ipns/$ZONE\\n"
else
  curl -s -X PATCH "https://api.dnsimple.com/v2/$ACCOUNT/zones/$ZONE/records/$record_id" \
    -H "Authorization: Bearer $DNSIMPLE_TOKEN" \
    -H "Accept: application/json" \
    -H "Content-Type: application/json" \
    -d "{ \"content\":\"dnslink=/ipfs/$HASH\", \"ttl\":\"$RECORD_TTL\" }" \
    | jq -r '.data' \
  && printf "\\nUpdated: It looks like we're good: https://ipfs.io/ipns/$ZONE\\n"
fi
