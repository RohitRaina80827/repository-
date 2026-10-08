#!/bin/bash

PROJECT_NAME="${project_name}"
RELEASE_ID="${release_id}"
BUCKET_NAME="${bucket_name}"
ARTIFACT_KEY="${artifact_key}"

LOG_FILE="/var/log/status-bootstrap.log"

exec >> "$LOG_FILE" 2>&1

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

echo "Nginx installation completed successfully."

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

echo "[7/9] Enabling and starting Nginx..."

systemctl enable nginx
systemctl start nginx

if systemctl is-active --quiet nginx; then
    echo "Nginx is running successfully."
else
    echo "ERROR: Nginx failed to start."
    systemctl status nginx --no-pager
    exit 1
fi
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

echo "Nginx installation completed successfully."

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

echo "[7/9] Enabling and starting Nginx..."

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
# Final verification
# --------------------------------------------------

echo "========================================"
echo "Bootstrap completed successfully."
echo "Project: $PROJECT_NAME"
echo "Release: $RELEASE_ID"
echo "Nginx: $(systemctl is-active nginx)"
echo "========================================"# --------------------------------------------------
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
# Final verification
# --------------------------------------------------

echo "========================================"
echo "Bootstrap completed successfully."
echo "Project: $PROJECT_NAME"
echo "Release: $RELEASE_ID"
echo "Nginx: $(systemctl is-active nginx)"
echo "========================================"
