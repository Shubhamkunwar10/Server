# Skaya Deployment Guide
- This guide explains how to deploy your project using Skaya's automated deployment script with two flexible options:

1. Use Skaya's Custom Frontend & Backend: Deploy our pre-built frontend and backend, then modify the code later as needed.

2. Use Your Own Repositories: Specify custom repositories in the configuration file and deploy your own projects.

## Deployment Script

This script automates the process of cloning GitHub repositories, setting up a project directory, and deploying it to an EC2 instance. It uses a configuration file (`config.cfg`) to eliminate manual inputs.


## 📌 Prerequisites
- ✅ A valid `.pem` file for SSH access to the EC2 instance.
- ✅ An EC2 instance with Ubuntu and necessary permissions.
- ✅ Git and Node.js installed on both local and remote environments.

## ⚙️ Configuration
Create a `config.cfg` file in the same directory as the script with the following format:

```ini
# Required Configuration
PEM_FILE=/path/to/key.pem
EC2_IP=your.ec2.ip.address
FOLDER_NAME=company
USE_AWS=false (true if want to upload to server)
# Repository Configuration
REPO_URLS=https://github.com/skaya-labs/frontend.git,https://github.com/skaya-labs/backend.git
# Environment Configuration
ENVIRONMENT=dev # Options: dev, stage, prod (default: prod)
```
## Using Custom Repositories

### 📂 Repository Requirements
All repositories must contain:
- 1. package.json with these required scripts:
```
{
  "scripts": {
    "build": "...",
    "start": "...",
    "dev": "...",
    "stage": "..."
  }
}
```
- 2. Proper environment variables (via .env or other configuration)

If you prefer to use your own repositories, update the REPO_URLS field with your GitHub repository URLs:

```ini
REPO_URLS=https://github.com/your-org/custom-frontend.git,https://github.com/your-org/custom-backend.git
```

## 📚 Directory Structure

The script ensures that both frontend and backend repositories contain a package.json file with npm build, npm start, and npm run dev commands for proper setup and execution.

## 🔄 .env File Handling

- If a .env file is provided, it is copied into each cloned repository.

- If no .env file is provided, the script continues execution without copying it.

- To skip .env copying, simply press Enter when prompted.

## **Clone the repo**
```bash
git clone https://github.com/skaya-labs/aws-server
cd aws-server
```

### **How to Use This Script**

1️⃣ **Give execution permissions**
```bash
chmod +x connect-aws.sh
chmod 400 your-key.pem  # Ensure PEM file is secure
```

2️⃣ **Run the script**

```bash
./connect-aws.sh
```

The script selects the appropriate branch or environment (dev, prod, or stage) based on the ENVIRONMENT variable in config.cfg. It ensures that the correct configuration is used when running the project.

### Running and starting the aws for server

```bash
ssh -i skaya.pem ec2-user@@your_public_ip_address
```

If permission error:
```bash
chmod 400 skaya.pem
```

### To manually transfer files, use:

```bash
scp -i skaya.pem Projects/Insta-bot/insta-bot.sh ec2-user@your_public_ip_address:~/projects/skaya-labs/
```

scp -i skaya.pem installer.sh ec2-user@yorIpAddres:~/