#!/bin/bash
RootCAPath="$(pwd)"  # Use current directory for Root CA files (We're assuming you ran copytodrive.sh first!!!

# Create necessary directories
mkdir -p "$RootCAPath/private" "$RootCAPath/rootca"
touch "$RootCAPath/rootca/index.txt"
echo 1000 > "$RootCAPath/rootca/serial"

# Set permissions for private directory
chmod 700 "$RootCAPath/private"

# Generate Root CA private key (4096 bits, encrypted with AES256)
openssl genpkey -algorithm RSA -aes256 -out "$RootCAPath/private/ca.key.pem" -pkeyopt rsa_keygen_bits:4096
chmod 400 "$RootCAPath/private/ca.key.pem"

# Generate Root CA self-signed certificate (valid for 20 years)
openssl req -config <(cat <<EOF
[ req ]
default_bits       = 4096
distinguished_name = req_distinguished_name
prompt             = no
x509_extensions    = v3_ca

[ req_distinguished_name ]
C  = US
ST = State
L  = City
O  = Bing
OU = BingusWorks
CN = FancyPants Offline Root CA

[ v3_ca ]
subjectKeyIdentifier=hash
authorityKeyIdentifier=keyid:always,issuer:always
basicConstraints = critical,CA:true,pathlen:1
keyUsage = critical, digitalSignature, cRLSign, keyCertSign
EOF
) \
    -key "$RootCAPath/private/ca.key.pem" \
    -new -x509 -days 7300 -sha256 -out "$RootCAPath/rootca/ca.cert.pem"
chmod 444 "$RootCAPath/rootca/ca.cert.pem"

# Print completion message
echo "Root CA setup complete. Files stored in $RootCAPath."