#!/bin/bash
# Script to create a new intermediate CA certificate signed by the offline root CA
# Usage: ./issue-intermediate-cert.sh <intermediate_name>

set -e

if [ -z "$1" ]; then
  echo "Usage: $0 <intermediate_name>"
  exit 1
fi

INTERMEDIATE_NAME="$1"
RootCAPath="$(pwd)"  # Assume CA is in the same directory as this script
OUTPUT_DIR="./$INTERMEDIATE_NAME"

mkdir -p "$OUTPUT_DIR"

# Generate intermediate private key
openssl genpkey -algorithm RSA -out "$OUTPUT_DIR/$INTERMEDIATE_NAME.key.pem" -pkeyopt rsa_keygen_bits:4096
chmod 400 "$OUTPUT_DIR/$INTERMEDIATE_NAME.key.pem"

# Generate CSR for intermediate CA
openssl req -new -key "$OUTPUT_DIR/$INTERMEDIATE_NAME.key.pem" -out "$OUTPUT_DIR/$INTERMEDIATE_NAME.csr.pem" -subj "/C=US/ST=State/L=City/O=Homelab/OU=IntermediateCA/CN=$INTERMEDIATE_NAME"

# Create OpenSSL config for intermediate CA extensions
cat > "$OUTPUT_DIR/$INTERMEDIATE_NAME.ext" <<EOF
[ v3_intermediate_ca ]
subjectKeyIdentifier=hash
authorityKeyIdentifier=keyid:always,issuer:always
basicConstraints = critical,CA:true,pathlen:0
keyUsage = critical, digitalSignature, cRLSign, keyCertSign
EOF

# Sign the CSR with the Root CA to create the intermediate CA certificate
openssl x509 -req -in "$OUTPUT_DIR/$INTERMEDIATE_NAME.csr.pem" \
  -CA "$RootCAPath/rootca/ca.cert.pem" -CAkey "$RootCAPath/private/ca.key.pem" \
  -CAcreateserial -out "$OUTPUT_DIR/$INTERMEDIATE_NAME.cert.pem" -days 3650 -sha256 \
  -extfile "$OUTPUT_DIR/$INTERMEDIATE_NAME.ext" -extensions v3_intermediate_ca
chmod 444 "$OUTPUT_DIR/$INTERMEDIATE_NAME.cert.pem"

# Create a full chain PEM (intermediate + root) for Teleport compatibility
cat "$OUTPUT_DIR/$INTERMEDIATE_NAME.cert.pem" "$RootCAPath/rootca/ca.cert.pem" > "$OUTPUT_DIR/$INTERMEDIATE_NAME.chain.pem"
chmod 444 "$OUTPUT_DIR/$INTERMEDIATE_NAME.chain.pem"

# Print completion message
echo "Intermediate CA certificate for $INTERMEDIATE_NAME created in $OUTPUT_DIR."
echo "Full chain PEM for Teleport: $OUTPUT_DIR/$INTERMEDIATE_NAME.chain.pem"
