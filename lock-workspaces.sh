#!/bin/bash
# This script iterates all of the TFE organizations and workspaces and locks them. 

API_TOKEN=$1

organizations=$(curl -s \
  --header "Authorization: Bearer $API_TOKEN" \
  --header "Content-Type: application/vnd.api+json" \
  --request GET \
  https://app.terraform.io/api/v2/organizations | jq -r '.data[].attributes.name')


current_page=0
total_pages=1
workspaces=()

# Iterate Organizations
for org in $organizations
do
    # Iterate all pages and add the workspace IDs to our array
    while [ $current_page -lt $total_pages ]; do
        page=$(curl -s \
        --header "Authorization: Bearer $API_TOKEN" \
        --header "Content-Type: application/vnd.api+json" \
        https://app.terraform.io/api/v2/organizations/$org/workspaces)

        total_pages=$(jq -r '.meta.pagination."total-pages"' <<< "$page")

        workspaces+=$(jq -r '.data[].id' <<< "$page")


        ((current_page++))
        echo "Got Page $current_page of $total_pages for Organization: $org"
    done

    echo "Finished Organization: $org"
done

# Iterate Workspaces and Issue POST Request on /workspaces/id/actions/lock to Lock them
for workspace in $workspaces
do
    resp=$(curl -s \
    --header "Authorization: Bearer $API_TOKEN" \
    --header "Content-Type: application/vnd.api+json" \
    --request POST \
    --data "{\"reason\": \"failover\"}" \
    https://app.terraform.io/api/v2/workspaces/$workspace/actions/lock)

    if [ "$(jq '.errors' <<< "$resp")" = "null" ] ; then
        echo "Locked $workspace"
    else 
        echo "$(jq -r '.errors[0].detail' <<< "$resp") Workspace: $workspace"
    fi
done