# Brew must be installed
# INSTALL BREW: 
#     /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
# ADD BREW TO PATH: 
#    (echo; echo 'eval "$(/opt/homebrew/bin/brew shellenv)"') >> /Users/{Mac Username}/.zprofile
#    eval "$(/opt/homebrew/bin/brew shellenv)"

# Install jq: 
#   brew install jq

GREEN='\033[1;32m'
YELLOW='\033[1;33m'
NC='\033[0m'
TARGET_ORG=""
DEPLOY_PARTNERHUB=false
CHECKPOINT=""
CHECKPOINT_INVALID=true
CHECKPOINT_OPTIONS=("datahub" "carehub" "unpackaged" "after-deployment" "partnerhub")
set -e
while getopts ":o:c:p" opt; do
    case $opt in
        o)
            TARGET_ORG="--target-org $OPTARG"
            ;;
        p)
            DEPLOY_PARTNERHUB=true
            ;;
        c)
            for element in "${CHECKPOINT_OPTIONS[@]}"; do
                if [ "$element" == "$OPTARG" ]; then
                    CHECKPOINT_INVALID=false
                    break
                fi
            done
            if [ "$CHECKPOINT_INVALID" = true ]; then
                echo "Invalid parameter value"
                echo "-c can be only one of datahub, carehub, unpackaged, after-deployment or partnerhub."
                exit
            fi
            if [ "$OPTARG" = "partnerhub" ]; then
                DEPLOY_PARTNERHUB=true
            fi
            CHECKPOINT="$OPTARG"
            ;;
    esac
done
echo "Target Org $TARGET_ORG"
echo "Deploy Partnerhub $DEPLOY_PARTNERHUB"

if [ "$CHECKPOINT" = "" ] || [ "$CHECKPOINT" = "datahub" ]; then
    CHECKPOINT=""
    echo "${YELLOW}Starting DataHub Dry Run${NC}"
    eval "sf project deploy start --source-dir ./source/datahub $TARGET_ORG -c --dry-run"
    echo "${GREEN}DataHub Dry Run Successful${NC}"
    echo

    echo "${YELLOW}Deploying DataHub${NC}"
    eval "sf project deploy start --source-dir ./source/datahub $TARGET_ORG -c"
    echo "${GREEN}DataHub Deployed${NC}"
    echo

    echo "${YELLOW}Assigning DataHub Admin Permission Set${NC}"
    eval "sf org assign permset --name SyntilioDataHubAdmin $TARGET_ORG"
    echo "${GREEN}Permission Set Assigned${NC}"
    echo
fi

if [ "$CHECKPOINT" = "" ] || [ "$CHECKPOINT" = "carehub" ]; then
    CHECKPOINT=""
    echo "${YELLOW}Starting CareHub Pre-Deployment Dry Run${NC}"
    eval "sf project deploy start --source-dir ./source-carehub-pre-deployment $TARGET_ORG -c --dry-run"
    echo "${GREEN}CareHub Pre-Deployment Dry Run Successful${NC}"
    echo

    echo "${YELLOW}Starting CareHub Pre-Deployment${NC}"
    eval "sf project deploy start --source-dir ./source-carehub-pre-deployment $TARGET_ORG -c"
    echo "${GREEN}CareHub Pre-Deployment Successful${NC}"
    echo

    echo "${YELLOW}Starting CareHub Dry Run${NC}"
    eval "sf project deploy start --source-dir ./source/carehub $TARGET_ORG -c --dry-run"
    echo "${GREEN}CareHub Dry Run Successful${NC}"
    echo

    echo "${YELLOW}Deploying CareHub${NC}"
    eval "sf project deploy start --source-dir ./source/carehub $TARGET_ORG -c"
    echo "${GREEN}CareHub Deployed${NC}"
    echo

    echo "${YELLOW}Assigning CareHub Admin Permission Set${NC}"
    eval "sf org assign permset --name SyntilioCareHubAdmin $TARGET_ORG"
    echo "${GREEN}Permission Set Assigned${NC}"
    echo
fi

if [ "$CHECKPOINT" = "" ] || [ "$CHECKPOINT" = "unpackaged" ]; then
    CHECKPOINT=""
    echo "${YELLOW}Starting Unpackaged Dry Run${NC}"
    eval "sf project deploy start --source-dir ./unpackagedsource $TARGET_ORG -c --dry-run"
    echo "${GREEN}Unpackaged Dry Run Successful${NC}"
    echo

    echo "${YELLOW}Deploying Unpackaged${NC}"
    eval "sf project deploy start --source-dir ./unpackagedsource $TARGET_ORG -c"
    echo "${GREEN}Unpackaged Deployed${NC}"
    echo
fi

if [ "$CHECKPOINT" = "" ] || [ "$CHECKPOINT" = "after-deployment" ]; then
    CHECKPOINT=""
    echo "${YELLOW}Starting After Deployment Dry Run${NC}"
    #eval "sf project deploy start --source-dir ./unpackagedsource/datahub-after-deployment $TARGET_ORG -c --dry-run"
    eval "sf project deploy start --source-dir ./unpackagedsource/carehub-after-deployment $TARGET_ORG -c --dry-run"
    echo "${GREEN}After Deployment Dry Run Successful${NC}"
    echo

    echo "${YELLOW}Deploying After Deployment${NC}"
    #eval "sf project deploy start --source-dir ./unpackagedsource/datahub-after-deployment $TARGET_ORG -c"
    eval "sf project deploy start --source-dir ./unpackagedsource/carehub-after-deployment $TARGET_ORG -c"
    echo "${GREEN}After Deployment Deployed${NC}"
    echo
fi

if [ "$DEPLOY_PARTNERHUB" = false ]; then
    exit
fi

if [ "$CHECKPOINT" = "" ] || [ "$CHECKPOINT" = "partnerhub" ]; then
    CHECKPOINT=""
    SITE_QUERY=$(sf data query $TARGET_ORG --query "SELECT Id,Name FROM Site WHERE Name='partnerhub'" --json)
    JSON_SITE=$(jq -r ".result.totalSize" <<< "$SITE_QUERY")

    if [ "$JSON_SITE" = 0 ]; then
        echo "${YELLOW}Creating Site${NC}"
        eval "sf community create --name 'partnerhub' --template-name 'Customer Account Portal' --url-path-prefix partnerhub $TARGET_ORG"
        while [ "$JSON_SITE" = 0 ]; do
            echo "${YELLOW}Checking Site Status${NC}"
            SITE_QUERY=$(sf data query $TARGET_ORG --query "SELECT Id,Name FROM Site WHERE Name='partnerhub'" --json)
            JSON_SITE=$(jq -r ".result.totalSize" <<< "$SITE_QUERY")
            sleep 20 
        done
        echo "${GREEN}Site Created${NC}"
    fi

    echo "${YELLOW}Starting PartnerHub Dry Run${NC}"
    eval "sf project deploy start --source-dir ./digicontactsource/partnerhub $TARGET_ORG -c --dry-run"
    echo "${GREEN}PartnerHub Dry Run Successful${NC}"
    echo

    echo "${YELLOW}Deploying PartnerHub${NC}"
    eval "sf project deploy start --source-dir ./digicontactsource/partnerhub $TARGET_ORG -c"
    echo "${GREEN}PartnerHub Deployed${NC}"
    echo

    echo "${YELLOW}Publishing Site${NC}"
    eval "sf community publish --name 'partnerhub' $TARGET_ORG"
    echo "${GREEN}SitePublished${NC}"
    echo
fi
echo "${GREEN}Source Deployed Successfully${NC} \xF0\x9F\x8E\x89"
exit
