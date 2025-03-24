# Deployment Script

This script automates the process of cloning GitHub repositories, setting up a project directory, and deploying it to an EC2 instance. It uses a configuration file (`config.cfg`) to eliminate manual inputs.

## 📌 Prerequisites
- ✅ A valid `.pem` file for SSH access to the EC2 instance.
- ✅ An EC2 instance with Ubuntu and necessary permissions.
- ✅ Git and Node.js installed on both local and remote environments.

## ⚙️ Configuration
Create a `config.cfg` file in the same directory as the script with the following format:

```ini
PEM_FILE=/path/to/key.pem
EC2_IP=your.ec2.ip.address
FOLDER_NAME=company
REPO_URLS=https://github.com/user/repo1.git,https://github.com/user/repo2.git
USE_AWS=false (true if want to upload to server)
```

### **How to Use This Script**

1️⃣ **Give execution permissions**
```bash
chmod +x connect-aws.sh
```

2️⃣ **Run the script**

```bash
./connect-aws.sh
```