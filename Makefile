PREFIX_NAME				= omi01
RESOURCE_GROUP				= rg-$(PREFIX_NAME)
LOCATION				= japaneast
#NAME					= container-apps-$(PREFIX_NAME)
CONTAINERAPPS_NAME			= aca-$(PREFIX_NAME)
ENVIRONMENT_NAME			?= $(shell az resource list -g $(RESOURCE_GROUP) --resource-type Microsoft.App/managedEnvironments --query '[0].name' -o tsv)
#ENVIRONMENT_ID				?= $(shell az resource list -g $(RESOURCE_GROUP) --resource-type Microsoft.App/managedEnvironments --query '[0].id' -o tsv)
CONTAINERAPPS_ID			?= $(shell az resource list -g $(RESOURCE_GROUP) --resource-type Microsoft.App/containerApps --query '[0].id' -o tsv)

#MIN_REPLICAS				= 1
#TRANSPORT				= http2
#ALLOWINSECURE				= false
#SERVER_PORT				= 443
#CONTAINER_PORT				= 8088
#CONTAINER_ONLY				= false

help:			## Show this help.
	@sed -ne '/@sed/!s/## //p' $(MAKEFILE_LIST)

create-rg:		## create resouce group
	az group create \
	--name $(RESOURCE_GROUP) \
	--location "$(LOCATION)"

deploy-environment:	## deploy environment
	az deployment group create -g $(RESOURCE_GROUP) -f ./deploy-env/main.bicep \
	-p \
	prefixName=$(PREFIX_NAME) \
	-o table

deploy-apps-demo:	## deploy demo app
	az deployment group create -g $(RESOURCE_GROUP) -f ./deploy-app/main.bicep \
	-p \
	containerAppName=$(CONTAINERAPPS_NAME)-demo \
	environmentName=$(ENVIRONMENT_NAME) \
	containerImage=mcr.microsoft.com/azuredocs/containerapps-helloworld:latest \
	containerPort=80

deploy-apps-nginx-demo:	## deploy nginx demo app
	az deployment group create -g $(RESOURCE_GROUP) -f ./deploy-app/main.bicep \
	-p \
	containerAppName=$(CONTAINERAPPS_NAME)-nginx \
	environmentName=$(ENVIRONMENT_NAME) \
	containerImage=nginx \
	containerPort=80

clean:
	az group delete \
	--name $(RESOURCE_GROUP)

env-list:
	@echo $(ENVIRONMENT_NAME)

show-endpoint:
	az rest -u https://management.azure.com$(CONTAINERAPPS_ID)?api-version=2022-01-01-preview | \
	jq -r '.properties.latestRevisionFqdn'
