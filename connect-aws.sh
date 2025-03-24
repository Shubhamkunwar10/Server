#!/bin/bash

# @dev Load configuration from file
CONFIG_FILE="./config.cfg"
if [[ ! -f "$CONFIG_FILE" ]]; then
    echo "❌ Error: Configuration file '$CONFIG_FILE' not found."
    exit 1
fi

# @dev Read values from config file
PEM_FILE=$(grep '^PEM_FILE=' "$CONFIG_FILE" | cut -d'=' -f2)
EC2_IP=$(grep '^EC2_IP=' "$CONFIG_FILE" | cut -d'=' -f2)
FOLDER_NAME=$(grep '^FOLDER_NAME=' "$CONFIG_FILE" | cut -d'=' -f2)
USE_AWS=$(grep '^USE_AWS=' "$CONFIG_FILE" | cut -d'=' -f2)

# @dev Fetch repository URLs from config or .gitignore
if grep -q '^REPO_URLS=' "$CONFIG_FILE"; then
    REPO_URLS=($(grep '^REPO_URLS=' "$CONFIG_FILE" | cut -d'=' -f2- | tr ',' ' '))
else
    REPO_URLS=($(grep -Eo 'https?://[^[:space:]]+\.git' .gitignore))
fi

# @user Validate required values
if [[ -z "$FOLDER_NAME" || ${#REPO_URLS[@]} -eq 0 ]]; then
    echo "❌ Error: Missing required configuration values. Check '$CONFIG_FILE'."
    exit 1
fi

# @dev Create the folder locally if it doesn't exist
mkdir -p "$FOLDER_NAME"
echo "📁 Folder '$FOLDER_NAME' is ready."

# @dev Clone or update each repository inside the folder
for REPO_URL in "${REPO_URLS[@]}"; do
    REPO_NAME=$(basename "$REPO_URL" .git)
    REPO_PATH="$FOLDER_NAME/$REPO_NAME"
    
    if [[ -d "$REPO_PATH/.git" ]]; then
        echo "🔄 Repository '$REPO_NAME' exists. Pulling latest changes..."
        git -C "$REPO_PATH" pull > /dev/null 2>&1
    else
        echo "🛠️ Cloning repository '$REPO_NAME'..."
        git clone "$REPO_URL" "$REPO_PATH" > /dev/null 2>&1
    fi
    
    if [[ $? -ne 0 ]]; then
        echo "❌ Error: Failed to process repository '$REPO_NAME'."
        exit 1
    fi

done

echo "✅ All repositories are up to date in '$FOLDER_NAME'."

# @user Prompt for .env file and copy it to each repository
read -p "📂 Please provide the path to your .env file: " ENV_FILE
if [[ ! -f "$ENV_FILE" ]]; then
    echo "❌ Error: Provided .env file does not exist."
    exit 1
fi

for REPO_URL in "${REPO_URLS[@]}"; do
    REPO_NAME=$(basename "$REPO_URL" .git)
    REPO_PATH="$FOLDER_NAME/$REPO_NAME"
    cp "$ENV_FILE" "$REPO_PATH/.env"
    echo "✅ .env file copied to '$REPO_NAME'."
done

if [[ "$USE_AWS" == "true" ]]; then
    # @dev AWS-specific deployment
    if [[ -z "$PEM_FILE" || -z "$EC2_IP" || ! -f "$PEM_FILE" ]]; then
        echo "❌ Error: Missing or invalid AWS configuration. Check '$CONFIG_FILE'."
        exit 1
    fi

    chmod 400 "$PEM_FILE"
    scp -i "$PEM_FILE" -r "$FOLDER_NAME" ubuntu@"$EC2_IP":~/ > /dev/null 2>&1

    if [[ $? -eq 0 ]]; then
        echo "✅ Folder '$FOLDER_NAME' successfully copied to EC2 instance."
    else
        echo "❌ Error: Failed to copy files."
        exit 1
    fi

    ssh -i "$PEM_FILE" ubuntu@"$EC2_IP" << 'EOF'
        PROJECT_DIR="$HOME/company"
        
        for repo in "$PROJECT_DIR"/*; do
            if [[ -d "$repo" && -f "$repo/package.json" ]]; then
                echo "📦 Installing dependencies for $(basename "$repo")..."
                cd "$repo"
                rm -rf node_modules
                npm install > /dev/null 2>&1
                echo "🚀 Starting $(basename "$repo")..."
                npm start > /dev/null 2>&1 &
            fi
        done
        
        echo "✅ All repositories are running!"
EOF

else
    # @dev Local deployment
    for REPO_URL in "${REPO_URLS[@]}"; do
        REPO_NAME=$(basename "$REPO_URL" .git)
        REPO_PATH="$FOLDER_NAME/$REPO_NAME"
        if [[ -d "$REPO_PATH" && -f "$REPO_PATH/package.json" ]]; then
            echo "📦 Installing dependencies for '$REPO_NAME'..."
            cd "$REPO_PATH"
            rm -rf node_modules
            npm install > /dev/null 2>&1
            echo "🚀 Starting '$REPO_NAME'..."
            npm run dev
        fi
    done
    echo "✅ All repositories are running locally!"
fi

echo "🎉 Deployment completed successfully!"
