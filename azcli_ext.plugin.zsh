delete-rg () {
  az group delete -n "$@" -y --no-wait
}

create-rg () {
  az group create -n "$@" -l eastus
}

list-rg () {
  az group list -otable
}

start-vs-vm() {
  az vm start -n vsdevbox -g visual-studio-rg
}

stop-vs-vm() {
  az vm deallocate -n vsdevbox -g visual-studio-rg
}

list-images-from-offer () {
  az vm image list --offer "$@" --output table --all
}

create-vs-vm () {
  create-rg "visual-studio-rg"
  urn=$(az vm image list --all --offer visualstudio2019latest --query "[?contains(sku, 'vs-2019-comm-latest-win10-n')].{Urn:urn,Version:version} | reverse(sort_by([], &Version)) | [0].Urn" -otsv) 
  az vm create --name vsdevbox --resource-group visual-studio-rg --image $urn --admin-username azureadmin --admin-password "Change Me Later" --data-disk-sizes-gb 512 --nsg-rule RDP
}

create-linux-vm () {
    vname=$1 
    az group create -n ${vname}-rg
    az vm create --name ${vname}-vm --resource-group ${vname}-rg --image UbuntuLTS --admin-username azureadmin
}

stop-vms() {
  az vm deallocate --ids $(az vm list --query "[].id" -o tsv)
}

start-vms() {
  az vm start --ids $(az vm list --query "[].id" -o tsv)
}

 
deploy-sonarqube-as-container() {
  az group create -n sonarqube-1-rg
  azcontainer create -g sonarqube-1-rg --name sonarqci --ports 9000 --dns-name-label sonarqci --cpu 2 --memory 3.5 --image sonarqube
}

get-pwd() {
	< /dev/urandom tr -dc _A-Z-a-z-0-9 | head -c${1:-32};echo;
}

create-aks-cluster() {
	az group create -n ${AZ_GROUP:=aks-lab-rg}
	az aks create -g ${AZ_GROUP} -n aks-lab-cluster --outbound-type loadBalancer -c 1
	az aks get-credentials -g ${AZ_GROUP} -n aks-lab-cluster
}

delete-aks-cluster() {
	az group delete -n ${AZ_GROUP:=aks-lab-rg} -y --no-wait
}

# Machine Learning
create-ml-ws() {
  # install ml extensions if not present
  az extension list -otable --query "[?name=='ml']" | grep ml &>/dev/null || az extension add -n ml

  # Create resource group
	az group create -n ${AZ_NAME:=alejandropacheco-ml-ws}-rg
  
  # Create workspace
  az ml workspace create -n ${AZ_NAME} -g ${AZ_NAME}-rg
}

delete-ml-ws() {
  az group delete -n ${AZ_NAME:=alejandropacheco-ml-ws}-rg -y --no-wait
}

agl () {
	az group list -otable
}
