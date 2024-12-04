# AWS CDK Installation Script

This Bash script automates the installation and setup of:
- **AWS CLI** (specifically version 2.18.0 or higher)
- **Node.js** (with version management via NVM, specifically installing version 20 if not already present)
- **AWS CDK** (with optional setup for either TypeScript or Python as the development language)

Additionally, the script checks for existing installations, removes outdated versions as needed, and installs required software from scratch if not detected. Logging and colored terminal messages are incorporated for an enhanced user experience.

## Features
- Checks for an installed AWS CLI and removes outdated versions.
- Installs the latest AWS CLI version 2 if not present or outdated.
- Checks and installs Node.js version 20 via NVM.
- Installs the AWS CDK toolkit and configures it for either **TypeScript** or **Python** development.
- Uses color-coded logging messages for easier readability.
- Writes log entries to `installCDK.log` with timestamps and log levels.

## Usage


- Download or copy the contents of [/src/installCDK.sh](https://github.com/ckatyal17/aws-install-cdk/blob/main/src/installCDK.sh) file on the machine where you want to install AWS CDK.
- After downloading the script, make it executable by running below command:
```bash
chmod +x installCDK.sh
```

### Basic Command
To run the script, execute:
```bash
./installCDK.sh
```


### Optional Parameters
The script accepts an optional `--language` argument to specify the development language for AWS CDK. The default language is **TypeScript**.

#### Examples
```bash
./installCDK.sh --language typescript  # Sets up CDK for TypeScript (default)
./installCDK.sh --language python      # Sets up CDK for Python
```

### Notes

- If the `--language` parameter is not specified, TypeScript will be used by default.
- Supported values for the `--language` argument are **typescript** and **python** only.

## Prerequisites
Ensure you have the following:
- **Root or sudo privileges** to install or remove software.
- **Internet connectivity** to download required files and packages.

## Script Breakdown

### 1. Logging
The script defines a `log_message` and `log_error` function to log both to the console (with color-coded messages) and to a log file (`installCDK.log`). The log messages include timestamps and are categorized by log level (INFO, WARNING, ERROR).

### 2. AWS CLI Check and Installation
- **`check_aws_cli_installed`**: Checks if AWS CLI v2.18.0 or higher is installed.
- **`remove_aws_cli`**: Removes any existing AWS CLI installation if an outdated version is detected.
- **`install_aws_cli_v2`**: Downloads and installs the latest AWS CLI version if it's not already present or outdated.

### 3. Node.js and NVM Installation
- **`install_node_js`**: Installs NVM and Node.js version 20 if not already installed or if an outdated Node.js version is detected.

### 4. AWS CDK and Language Setup
- **`install_cdk`**: Installs the AWS CDK CLI and configures it for the specified development language (TypeScript or Python).
- **`install_python`**: Installs Python 3.12.7 and its required dependencies if Python is selected as the development language and not already available.

### 5. Script Execution Flow
The script first checks if AWS CLI is installed and then proceeds to:
- Install Node.js (via NVM) if not present.
- Install AWS CDK and configure the specified language (either TypeScript or Python).
- Open a new shell instance for the user.

## Logging and Monitoring

To monitor the script's progress in real time:
```bash
tail -f installCDK.log
```

## Troubleshooting

If you encounter any issues:
- Check the `installCDK.log` file for detailed error messages and debugging information.
- Verify internet connectivity and permissions if installations fail.
