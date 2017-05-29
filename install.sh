# -- INSTALL SSL CERT --

# Update machine package indexes
sudo apt-get update

# Open 443 port
sudo ufw allow 443/tcp

# Install Let's Encrypt cli
sudo apt-get install -y letsencrypt

# Obtain SSL CERT
sudo letsencrypt certonly --agree-tos --standalone --email developersworkspace@gmail.com -d "worldofrations.com"

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
sed -i -- "s/yourdomain.com/worldofrations.com/g" /etc/nginx/nginx.conf

# Restart NGINX
systemctl restart nginx
