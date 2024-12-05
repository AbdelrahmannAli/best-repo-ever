read -p "Enter Scratch Org alias: " scratchOrgAlias
read -p "Enter Dev Hub username: " devHubUsername

sfdx force:org:create -s --definitionfile "./config/carehub-enterprise-project-scratch-def.json" --setalias "$scratchOrgAlias" --durationdays 30 --wait 30 --targetdevhubusername "$devHubUsername"

sf org open

echo "Running script1.sh"
source DeployToScratchOrg.sh
echo "DeployToScratchOrg.sh completed"

echo "Script completed successfully."
