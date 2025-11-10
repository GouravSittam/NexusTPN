# Terraform Setup Guide

## Fixing Configuration Errors

### Error 1: Invalid CIDR Block

**Error:** `"YOUR_IP_ADDRESS/32" is not a valid CIDR block`

**Solution:** You need to replace `YOUR_IP_ADDRESS` with your actual public IP address.

**Quick Fix:**
1. Run the helper script to get your IP:
   ```powershell
   .\get-my-ip.ps1
   ```
   Or on Linux/Mac:
   ```bash
   chmod +x get-my-ip.sh
   ./get-my-ip.sh
   ```

2. Update `terraform.tfvars`:
   ```hcl
   admin_cidr = "YOUR_ACTUAL_IP/32"
   ```
   Example: `admin_cidr = "203.0.113.4/32"`

**Manual Method:**
- Visit https://whatismyipaddress.com/ to get your IP
- Update `terraform.tfvars` with your IP followed by `/32`

### Error 2: Key Pair Not Found

**Error:** `no matching EC2 Key Pair found`

**Solution:** Create the key pair `INT333` in AWS EC2.

**Steps:**
1. Go to AWS EC2 Console → Key Pairs
2. Click "Create key pair"
3. Name: `INT333`
4. Key pair type: `RSA`
5. Private key file format: `pem` (for Linux/Mac) or `ppk` (for Windows/PuTTY)
6. Click "Create key pair"
7. **Important:** Download and save the private key file securely
8. Make sure you're in the same region (`us-east-1`) as specified in `terraform.tfvars`

**Alternative:** If you already have a key pair with a different name:
- Update `terraform.tfvars`:
  ```hcl
  key_name = "your-existing-key-pair-name"
  ```

## After Fixing

Once both issues are resolved, run:
```powershell
terraform plan
```

If the plan succeeds, you can apply:
```powershell
terraform apply
```

## Security Note

- The `admin_cidr` restricts SSH access to your IP only
- If your IP changes (e.g., different network), update `admin_cidr` accordingly
- For a subnet instead of single IP, use format like `203.0.113.0/24`

