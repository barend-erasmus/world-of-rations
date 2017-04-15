# -- BUILD AND INSTALL 'world-of-rations' --

# Declare varibles
domain=$1

# Update machine package indexes
sudo apt-get update

# Download and run script to install node 7
curl -sL https://deb.nodesource.com/setup_7.x | sudo -E bash -

# Install node 7
apt-get install -y nodejs

# Install 'typescript' node package
npm install -g typescript

# Install 'gulp' node package
npm install -g gulp

# Install 'angular-cli' node package
npm install -g @angular/cli

# -- BUILD 'world-of-rations-ui'' project --

# Clone 'world-of-rations-ui' repository
git clone https://github.com/barend-erasmus/world-of-rations-ui.git

# Change to cloned directory
cd ./world-of-rations-ui

# Replace domain
sed -i -- "s/yourdomain.com/$domain/g" ./src/environments/environment.prod.ts

# Install node packages
npm install

# Build project
npm run build

# Build docker image
docker build --no-cache -t world-of-rations-ui ./

# Run docker as deamon
docker run -d -p 8083:8083 -t world-of-rations-ui
