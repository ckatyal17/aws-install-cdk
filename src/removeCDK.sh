#!/bin/bash

# Load NVM if it's installed
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# Function to remove AWS CLI
remove_aws_cli() {
    echo "======================================"
    echo "Removing AWS CLI..."
    echo "======================================"
    if command -v aws; then
        # sudo yum remove awscli -y
        sudo yum remove awscli -y > /dev/null 2>&1
        sudo rm /usr/local/bin/aws
        sudo rm /usr/local/bin/aws_completer
        sudo rm -rf /usr/local/aws-cli
        sudo rm -rf ./aws
        echo "AWS CLI removed."
    else
        echo "AWS CLI is not installed."
    fi
}

# Function to remove AWS CDK
remove_aws_cdk() {
    echo -e "\n======================================"
    echo "Removing AWS CDK..."
    echo "======================================"
    if npm list -g --depth=0 | grep -q aws-cdk; then
        npm uninstall -g aws-cdk
        echo "AWS CDK removed."
    else
        echo "AWS CDK is not installed."
    fi
}

# Function to remove Node.js and NVM
remove_node_js_nvm() {
    echo -e "\n======================================"
    echo "Removing Node.js and NVM..."
    echo "======================================"
    
    # Deactivate nvm (if it's loaded in the current session)
    if command -v nvm &> /dev/null; then
        nvm deactivate
        nvm uninstall 20
        rm -rf "$HOME/.nvm"
        rm -rf "$NVM_DIR"
        export NVM_DIR="$HOME/.nvm"
        [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
        [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
        echo "Node.js and NVM removed."
    else
        echo "NVM is not installed."
    fi
}

# Function to remove Python
remove_python() {
    echo -e "\n======================================"
    echo "Removing Python..."
    echo "======================================"
    
    # Check if Python 3.12 is installed
    if command -v python3.12 &> /dev/null; then
        sudo rm -rf /usr/local/bin/python3.12
        sudo rm -rf /usr/local/bin/python
        sudo rm -rf /usr/local/lib/python3.12
        echo "Python 3.12 removed."
    else
        echo "Python 3.12 is not installed."
    fi
}

# Main script execution
remove_aws_cli
remove_aws_cdk
remove_node_js_nvm
remove_python

echo -e "\n======================================"
echo "Cleanup completed."
echo "======================================"

exec $SHELL
