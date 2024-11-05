#!/bin/bash

# Define color variables
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

# Define log file path
LOG_FILE="./installCDK.log"

# Logging functions
log_message() {
    local level="$1"
    local message="$2"
    local color="$3"

    # Log to terminal with color
    echo -e "${color}${message}${NC}"

    # Log to file with timestamp and log level
    echo "$(date +'%Y-%m-%d %H:%M:%S') [$level] $message" >> "$LOG_FILE"
}

log_error() {
    local level="$1"
    local message="$2"

    # Log to file with timestamp and log level
    echo "$(date +'%Y-%m-%d %H:%M:%S') [$level] $message" >> "$LOG_FILE"
}

# Parse input arguments for language parameter
language="typescript"  # Default to TypeScript if no language is specified

while [[ "$#" -gt 0 ]]; do
    case $1 in
        --language)
            language="$2"
            shift 2
            ;;
        *)
            log_message "ERROR" "Unknown parameter passed: $1" "$RED"
            exit 1
            ;;
    esac
done

# Check if AWS CLI is installed and check the version
check_aws_cli_installed() {
    echo -e "\n${BLUE}===============================================================${NC}"
    log_message "INFO" "Checking if AWS CLI version 2.18.0 or higher is installed..." "$BLUE"
    echo -e "${BLUE}===============================================================${NC}"
    
    if command -v aws &> /dev/null; then
        installed_version=$(aws --version 2>&1 | awk '{print $1}' | cut -d "/" -f2)
        required_version="2.18.0"

        # Function to compare versions
        cli_version_get() {
            [ "$(printf '%s\n' "$2" "$1" | sort -V | head -n1)" = "$2" ]
        }

        # Check if installed version is 2.18.0 or higher
        if cli_version_get "$installed_version" "$required_version"; then
            log_message "INFO" "AWS CLI version $installed_version is already installed and meets the required version (2.18.0 or higher)." "$GREEN"
            return 0
        else
            log_message "WARNING" "AWS CLI version $installed_version is installed but outdated. Proceeding with update..." "$YELLOW"
            remove_aws_cli
            return 1
        fi
    else
        log_message "WARNING" "AWS CLI is not installed." "$YELLOW"
        return 1
    fi
}

# Remove AWS CLI
remove_aws_cli() {
    echo -e "\n${BLUE}======================================${NC}"
    log_message "INFO" "Removing current AWS CLI version..." "$BLUE"
    echo -e "${BLUE}======================================${NC}"
    sudo rm /usr/local/bin/aws > /dev/null 2>&1
    sudo rm /usr/local/bin/aws_completer > /dev/null 2>&1
    sudo rm -rf /usr/local/aws-cli > /dev/null 2>&1
    log_message "INFO" "AWS CLI removed." "$GREEN"
}

# Install the latest AWS CLI v2
install_aws_cli_v2() {
    echo -e "\n${BLUE}===========================================${NC}"
    log_message "INFO" "Installing latest version of AWS CLI..." "$BLUE"
    echo -e "${BLUE}===========================================${NC}"

    # Download AWS CLI
    cli_response="$(curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" 2>&1)"
    if [ $? -ne 0 ]; then
        log_message "ERROR" "Unable to download AWS CLI. Please ensure that the machine is connected to the internet." "$RED"
        log_error "ERROR" "$cli_response"
        return 1
    else
        log_message "INFO" "AWS CLI package downloaded successfully."
    fi

    # Unzip the AWS CLI package
    unzip_response="$(unzip awscliv2.zip 2>&1)"
    if [ $? -ne 0 ]; then
        log_message "ERROR" "Failed to unzip AWS CLI package." "$RED"
        log_error "ERROR" "$unzip_response"
        rm -rf aws awscliv2.zip
        return 1
    else
        log_message "INFO" "AWS CLI package unzipped successfully."
    fi

    # Install AWS CLI
    install_response="$(sudo ./aws/install 2>&1)"
    if [ $? -ne 0 ]; then
        log_message "ERROR" "Failed to install AWS CLI." "$RED"
        log_error "ERROR" "$install_response"
        rm -rf aws awscliv2.zip
        return 1
    else
        rm -rf aws awscliv2.zip
        installed_version=$(aws --version 2>&1 | cut -d " " -f1 | cut -d "/" -f2)
        log_message "INFO" "AWS CLI version $installed_version installed successfully." "$GREEN"
    fi
}
: '
# Install the latest AWS CLI v2
install_aws_cli_v2() {
    echo -e "\n${BLUE}===========================================${NC}"
    log_message "INFO" "Installing latest version of AWS CLI..." "$BLUE"
    echo -e "${BLUE}===========================================${NC}"
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" > /dev/null 2>&1
    unzip awscliv2.zip > /dev/null 2>&1
    sudo ./aws/install > /dev/null 2>&1
    rm -rf aws awscliv2.zip
    installed_version=$(aws --version 2>&1 | cut -d " " -f1 | cut -d "/" -f2)
    log_message "INFO" "AWS CLI v2 version $installed_version installed successfully." "$GREEN"
}
'

# Install the NodeJS and NVM
install_node_js(){
    echo -e "\n${BLUE}=================================${NC}"
    log_message "INFO" "Installing NodeJS and NVM..." "$BLUE"
    echo -e "${BLUE}=================================${NC}"

    # Ensure NVM_DIR is set and try to load NVM if it exists
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

    if command -v nvm &> /dev/null; then
        log_message "INFO" "NVM is already installed." "$GREEN"
    else
        log_message "WARNING" "NVM is not installed. Installing NVM..." "$YELLOW"
        curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.0/install.sh 2>/dev/null | bash >/dev/null 2>&1
        export NVM_DIR="$HOME/.nvm"
        [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
        [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
        log_message "INFO" "NVM installed successfully." "$GREEN"
    fi
    if command -v node > /dev/null 2>&1 && [ "$(node -v)" == "v20.18.0" ]; then
        log_message "INFO" "Node.js version 20 is already installed." "$GREEN"
    else
        log_message "WARNING" "Node.js version 20 is not installed or outdated. Installing Node.js 20..." "$YELLOW"
        nvm install 20 > /dev/null 2>&1
        nvm use 20 > /dev/null 2>&1
        log_message "INFO" "Node.js version 20 installed successfully." "$GREEN"
    fi
}

# Install the AWS CDK
install_cdk(){
    echo -e "\n${BLUE}=========================${NC}"
    log_message "INFO" "Installing AWS CDK..." "$BLUE"
    echo -e "${BLUE}=========================${NC}"

    # Check if CDK is installed
    if command -v cdk > /dev/null 2>&1; then
        log_message "INFO" "AWS CDK is already installed." "$GREEN"
    else
        npm install -g aws-cdk > /dev/null 2>&1
        log_message "INFO" "AWS CDK installed successfully." "$GREEN"
    fi

    # Install TypeScript or Python CDK setup based on user input
    if [ "$language" == "typescript" ]; then
        echo -e "\n${BLUE}====================================${NC}"
        log_message "INFO" "Setting up TypeScript for CDK..." "$BLUE"
        echo -e "${BLUE}====================================${NC}"

        if command -v tsc > /dev/null 2>&1; then
            log_message "INFO" "TypeScript is already installed." "$GREEN"
        else
            npm install -g typescript > /dev/null 2>&1
            log_message "INFO" "TypeScript setup for CDK completed." "$GREEN"
        fi
    
    elif [ "$language" == "python" ]; then
        echo -e "\n${BLUE}===================================${NC}"
        log_message "INFO" "Setting up Python 3.12.7 for CDK..." "$BLUE"
        echo -e "${BLUE}===================================${NC}"

        if command -v python3.12 &> /dev/null; then
            python_version=$(python3.12 --version 2>&1 | awk '{print $2}')
            required_version="3.12.7"
            
            # Function to compare versions
            python_version_get() {
                [ "$(printf '%s\n' "$2" "$1" | sort -V | head -n1)" = "$2" ]
            }

            # Check if installed version is 3.12.7 or higher
            if python_version_get "$python_version" "$required_version"; then
                log_message "INFO" "Python version 3.12.7 or higher is already installed." "$GREEN"
            else
                log_message "WARNING" "Python version 3.12 is installed but outdated. Proceeding with installation...${NC}" "$YELLOW"
                install_python
            fi
        else
            log_message "WARNING" "Python 3.12 is not installed. Proceeding with installation..." "$YELLOW"
            install_python
        fi
    else
        log_message "ERROR" "Invalid language specified. Please use 'typescript' or 'python'" "$RED"
        exit 1
    fi
}

# Function to install Python 3.12.7
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
    log_message "WARNING" "Configuring and running make command for Python. This could take about 30 minutes to complete..." "$YELLOW"

    # Store the current working directory
    current_directory=$(pwd)

    # Change to the Python source directory
    cd /usr/src/Python-3.12.7 || exit 1

    # Configure, make, and install Python
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

    log_message "INFO" "Python 3.12.7 setup for CDK completed." "$GREEN"
}

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
