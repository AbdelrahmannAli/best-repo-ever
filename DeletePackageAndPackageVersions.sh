
packageIds=(0HoQs0000000AAfKAM \
0HoQs00000008f7KAA \
0HoQs00000009PtKAI \
0HoQs00000008tdKAA \
0HoQs00000009WLKAY \
0HoQs00000008VRKAY \
0HoQs0000000ACHKA2 \
0HoQs00000008iLKAQ \
0HoQs00000008gjKAA \
0HoQs00000002OPKAY \
0HoQs00000002Q1KAI \
0HoQs00000008btKAA \
0HoQs00000008wrKAA \
0HoQs0000000905KAA \
0HoQs00000008yTKAQ \
0HoQs000000091hKAA )

for i in "${!packageIds[@]}"; do 
  echo "Deleting package ID: ${packageIds[$i]}"

  packageDeleteResponse=$(sf package delete --target-dev-hub=SyntilioDevHubMyUser --no-prompt --package="${packageIds[$i]}" --json)
  
  if [ "$(jq '.status' <<< "$packageDeleteResponse")" = "1" ]; then
      echo "🐱 Delete failed."

      packageListResponse=$(sf package version list --target-dev-hub=SyntilioDevHubMyUser --packages="${packageIds[$i]}" --json)
      if [ "$(jq '.status' <<< "$packageListResponse")" = "1" ]; then
          echo "🐱 Listing failed."
          exit 1
      fi

      echo "🐱 Listing successful. Now deleting package versions..."
      
      # Loop through the package version results
      subscriberIds=$(jq -r '.result[].SubscriberPackageVersionId' <<< "$packageListResponse")
      for subscriberId in $subscriberIds; do
          echo "Deleting package version ID: $subscriberId"
          versionDeleteResponse=$(sf package version delete --target-dev-hub=SyntilioDevHubMyUser --no-prompt --package="$subscriberId" --json)

          if [ "$(jq '.status' <<< "$versionDeleteResponse")" = "1" ]; then
                echo "🐱 Failed to delete package version ID: $subscriberId."
          else
                echo "🐱 Deleted package version ID: $subscriberId successfully."
          fi
      done
    #echo "Try Deleting again package ID: ${packageIds[$i]}"

    #packageDeleteRetryResponse=$(sf package delete --target-dev-hub=SyntilioDevHubMyUser --no-prompt --package="${packageIds[$i]}" --json)

    #if [ "$(jq '.status' <<< "$packageDeleteRetryResponse")" = "1" ]; then
    #    echo "🐱 Delete failed."
    #else 
    #    echo "🐱 Deleted package successfully after deletion of versions"
    #fi
  fi    
done


