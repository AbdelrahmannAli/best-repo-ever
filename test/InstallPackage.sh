#!/bin/bash
set -x
TIMEOUT=$(( $(date +%s) + 60 * 60 ))
COMMAND_ID=""
PACKAGE_VERSION_ID=""
INSTALLATION_KEY=""
INSTALL_COMMAND=""
while getopts ":i:k" opt; do
    case $opt in
        i)
            PACKAGE_VERSION_ID="$OPTARG"
            ;;
        k)
            INSTALLATION_KEY="$OPTARG"
            ;;
    esac
done

if [ "$INSTALLATION_KEY" = "" ]; then
    INSTALL_COMMAND="sf package install --package \"$PACKAGE_VERSION_ID\" --no-prompt --json"
else
    INSTALL_COMMAND="sf package install --package \"$PACKAGE_VERSION_ID\" --installation-key \"$INSTALLATION_KEY\" --no-prompt --json"
fi

INSTALL_RESULT=$(eval $INSTALL_COMMAND)
STATUS=$(jq -r ".status" <<< "$INSTALL_RESULT")
if [ "$STATUS" != 0 ]; then
    echo "$INSTALL_RESULT"
    exit 1
else
    COMMAND_ID=$(jq -r ".result.Id" <<< "$INSTALL_RESULT")
fi

COMMAND="sf package install report -i \"$COMMAND_ID\" --json"

while [ $(date +%s) -lt $TIMEOUT ]; do
    COMMAND_RESULT=$(eval $COMMAND)
    RESPONSE_JSON=$(echo $COMMAND_RESULT | jq .)
    echo "Check if installed on org: $RESPONSE_JSON"
    STATUS=$(echo $RESPONSE_JSON | jq -r '.status')
    RESULT=$(echo $RESPONSE_JSON | jq -r '.result.Status')

    if [ "$STATUS" -ne 0 ] || [ -z "$RESULT" ]; then
        MESSAGE=$(echo $RESPONSE_JSON | jq -r '.message')
        echo "$MESSAGE"
        exit 1
    fi

    if [ "$RESULT" = "SUCCESS" ]; then
        exit 0
    fi

    sleep 10
done

echo "Installation timed out"
exit 1