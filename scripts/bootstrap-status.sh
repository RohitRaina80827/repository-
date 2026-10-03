#!/bin/bash

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

if dnf install -y nginx; then
    echo "Nginx installation completed successfully."
else
    echo "ERROR: Nginx installation failed."
fi

# --------------------------------------------------
# 2. Create application page
# --------------------------------------------------

echo "[2/9] Creating application page..."

mkdir -p /usr/share/nginx/html

cat > /usr/share/nginx/html/index.html <<EOF
<html>
<body>
<h1>$PROJECT_NAME</h1>
<p>release: $RELEASE_ID</p>
</body>
</html>
EOF

echo "Application page created."

# --------------------------------------------------
# 3. Create health endpoint
# --------------------------------------------------

echo "[3/9] Creating health endpoint..."

cat > /usr/share/nginx/html/health <<EOF
status: healthy
release: $RELEASE_ID
EOF

echo "Health endpoint created."

# --------------------------------------------------
# 4. Configure Nginx
# --------------------------------------------------

echo "[4/9] Configuring Nginx for port 8080..."

cat > /etc/nginx/conf.d/status.conf <<EOF
server {
    listen 8080;
    server_name _;

    root /usr/share/nginx/html;
    index index.html;

    location / {
        try_files \$uri \$uri/ =404;
    }

    location = /health {
        default_type text/plain;
        try_files /health =404;
    }
}
EOF

echo "Nginx configuration created."

# --------------------------------------------------
# 5. Validate Nginx configuration
# --------------------------------------------------

echo "[5/9] Validating Nginx configuration..."

if nginx -t; then
    echo "Nginx configuration is valid."
else
    echo "ERROR: Nginx configuration validation failed."
fi

# --------------------------------------------------
# 6. Enable and start Nginx
# --------------------------------------------------

echo "[6/9] Enabling and starting Nginx..."

systemctl enable nginx

if systemctl restart nginx; then
    echo "Nginx restarted successfully."
else
    echo "ERROR: Nginx failed to restart."
    echo "Checking nginx status..."
    systemctl status nginx --no-pager || true
fi

# Verify service state
echo "Nginx service state:"
systemctl is-enabled nginx || true
systemctl is-active nginx || true

# --------------------------------------------------
# 7. Verify Nginx listener
# --------------------------------------------------

echo "[7/9] Checking Nginx listener on port 8080..."

if ss -lntp | grep ':8080'; then
    echo "Nginx is listening on port 8080."
else
    echo "WARNING: Nothing is listening on port 8080."
fi

# --------------------------------------------------
# 8. Ensure SSM agent is running
# --------------------------------------------------

echo "[8/9] Starting SSM agent..."

systemctl enable amazon-ssm-agent

if systemctl restart amazon-ssm-agent; then
    echo "SSM agent restarted successfully."
else
    echo "WARNING: SSM agent failed to restart."
fi

systemctl is-active amazon-ssm-agent || true

# --------------------------------------------------
# 9. Download application artifact
# --------------------------------------------------

echo "[9/9] Downloading application artifact..."

if aws s3api get-object \
    --bucket "$BUCKET_NAME" \
    --key "$ARTIFACT_KEY" \
    /tmp/status-artifact.txt
then
    echo "Application artifact downloaded successfully."
else
    echo "WARNING: Failed to download application artifact."
fi

echo "========================================"
echo "Bootstrap completed."
echo "========================================"

