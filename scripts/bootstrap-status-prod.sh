#!/bin/bash
set -euxo pipefail

PROJECT_NAME="${project_name}"
RELEASE_ID="${release_id}"
BUCKET_NAME="${bucket_name}"
ARTIFACT_KEY="${artifact_key}"

LOG_FILE="/var/log/status-bootstrap.log"

exec > >(tee -a "$LOG_FILE") 2>&1

echo "========================================"
echo "Starting status service bootstrap..."
echo "Project: $PROJECT_NAME"
echo "Release: $RELEASE_ID"
echo "========================================"

# --------------------------------------------------
# 1. Install Nginx
# --------------------------------------------------

echo "[1/9] Installing Nginx..."

dnf install -y nginx
dnf install -y unzip
curl -fsSLo /tmp/awscliv2.zip https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip
unzip -q /tmp/awscliv2.zip -d /tmp
/tmp/aws/install
rm -rf /tmp/aws /tmp/awscliv2.zip

echo "Nginx and AWS CLI installation completed successfully."
aws --version

# --------------------------------------------------
# 2. Create application directory
# --------------------------------------------------

echo "[2/9] Creating application directory..."

mkdir -p /usr/share/nginx/html

echo "Application directory created."

# --------------------------------------------------
# 3. Create application page
# --------------------------------------------------

echo "[3/9] Creating application page..."

cat > /usr/share/nginx/html/index.html <<EOF
<html>
<body>
<h1>$${PROJECT_NAME}</h1>
<p>release: $${RELEASE_ID}</p>
</body>
</html>
EOF

echo "Application page created."

# --------------------------------------------------
# 4. Create health endpoint
# --------------------------------------------------

echo "[4/9] Creating health endpoint..."

cat > /usr/share/nginx/html/health <<EOF
status: healthy
release: $${RELEASE_ID}
EOF

echo "Health endpoint created."

# --------------------------------------------------
# 5. Configure Nginx
# --------------------------------------------------

echo "[5/9] Configuring Nginx for port 8080..."

cat > /etc/nginx/conf.d/status.conf <<'EOF'
server {
    listen 8080;
    server_name _;

    root /usr/share/nginx/html;
    index index.html;

    location / {
        try_files $uri $uri/ =404;
    }

    location = /health {
        default_type text/plain;
        try_files /health =404;
    }
}
EOF

echo "Nginx configuration created."

# --------------------------------------------------
# 6. Validate Nginx configuration
# --------------------------------------------------

echo "[6/9] Validating Nginx configuration..."

nginx -t

echo "Nginx configuration is valid."

# --------------------------------------------------
# 7. Enable and start Nginx
# --------------------------------------------------

echo "[7/9] Enabling,start and restarting Nginx..."

mkdir -p /etc/systemd/system/nginx.service.d
printf '[Service]\nRestart=on-failure\nRestartSec=5s\n' \
  > /etc/systemd/system/nginx.service.d/restart.conf
systemctl daemon-reload


systemctl enable nginx
systemctl start nginx

if systemctl is-active --quiet nginx; then
    echo "Nginx is running successfully."
else
    echo "ERROR: Nginx failed to start."
    systemctl status nginx --no-pager
    exit 1
fi

# --------------------------------------------------
# 8. Verify Nginx listener
# --------------------------------------------------

echo "[8/9] Checking Nginx listener on port 8080..."

if ss -lntp | grep -q ':8080'; then
    echo "Nginx is listening on port 8080."
else
    echo "ERROR: Nothing is listening on port 8080."
    exit 1
fi

# --------------------------------------------------
# 9. Download application artifact
# --------------------------------------------------

echo "[9/9] Downloading application artifact..."

if command -v aws >/dev/null 2>&1; then

    if aws s3api get-object \
        --bucket "$BUCKET_NAME" \
        --key "$ARTIFACT_KEY" \
        /tmp/status-artifact.txt
    then
        echo "Application artifact downloaded successfully."
    else
        echo "WARNING: Failed to download application artifact."
    fi

else
    echo "WARNING: AWS CLI is not installed. Skipping artifact download."
fi

# --------------------------------------------------

# --------------------------------------------------
# Periodic application health metric
# --------------------------------------------------

cat > /usr/local/bin/status-health-metric.sh <<'HEALTHCHECK'
#!/bin/bash
set -euo pipefail

if curl -fsS --max-time 5 http://127.0.0.1:8080/health >/dev/null; then
    value=1
else
    value=0
fi

aws cloudwatch put-metric-data \
    --region us-east-1 \
    --namespace terraform-status-lab/prod-lab \
    --metric-name ServiceHealthy \
    --value "$value" \
    --unit Count

echo "Published ServiceHealthy=$value to CloudWatch."
HEALTHCHECK

chmod 0755 /usr/local/bin/status-health-metric.sh

cat > /etc/systemd/system/status-health-metric.service <<'HEALTHSERVICE'
[Unit]
Description=Publish status service health to CloudWatch

[Service]
Type=oneshot
ExecStart=/usr/local/bin/status-health-metric.sh
HEALTHSERVICE

cat > /etc/systemd/system/status-health-metric.timer <<'HEALTHTIMER'
[Unit]
Description=Check status service health every minute

[Timer]
OnBootSec=1min
OnUnitActiveSec=1min
Unit=status-health-metric.service

[Install]
WantedBy=timers.target
HEALTHTIMER

systemctl daemon-reload
systemctl enable --now status-health-metric.timer

# 10. Configure CloudWatch Agent
# --------------------------------------------------

echo "[10/10] Installing and starting CloudWatch Agent..."

case "$(uname -m)" in
    x86_64)  AGENT_ARCH="amd64" ;;
    aarch64) AGENT_ARCH="arm64" ;;
    *)
        echo "ERROR: Unsupported architecture for CloudWatch Agent."
        exit 1
        ;;
esac

curl -fsSLo /tmp/amazon-cloudwatch-agent.rpm \
    "https://amazoncloudwatch-agent.s3.amazonaws.com/amazon_linux/$${AGENT_ARCH}/latest/amazon-cloudwatch-agent.rpm"

dnf install -y /tmp/amazon-cloudwatch-agent.rpm

install -d /opt/aws/amazon-cloudwatch-agent/etc

cat > /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json <<'CWAGENT'
${cloudwatch_agent_config}
CWAGENT

/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
    -a fetch-config \
    -m ec2 \
    -c file:/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json \
    -s

echo "CloudWatch Agent configuration submitted successfully."

# --------------------------------------------------
# Final verification
# --------------------------------------------------

echo "========================================"
echo "Bootstrap completed successfully."
echo "Project: $PROJECT_NAME"
echo "Release: $RELEASE_ID"
echo "Nginx: $(systemctl is-active nginx)"
echo "CloudWatch Agent: configured"
echo "========================================"
