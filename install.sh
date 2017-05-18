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

# -- BUILD 'world-of-rations-ui' project --

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
docker run -d -p 8084:8084 --name wor-ui -t world-of-rations-ui

# Change to home directory
cd ~

# -- BUILD 'world-of-rations-db' project --

# Clone 'world-of-rations-db' repository
git clone https://github.com/barend-erasmus/world-of-rations-db.git

# Change to cloned directory
cd ./world-of-rations-db

# Build docker image
docker build --no-cache -t world-of-rations-db ./

# Run docker as deamon
docker run -d -p 3306:3306 --name wor-db -e MYSQL_ROOT_PASSWORD=password -e MYSQL_DATABASE=worldofrations -e MYSQL_USER=worldofrations_user -e MYSQL_PASSWORD=worldofrations_password -t world-of-rations-db

# Change to home directory
cd ~

# -- BUILD 'world-of-rations-redis' project --

docker run --name wor-redis -d redis

# -- BUILD 'world-of-rations-service' project --

# Clone 'world-of-rations-service' repository
git clone https://github.com/barend-erasmus/world-of-rations-service.git

# Change to cloned directory
cd ./world-of-rations-service

# Replace domain
sed -i -- "s/yourdomain.com/$domain/g" ./src/config.prod.ts

# Install node packages
npm install

# Build project
npm run build

# Build docker image
docker build --no-cache -t world-of-rations-service ./

# Run docker as deamon
docker run -d -p 8083:8083 --name wor-service -v /logs:/logs --link wor-db:mysql --link wor-redis:redis -t world-of-rations-service

# Change to home directory
cd ~

# -- INSTALL SSL CERT --

# Update machine package indexes
sudo apt-get update

# Open 443 port
sudo ufw allow 443/tcp

# Install Let's Encrypt cli
sudo apt-get install -y letsencrypt

# Obtain SSL CERT
sudo letsencrypt certonly --agree-tos --standalone --email developersworkspace@gmail.com -d "$domain"

# -- INSTALL NGINX --

# Update machine package indexes
sudo apt-get update

# Install NGINX
sudo apt-get install -y nginx

# Add rule to firewall
sudo ufw allow 'Nginx HTTP'

# Download nginx.conf to NGINX directory
curl -o /etc/nginx/nginx.conf https://raw.githubusercontent.com/barend-erasmus/world-of-rations/master/nginx.conf

# Replace domain
sed -i -- "s/yourdomain.com/$domain/g" /etc/nginx/nginx.conf

# Restart NGINX
systemctl restart nginx
