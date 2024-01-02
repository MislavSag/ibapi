# Steps to run plumber API on Azure
1. Create Azure Container Registry registry with command:
```
az acr build --image ibapi:v1 --registry cgsqcwebhook --resource-group Strategies --file Dockerfile .
```
2. Create Azure Container Instance ibeam instance:
```
az container create `
  --resource-group Strategies `
  --name cgspaperexuber `
  --image voyz/ibeam:latest `
  --ports 80 5000 5001 `
  --dns-name-label cgspaperexuber `
  --location eastus `
  --environment-variables IBEAM_ACCOUNT='username' IBEAM_PASSWORD='pass' `
  --restart-policy Never `
  --azure-file-volume-account-name acivolume `
  --azure-file-volume-account-key 'jmcc5PznZr6Mj3IbNPS/nAyZ7p5Kedp8ojPYN7H7cIN8FQ/aFkGwx6jVU8CsmAeLggJUp/OHxV1T+ASt7iB3LA==' `
  --azure-file-volume-share-name acishare `
  --azure-file-volume-mount-path 'inputs/' `
  --cpu 1 `
  --memory 1
```
