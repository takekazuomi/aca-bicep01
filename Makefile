PREFIX_NAME				= omi01
RESOURCE_GROUP				= $(PREFIX_NAME)-rg
LOCATION				= canadacentral
#NAME					= container-apps-$(PREFIX_NAME)
CONTAINERAPPS_NAME			= $(PREFIX_NAME)-container-apps2
ENVIRONMENT_NAME			?= $(shell az resource list -g $(RESOURCE_GROUP) --resource-type Microsoft.App/managedEnvironments --query '[0].name' -o tsv)
#ENVIRONMENT_ID				?= $(shell az resource list -g $(RESOURCE_GROUP) --resource-type Microsoft.App/managedEnvironments --query '[0].id' -o tsv)

#MIN_REPLICAS				= 1
#TRANSPORT				= http2
#ALLOWINSECURE				= false
#SERVER_PORT				= 443
#CONTAINER_PORT				= 8088
#CONTAINER_ONLY				= false

help:			## Show this help.
	@sed -ne '/@sed/!s/## //p' $(MAKEFILE_LIST)

setup: 			## initial setup. only for first time
setup: setup-azcli

setup-azcli:
	az extension show -n containerapp -o none || \
	az extension add --upgrade \
	--source https://workerappscliextension.blob.core.windows.net/azure-cli-extension/containerapp-0.2.2-py2.py3-none-any.whl

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
	containerAppName=$(CONTAINERAPPS_NAME) \
	environmentName=$(ENVIRONMENT_NAME) \
	containerImage=mcr.microsoft.com/azuredocs/containerapps-helloworld:latest \
	containerPort=80

clean:
	az group delete \
	--name $(RESOURCE_GROUP) \
	--location "$(LOCATION)"

env-list:
	@echo $(ENVIRONMENT_ID)
