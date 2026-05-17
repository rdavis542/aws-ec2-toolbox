#!/bin/bash
set -euxo pipefail

echo "=== AWS Toolbox AMI Build Starting ==="
echo "Base OS: $(grep PRETTY_NAME /etc/os-release | cut -d= -f2)"

# System update
dnf update -y

# Network diagnostics & system tools
# Note: AL2023 uses dnf; nload and telnet not in default repos, use socat/nc instead
dnf install -y \
  jq \
  wget \
  git \
  vim \
  nano \
  tree \
  unzip \
  zip \
  htop \
  iotop \
  lsof \
  strace \
  tcpdump \
  nmap \
  nmap-ncat \
  traceroute \
  mtr \
  bind-utils \
  net-tools \
  iproute \
  iperf3 \
  socat \
  sysstat \
  python3 \
  python3-pip \
  perf

# AWS CLI v2 (AL2023 ships v2 but this ensures latest)
curl -s "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "/tmp/awscliv2.zip"
unzip -q /tmp/awscliv2.zip -d /tmp/
/tmp/aws/install --update
rm -rf /tmp/awscliv2.zip /tmp/aws

# Python AWS SDK
pip3 install --quiet boto3 requests

# CloudWatch Agent
dnf install -y amazon-cloudwatch-agent

# SSM Agent — install, reload unit files, then enable
dnf install -y amazon-ssm-agent
systemctl daemon-reload
systemctl enable amazon-ssm-agent
systemctl start amazon-ssm-agent

# Shell profile with AWS troubleshooting helpers
cat > /etc/profile.d/aws-toolbox.sh << 'PROFILE'
export AWS_DEFAULT_OUTPUT=json

# IMDSv2 helpers
_imds_token() { curl -sf -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600"; }
_imds() { curl -sf -H "X-aws-ec2-metadata-token: $(_imds_token)" "http://169.254.169.254/latest/meta-data/$1"; }

alias myid='_imds instance-id'
alias myip='_imds local-ipv4'
alias mypubip='_imds public-ipv4'
alias myaz='_imds placement/availability-zone'
alias myregion='_imds placement/region'
alias mysgs='_imds security-groups'
alias mymac='_imds mac'
alias myvpc='_imds network/interfaces/macs/$(_imds mac)/vpc-id'
alias mysubnet='_imds network/interfaces/macs/$(_imds mac)/subnet-id'
alias myiam='_imds iam/info'

# Network
alias ports='ss -tlnp'
alias conns='ss -antp'
alias routes='ip route show'
alias arplist='arp -n'
alias dns='cat /etc/resolv.conf'

# Process
alias topmem='ps aux --sort=-%mem | head -15'
alias topcpu='ps aux --sort=-%cpu | head -15'

# AWS resource inspection
check-sg()        { aws ec2 describe-security-groups --group-ids "$1" --output table; }
check-nacl()      { aws ec2 describe-network-acls --filters "Name=vpc-id,Values=$1" --output table; }
check-rt()        { aws ec2 describe-route-tables --filters "Name=vpc-id,Values=$1" --output table; }
check-vpc()       { aws ec2 describe-vpcs --vpc-ids "$1" --output table; }
check-subnet()    { aws ec2 describe-subnets --subnet-ids "$1" --output table; }
check-igw()       { aws ec2 describe-internet-gateways --filters "Name=attachment.vpc-id,Values=$1" --output table; }
check-natgw()     { aws ec2 describe-nat-gateways --filter "Name=vpc-id,Values=$1" --output table; }
check-eni()       { aws ec2 describe-network-interfaces --filters "Name=vpc-id,Values=$1" --output table; }
check-ec2()       { aws ec2 describe-instances --instance-ids "$1" --output table; }
check-elb()       { aws elbv2 describe-load-balancers --output table; }
check-tg()        { aws elbv2 describe-target-groups --output table; }
check-tg-health() { aws elbv2 describe-target-health --target-group-arn "$1" --output table; }
check-s3()        { aws s3 ls "s3://$1" --human-readable; }
check-rds()       { aws rds describe-db-instances --output table; }
check-logs()      { aws logs describe-log-groups --output table; }
check-metrics()   { aws cloudwatch list-metrics --namespace "$1" --output table; }
check-iam-role()  { aws iam get-role --role-name "$1" --output table; aws iam list-attached-role-policies --role-name "$1" --output table; }

# Connectivity helpers
dns-test()  { dig +short "$1"; }
port-test() { nc -zv "$1" "$2" 2>&1; }
http-test() { curl -sIL "$1" | head -30; }
PROFILE

chmod 644 /etc/profile.d/aws-toolbox.sh

# Verify key tools are present
echo "=== Verifying installations ==="
aws --version
python3 --version
jq --version
tcpdump --version 2>&1 | head -1
nmap --version | head -1

echo "=== AWS Toolbox AMI Build Complete ==="
