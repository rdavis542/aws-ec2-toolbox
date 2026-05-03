# aws-ec2-toolbox

An EC2 instance pre-loaded with AWS troubleshooting utilities, accessed exclusively via AWS Systems Manager Session Manager (no SSH, no public IP).

## What's Installed

### Network Diagnostics
| Tool | Purpose |
|------|---------|
| `nmap` | Port/host scanning |
| `ncat` (netcat) | TCP/UDP connectivity tests |
| `tcpdump` | Packet capture |
| `mtr` | Combined traceroute + ping |
| `traceroute` | Network path tracing |
| `iperf3` | Bandwidth measurement |
| `socat` | Socket relay / proxy testing |
| `nload` | Real-time network traffic |
| `dig` / `nslookup` | DNS resolution |
| `ss` / `netstat` | Open ports and connections |

### System Monitoring
| Tool | Purpose |
|------|---------|
| `htop` | Interactive process viewer |
| `iotop` | Disk I/O per-process |
| `sysstat` | `iostat`, `sar`, `vmstat` |
| `lsof` | Open files and network sockets |
| `strace` | System call tracing |
| `perf` | Performance profiling |

### AWS Tools
| Tool | Purpose |
|------|---------|
| `aws` (CLI v2) | Full AWS CLI for API inspection |
| `boto3` | Python AWS SDK for scripting |

### Shell Aliases (auto-loaded in every session)

**Instance metadata:**
```
myid       # instance ID
myip       # private IP
mypubip    # public IP
myaz       # availability zone
myregion   # region
mysgs      # attached security group names
myvpc      # VPC ID
mysubnet   # subnet ID
myiam      # IAM role info
```

**AWS resource inspection:**
```bash
check-sg       <sg-id>        # describe security group rules
check-nacl     <vpc-id>       # describe network ACLs
check-rt       <vpc-id>       # describe route tables
check-vpc      <vpc-id>       # describe VPC
check-subnet   <subnet-id>    # describe subnet
check-igw      <vpc-id>       # describe internet gateway
check-natgw    <vpc-id>       # describe NAT gateways
check-eni      <vpc-id>       # describe network interfaces
check-ec2      <instance-id>  # describe EC2 instance
check-elb                     # list load balancers
check-tg                      # list target groups
check-tg-health <tg-arn>      # target group health
check-s3       <bucket>       # list S3 bucket contents
check-rds                     # describe RDS instances
check-logs                    # list CloudWatch log groups
check-metrics  <namespace>    # list CloudWatch metrics
check-iam-role <role-name>    # get role and policies
```

**Connectivity tests:**
```bash
dns-test   example.com         # DNS lookup
port-test  10.0.1.5 443        # TCP port check
http-test  https://example.com # HTTP response headers
```

## Architecture

- **Access**: AWS SSM Session Manager only — no inbound security group rules, no SSH key, no public IP
- **IAM**: Read-only access to EC2, VPC, ELB, RDS, S3, CloudWatch, IAM, Route53, Lambda, SSM Parameters, Secrets Manager
- **AMI**: Amazon Linux 2 (latest)
- **Instance type**: `t3.small` (configurable)
- **Storage**: 30 GB gp3, encrypted

## Connecting

```bash
# Get instance ID from Terraform output
terraform -chdir=terraform output instance_id

# Connect via SSM
aws ssm start-session --target <instance-id> --region us-east-1
```

Or use the output directly:
```bash
$(terraform -chdir=terraform output -raw ssm_connect_command)
```

## Deployment

```bash
# Plan
terraform -chdir=terraform init
terraform -chdir=terraform plan --var-file=terraform-toolbox.tfvars

# Apply (or trigger via GitHub Actions workflow_dispatch)
terraform -chdir=terraform apply --var-file=terraform-toolbox.tfvars
```

## GitHub Actions

| Workflow | Trigger | Purpose |
|----------|---------|---------|
| `tf-create.yml` | push/PR to main, workflow_dispatch | Plan on push/PR; apply on workflow_dispatch |
| `tf-destroy.yml` | workflow_dispatch (requires typing "destroy") | Destroy all or targeted resources |
| `tfsec.yml` | push/PR to main, weekly, workflow_dispatch | Security scan with SARIF upload |

### Required Secrets
- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`
