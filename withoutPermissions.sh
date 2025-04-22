# git clone https://github.com/UCL-VR/ubiq.git

# to get chocolatey

Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

choco install -y git

Import-Module $env:ChocolateyInstall\helpers\chocolateyProfile.psm1

refreshenv

# get the repo on the server

git clone https://github.com/UCL-VR/ubiq.git

# the -y flag is to automatically accept the installation

choco install nodejs -y

choco install npm -y
# if the above doesn't work
msiexec.exe /a https://nodejs.org/dist/v23.7.0/node-v23.7.0-x64.msi /quiet

npm install -g npm@latest

# to get the cert on server
choco install openssl -y

# to setup network security groups to allow the correct access to the ports:
# nsg name can be found on portal under network setttings or view this SO post to get nsg name from terminal https://stackoverflow.com/questions/69654822/get-azure-vms-nsg-using-powershell-cli

az network nsg rule create \
    --resource-group ubiq_server-rg \
    --nsg-name <your-nsg-name> \
    --name Allow8009-8011 \
    --priority 100 \
    --direction Inbound \
    --protocol TCP \
    --source-address-prefixes "*" \
    --destination-port-ranges 8009 8010 8011 \
    --access Allow


