#set env vars
set -o allexport; source .env; set +o allexport;


SECRET=$(openssl rand -hex 32)

# The variable and its value
VARIABLE="ZEP_AUTH_SECRET"
VALUE="${SECRET}"

# Check if the variable is already in the .env file
if ! grep -q "^${VARIABLE}=" ./.env; then
  # If not found, append it to the .env file
  echo "${VARIABLE}=${VALUE}" >> .env
  echo "Added ${VARIABLE} to .env"
else
  echo "${VARIABLE} already exists in .env"
fi

TOKEN_FILE="./token.sh"

# Check if the token.sh file already exists
if [ ! -f "$TOKEN_FILE" ]; then
   cat << EOT >> ./token.sh
#!/bin/bash
set -o allexport; source .env; set +o allexport;

HEADER='{"alg": "HS256", "typ": "JWT"}'
PAYLOAD='{"username": "admin"}'
ENCODED_HEADER=\$(echo -n "\$HEADER" | base64 | tr -d '=' | tr '/+' '_-')
ENCODED_PAYLOAD=\$(echo -n "\$PAYLOAD" | base64 | tr -d '=' | tr '/+' '_-')
DATA="\$ENCODED_HEADER.\$ENCODED_PAYLOAD"
SIGNATURE=\$(echo -n "\$DATA" | openssl dgst -binary -sha256 -hmac "$SECRET" | base64 | tr -d '=' | tr '/+' '_-')
TOKEN="\$DATA.\$SIGNATURE"

echo "Generated JWT token: \$TOKEN"
EOT
  # Make the token.sh script executable
  chmod +x "$TOKEN_FILE"
  echo "Created and set executable permissions for $TOKEN_FILE"
else
  echo "$TOKEN_FILE already exists"
fi



generate_encrypted_password() {
    local password="$1"
    local salt=$(openssl rand -base64 6)
    local encrypted_password=$(openssl passwd -apr1 -salt "$salt" "$password")
    echo "$encrypted_password"
}

# Path to the .htpasswd file
HTPASSWD_FILE="./.htpasswd"

# Check if the .htpasswd file exists
if [ ! -f "$HTPASSWD_FILE" ]; then
    # If not found, generate the encrypted password and create the .htpasswd file
    encrypted=$(generate_encrypted_password "$ADMIN_PASSWORD")
    echo "Encrypted password: $encrypted"

    cat << EOT >> "$HTPASSWD_FILE"
root:${encrypted}
EOT
    echo "Created $HTPASSWD_FILE with encrypted password for root user."
else
    echo "$HTPASSWD_FILE already exists."
fi
