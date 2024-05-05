#set env vars
set -o allexport; source .env; set +o allexport;


SECRET=$(openssl rand -hex 32)

cat << EOT >> ./.env

ZEP_AUTH_SECRET=${SECRET}

EOT

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

chmod +x ./token.sh