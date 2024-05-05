#set env vars
set -o allexport; source .env; set +o allexport;

ZEP_AUTH_SECRET=${ZEP_AUTH_SECRET:-`openssl rand -hex 8`}

cat << EOT >> ./.env

ZEP_AUTH_SECRET=${ZEP_AUTH_SECRET}
EOT