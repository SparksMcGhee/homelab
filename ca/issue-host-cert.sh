#!/bin/bash
# Script to create a new host certificate signed by the offline root CA
# Usage: ./issuecert.sh <hostname>

set -e

if [ -z "$1" ]; then
  echo "Usage: $0 <hostname>"
  exit 1
fi

HOSTNAME="$1"
RootCAPath="$(pwd)"  # Assume CA is in the same directory as this script
OUTPUT_DIR="./$HOSTNAME"

mkdir -p "$OUTPUT_DIR"

# Generate host private key
openssl genpkey -algorithm RSA -out "$OUTPUT_DIR/$HOSTNAME.key.pem" -pkeyopt rsa_keygen_bits:2048
chmod 400 "$OUTPUT_DIR/$HOSTNAME.key.pem"

# Generate CSR
openssl req -new -key "$OUTPUT_DIR/$HOSTNAME.key.pem" -out "$OUTPUT_DIR/$HOSTNAME.csr.pem" -subj "/C=US/ST=State/L=City/O=Homelab/OU=Hosts/CN=$HOSTNAME"

# Create OpenSSL config for extensions
cat > "$OUTPUT_DIR/$HOSTNAME.ext" <<EOF
[ v3_req ]
subjectAltName = @alt_names
basicConstraints = CA:FALSE
keyUsage = digitalSignature, keyEncipherment
extendedKeyUsage = serverAuth, clientAuth

[ alt_names ]
DNS.1 = $HOSTNAME
EOF

# Sign the CSR with the Root CA
openssl x509 -req -in "$OUTPUT_DIR/$HOSTNAME.csr.pem" \
  -CA "$RootCAPath/rootca/ca.cert.pem" -CAkey "$RootCAPath/private/ca.key.pem" \
  -CAcreateserial -out "$OUTPUT_DIR/$HOSTNAME.cert.pem" -days 825 -sha256 \
  -extfile "$OUTPUT_DIR/$HOSTNAME.ext" -extensions v3_req
chmod 444 "$OUTPUT_DIR/$HOSTNAME.cert.pem"

# Print completion message
echo "Certificate for $HOSTNAME created in $OUTPUT_DIR."