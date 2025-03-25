Update installers file:
#!/bin/bash

# Update system packages
sudo yum update -y

# Install Git
sudo yum install -y git

# Verify Git installation
git --version

echo "Git installation completed successfully!"

# Install Node.js and npm
sudo yum install -y nodejs

# Verify Node.js and npm installation
node -v
npm -v

echo "Node.js and npm installation completed successfully!"