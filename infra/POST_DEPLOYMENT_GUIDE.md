# Post-Deployment Guide

## After Creating Terraform Instances

### Step 1: Get Instance IP Addresses

Run the following command to get the public IP addresses of your instances:

```bash
terraform output
```

This will display:
- `puppet_public_ip` - IP address of the Puppet Server
- `nagios_public_ip` - IP address of the Nagios Server

Alternatively, you can get individual IPs:
```bash
terraform output puppet_public_ip
terraform output nagios_public_ip
```

### Step 2: Wait for Initialization (Important!)

The user_data scripts install and configure services. **Wait 5-10 minutes** for:
- Software installation (Puppet Server, Nagios Core)
- Service startup
- System configuration

You can monitor the initialization by checking the AWS Console → EC2 → Instance → System Log (console output).

### Step 3: Verify SSH Access

SSH into the instances using your private key file (`projectkey.pem`):

**For Puppet Server:**
```bash
ssh -i projectkey.pem ubuntu@<puppet_public_ip>
```

**For Nagios Server:**
```bash
ssh -i projectkey.pem ubuntu@<nagios_public_ip>
```

**Note:** Make sure your `projectkey.pem` file has correct permissions:
- On Linux/Mac: `chmod 400 projectkey.pem`
- On Windows: Right-click → Properties → Security → Remove all users except yourself

### Step 4: Verify Services are Running

**On Puppet Server:**
```bash
# Check Puppet Server status
sudo systemctl status puppetserver

# Check if Puppet Server is listening on port 8140
sudo netstat -tlnp | grep 8140
# or
sudo ss -tlnp | grep 8140
```

**On Nagios Server:**
```bash
# Check Nagios status
sudo systemctl status nagios

# Check Apache status
sudo systemctl status apache2

# Verify Nagios is running
sudo /usr/local/nagios/bin/nagios -v /usr/local/nagios/etc/nagios.cfg
```

### Step 5: Access Nagios Web Interface

1. Open your web browser
2. Navigate to: `http://<nagios_public_ip>`
3. Login credentials:
   - **Username:** `nagiosadmin`
   - **Password:** `NagiosAdmin123!`

**Important:** Change this default password after first login!

### Step 6: Verify Puppet Server Configuration

**On Puppet Server:**
```bash
# Check Puppet Server certificate
sudo /opt/puppetlabs/bin/puppetserver ca list --all

# Verify Puppet Server configuration
sudo /opt/puppetlabs/bin/puppet config print
```

### Step 7: Configure Firewall (if needed)

The security group already allows:
- Port 22 (SSH) from anywhere
- Port 80 (HTTP) from anywhere (for Nagios)
- Port 8140 (Puppet) from anywhere

If you need to restrict access, modify the security group in `main.tf` or via AWS Console.

### Step 8: Next Steps

#### For Puppet Server:
1. **Sign certificates** for Puppet agents
2. **Create/manage Puppet manifests** for your infrastructure
3. **Configure Puppet agents** on other servers to connect to this Puppet Server

#### For Nagios Server:
1. **Change default password** in Nagios web interface
2. **Configure monitoring targets** (add hosts to monitor)
3. **Set up email/SMS notifications** (configure contact methods)
4. **Create custom service checks** for your infrastructure

### Troubleshooting

#### If services are not running:
```bash
# Check user_data script logs
sudo cat /var/log/cloud-init-output.log

# Check service logs
sudo journalctl -u puppetserver -f  # For Puppet
sudo journalctl -u nagios -f        # For Nagios
```

#### If you can't SSH:
1. Verify security group allows SSH (port 22)
2. Check that your local IP is not blocked
3. Verify the key pair name matches in AWS Console
4. Ensure the private key file (`projectkey.pem`) is in the correct location

#### If Nagios web interface is not accessible:
1. Check if Apache is running: `sudo systemctl status apache2`
2. Check if Nagios is running: `sudo systemctl status nagios`
3. Verify security group allows HTTP (port 80)
4. Check Apache error logs: `sudo tail -f /var/log/apache2/error.log`

### Useful Commands

**Check instance initialization status:**
```bash
# On the instance
sudo cloud-init status
```

**View initialization logs:**
```bash
# On the instance
sudo cat /var/log/cloud-init.log
sudo cat /var/log/cloud-init-output.log
```

**Restart services if needed:**
```bash
# Puppet Server
sudo systemctl restart puppetserver

# Nagios
sudo systemctl restart nagios
sudo systemctl restart apache2
```

### Security Recommendations

1. **Change Nagios default password** immediately
2. **Restrict SSH access** to your IP only (modify security group)
3. **Use AWS Systems Manager Session Manager** as an alternative to SSH
4. **Enable CloudWatch logging** for monitoring
5. **Regular security updates**: `sudo apt update && sudo apt upgrade -y`
6. **Consider using IAM roles** instead of access keys in terraform.tfvars

### Cleanup

To destroy the infrastructure when done:
```bash
terraform destroy
```

**Warning:** This will delete all resources created by Terraform!

