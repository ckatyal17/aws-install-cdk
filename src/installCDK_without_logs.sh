#!/bin/bash

# Defining color variables
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

# Parse input arguments for language parameter
language="typescript"  # Default to TypeScript if no language is specified

while [[ "$#" -gt 0 ]]; do
    case $1 in
        --language)
            language="$2"
            shift 2
            ;;
        *)
            echo "Unknown parameter passed: $1"
            exit 1
            ;;
    esac
done

# Check if AWS CLI is installed and check the version
check_aws_cli_installed() {
    echo -e "\n${BLUE}===============================================================${NC}"
    echo -e "${BLUE}Checking if AWS CLI version 2.18.0 or higher is installed...${NC}"
    echo -e "${BLUE}===============================================================${NC}"
    if command -v aws &> /dev/null; then
        installed_version=$(aws --version 2>&1 | awk '{print $1}' | cut -d "/" -f2)
        required_version="2.18.0"

        # Function to compare versions
        version_ge() {
            [ "$(printf '%s\n' "$2" "$1" | sort -V | head -n1)" = "$2" ]
        }

        # Check if installed version is 2.18.0 or higher
        if version_ge "$installed_version" "$required_version"; then
            echo -e "${GREEN}AWS CLI version $installed_version is already installed and meets the required version (2.18.0 or higher).${NC}\n"
            return 0
        else
            echo -e "${YELLOW}AWS CLI version $installed_version is installed but outdated. Proceeding with update...${NC}"
            remove_aws_cli
            return 1
        fi
    else
        echo -e "${YELLOW}AWS CLI is not installed.${NC}\n"
        return 1
    fi
}

# Remove AWS CLI
remove_aws_cli() {
    echo -e "\n${BLUE}======================================${NC}"
    echo -e "${BLUE}Removing current AWS CLI version...${NC}"
    echo -e "${BLUE}======================================${NC}"
    sudo rm /usr/local/bin/aws > /dev/null 2>&1
    sudo rm /usr/local/bin/aws_completer > /dev/null 2>&1
    sudo rm -rf /usr/local/aws-cli > /dev/null 2>&1
    echo -e "${GREEN}AWS CLI removed.${NC}"
}

# Install the latest AWS CLI v2
install_aws_cli_v2() {
    echo -e "\n${BLUE}===========================================${NC}"
    echo -e "${BLUE}Installing latest version of AWS CLI...${NC}"
    echo -e "${BLUE}===========================================${NC}"
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" > /dev/null 2>&1
    unzip awscliv2.zip > /dev/null 2>&1
    sudo ./aws/install > /dev/null 2>&1
    rm -rf aws awscliv2.zip
    installed_version=$(aws --version 2>&1 | cut -d " " -f1 | cut -d "/" -f2)
    echo -e "${GREEN}AWS CLI v2 version $installed_version installed successfully.${NC}"
}

# Install the NodeJS and NVM
install_node_js(){
    echo -e "\n${BLUE}=================================${NC}"
    echo -e "${BLUE}Installing NodeJS and NVM...${NC}"
    echo -e "${BLUE}=================================${NC}"

    # Ensure NVM_DIR is set and try to load NVM if it exists
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # Loads nvm if it's already installed
    [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # Loads nvm bash_completion

    if command -v nvm &> /dev/null; then
        echo -e "${GREEN}NVM is already installed.${NC}"
    else
        echo -e "${YELLOW}NVM is not installed. Installing NVM...${NC}"
        curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.0/install.sh 2>/dev/null | bash >/dev/null 2>&1
        export NVM_DIR="$HOME/.nvm"
        [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
        [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
        echo -e "${GREEN}NVM installed successfully.${NC}"
    fi
    if command -v node > /dev/null 2>&1 && [ "$(node -v)" == "v20.18.0" ]; then
        echo -e "${GREEN}Node.js version 20 is already installed.${NC}"
    else
        echo -e "\n${YELLOW}Node.js version 20 is not installed or outdated. Installing Node.js 20...${NC}"
        nvm install 20 > /dev/null 2>&1
        nvm use 20 > /dev/null 2>&1
        echo -e "${GREEN}Node.js version 20 installed successfully.${NC}"
    fi
}

# Install the AWS CDK
install_cdk(){
    echo -e "\n${BLUE}=========================${NC}"
    echo -e "${BLUE}Installing AWS CDK...${NC}"
    echo -e "${BLUE}=========================${NC}"

    # Check if CDK is installed
    if command -v cdk > /dev/null 2>&1; then
        echo -e "${GREEN}AWS CDK is already installed.${NC}"
    else
        echo -e $"{YELLOW}AWS CDK is not installed. Proceeding with installation...${NC}"
        npm install -g aws-cdk > /dev/null 2>&1
        echo -e "${GREEN}AWS CDK installed successfully.${NC}"
    fi

    # Install TypeScript or Python CDK setup based on user input
    if [ "$language" == "typescript" ]; then
        echo -e "\n${BLUE}====================================${NC}"
        echo -e "${BLUE}Setting up TypeScript for CDK...${NC}"
        echo -e "${BLUE}====================================${NC}"
        if command -v tsc > /dev/null 2>&1; then
            echo -e "${GREEN}TypeScript is already installed.${NC}"
        else
            npm install -g typescript > /dev/null 2>&1
            echo -e "${GREEN}TypeScript setup for CDK completed.${NC}"
        fi
    
    elif [ "$language" == "python" ]; then
        # Check if Python 3.12.7 or higher is installed
        python_version=$(python --version 2>&1 | awk '{print $2}')
        required_version="3.12.7"
        echo -e "\n${BLUE}===================================${NC}"
        echo -e "${BLUE}Setting up Python 3.12.7 for CDK...${NC}"
        echo -e "${BLUE}===================================${NC}"

        if command -v python3.12 &> /dev/null; then
            python_version=$(python3.12 --version 2>&1 | awk '{print $2}')
            required_version="3.12.7"
            
            # Function to compare versions
            version_ge() {
                [ "$(printf '%s\n' "$2" "$1" | sort -V | head -n1)" = "$2" ]
            }

            # Check if installed version is 3.12.7 or higher
            if version_ge "$python_version" "$required_version"; then
                echo -e "${GREEN}Python version 3.12.7 or higher is already installed.${NC}"
            else
                echo -e "${YELLOW}Python version 3.12 is installed but outdated. Proceeding with installation...${NC}"
                install_python
            fi
        else
            echo -e "${YELLOW}Python 3.12 is not installed. Proceeding with installation...${NC}"
            install_python
        fi
    else
        echo -e "${RED}Invalid language specified. Please use 'typescript' or 'python'.${NC}"
        exit 1
    fi
}

# Function to install Python 3.12.7
install_python() {
    # Remove old OpenSSL
    sudo yum remove -y openssl openssl-devel > /dev/null 2>&1
    
    # Install development tools and libraries
    sudo yum groupinstall "Development Tools" -y > /dev/null 2>&1

    sudo yum install -y \
        openssl gcc libffi-devel zlib-devel bzip2-devel \
        openssl-devel ncurses-devel sqlite-devel readline-devel \
        tk-devel gdbm-devel libpcap-devel xz-devel expat-devel > /dev/null 2>&1

    # Download and extract Python
    sudo wget http://python.org/ftp/python/3.12.7/Python-3.12.7.tar.xz -O /usr/src/Python-3.12.7.tar.xz > /dev/null 2>&1
    sudo tar -xf /usr/src/Python-3.12.7.tar.xz -C /usr/src > /dev/null 2>&1

    # Store the current working directory
    current_directory=$(pwd)

    # Change to the Python source directory
    cd /usr/src/Python-3.12.7 || exit 1

    # Configure, make, and install Python
    echo -e "${YELLOW}Configuring and running make command for Python. This could take about 30 minutes to complete...${NC}"
    sudo ./configure --enable-optimizations > /dev/null 2>&1
    sudo make -j "$(nproc)" > /dev/null 2>&1
    sudo make altinstall > /dev/null 2>&1

    # Set up pip
    sudo pip3.12 install --upgrade pip > /dev/null 2>&1
    sudo pip3.12 install setuptools > /dev/null 2>&1
    sudo ln -s /usr/local/bin/python3.12 /usr/local/bin/python
    
    # Cleanup and revert to the original directory
    cd "$current_directory"
    sudo rm -rf /usr/src/Python-3.12.7 /usr/src/Python-3.12.7.tar.xz
    
    echo -e "${GREEN}Python 3.12.7 setup for CDK completed.${NC}"
}

: '
# Remove NODEJS and NVM if already installed (Reserved function: Not in use as of now)
remove_node_js_nvm(){
    echo -e "\n${BLUE}======================================${NC}"
    echo -e "${BLUE}Removing current NodeJS and NVM version...${NC}"
    echo -e "${BLUE}======================================${NC}"
    nvm deactivate
    nvm uninstall 20
    rm -rf "$NVM_DIR"
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
    [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
}
'

# Main logic
if check_aws_cli_installed; then
    install_node_js
    install_cdk
    exec $SHELL
else
    install_aws_cli_v2
    install_node_js
    install_cdk
    exec $SHELL
fi
