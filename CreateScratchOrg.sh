RED='\033[1;31m' 
NC='\033[0m'
ORG_NAME=""
ALIAS=""
DEVHUB=""
DEFINITION=""
TEMP_DEFINITION="temp_def.json"
trap 'rm -f "$TEMP_DEFINITION"' EXIT
while getopts ":n:a:d:p:" opt; do
    case $opt in
        n)
            ORG_NAME="$OPTARG"
            ;;
        a)
            ALIAS="$OPTARG"
            ;;
        d)
            DEVHUB="$OPTARG"
            ;;
        p)
            DEFINITION="$OPTARG"
            ;;
    esac
done
if [ -z $ORG_NAME ] || [ -z $DEFINITION ] || [ -z $DEVHUB ]; then
    echo "${RED}Org Name (-n), DevHub (-d) and Definition path (-p) are required${NC}"
    exit 1
fi

COMMAND="sf org create scratch --definition-file $TEMP_DEFINITION --target-dev-hub $DEVHUB --set-default --duration-days 30 -w 30 --json -c"
if [ ! -z $ALIAS ]; then
    COMMAND="$COMMAND --alias $ALIAS"
fi

ORIGINAL_DATA=$(jq . "$DEFINITION")
# Update the field in the copied data (using jq)
UPDATE_DATA=$(echo "$ORIGINAL_DATA" | jq ".orgName = \"$ORG_NAME\"")
# Write the updated data to a new file
echo "$UPDATE_DATA" > "$TEMP_DEFINITION"

eval "$COMMAND"