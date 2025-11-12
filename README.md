# DevOps Project - Terraform & Puppet Infrastructure

This project sets up AWS infrastructure using Terraform and manages application deployment using Puppet.

## Project Structure

```
project/
├─ terraform/          # Infrastructure as Code
│  ├─ main.tf         # Main Terraform configuration
│  ├─ variables.tf    # Variable definitions
│  ├─ outputs.tf      # Output definitions
│  ├─ terraform.tfvars.example  # Example variables file
│  └─ bootstrap/      # Bootstrap scripts for EC2 instances
├─ puppet/            # Configuration Management
│  ├─ manifests/
│  │  └─ site.pp      # Main Puppet manifest
│  └─ modules/
│     └─ react_deploy/ # React deployment module
└─ README.md
```

## Prerequisites

- Terraform >= 1.3.0
- AWS Account with appropriate permissions
- AWS CLI configured (optional, for using credentials file)
- SSH key pair named "projectkey" in AWS

## AWS Credentials Setup

**For security, credentials should NOT be hardcoded in the repository.**

### Option 1: Environment Variables (Recommended)

Set the following environment variables:

```bash
# Linux/Mac
export AWS_ACCESS_KEY_ID="your_access_key_id"
export AWS_SECRET_ACCESS_KEY="your_secret_access_key"
export AWS_DEFAULT_REGION="us-east-1"

# Windows PowerShell
$env:AWS_ACCESS_KEY_ID="your_access_key_id"
$env:AWS_SECRET_ACCESS_KEY="your_secret_access_key"
$env:AWS_DEFAULT_REGION="us-east-1"

# Windows CMD
set AWS_ACCESS_KEY_ID=your_access_key_id
set AWS_SECRET_ACCESS_KEY=your_secret_access_key
set AWS_DEFAULT_REGION=us-east-1
```

**Note:** These environment variables are only active in the current terminal session. To make them persistent:

- **Linux/Mac:** Add the `export` commands to `~/.bashrc` or `~/.zshrc`
- **Windows:** Set them as system environment variables via System Properties

**Quick Setup Scripts:** Convenience scripts are available in the `terraform/` directory:

- `setup-env.sh` (Linux/Mac) - Run with `source terraform/setup-env.sh`
- `setup-env.ps1` (PowerShell) - Run with `. .\terraform\setup-env.ps1`
- `setup-env.cmd` (CMD) - Run with `terraform\setup-env.cmd`

**Note:** These setup scripts are gitignored as they contain credentials.

### Option 2: AWS Credentials File

Configure AWS CLI credentials:

```bash
aws configure
```

This creates `~/.aws/credentials` with your credentials.

### Option 3: terraform.tfvars (Less Secure)

1. Copy the example file:

   ```bash
   cp terraform/terraform.tfvars.example terraform/terraform.tfvars
   ```

2. Edit `terraform/terraform.tfvars` with your credentials.

**Note:** `terraform.tfvars` is gitignored and will not be committed to the repository.

## Usage

### Initialize Terraform

```bash
cd terraform
terraform init
```

### Plan Infrastructure

```bash
terraform plan
```

### Apply Infrastructure

```bash
terraform apply
```

### Destroy Infrastructure

```bash
terraform destroy
```

## Infrastructure Components

The Terraform configuration creates:

1. **Puppet Server** - Manages configuration for all nodes
2. **App Node** - Runs Puppet agent and hosts the React application
3. **Nagios Node** - Monitoring server

All instances use:

- AMI: `ami-0c398cb65a93047f2`
- Instance Type: `t3.micro` (configurable)
- Key Pair: `projectkey` (configurable)
- Security Group: Allows SSH (22), HTTP (80), and Puppet (8140)

## Outputs

After applying, Terraform will output the public IPs of:

- Puppet server
- App node
- Nagios node

## Puppet Configuration

The Puppet manifest deploys the **YumYum** React application (https://github.com/GouravSittam/YumYum) using the `react_deploy` module, which:

- Installs Node.js and npm
- Clones the YumYum repository from GitHub
- Installs dependencies using npm
- Builds the application using Parcel (builds to `dist` directory)
- Serves the static build using http-server on port 3000

The YumYum project is a food delivery platform built with React, Redux, and Tailwind CSS. Once deployed, the application will be accessible at `http://<app-node-ip>:3000`.

## Security Notes

- Never commit `terraform.tfvars` or any files containing credentials
- Use environment variables or AWS credentials file for production
- Review and tighten security group rules before production use
- Rotate AWS credentials regularly
