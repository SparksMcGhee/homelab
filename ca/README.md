# Homelab Offline Root CA Setup

This folder contains scripts to set up and use an offline Root Certificate Authority (CA) for your homelab. All scripts assume they are run from the same directory and that CA files are stored locally or on a flash drive.

## Scripts

### 1. offline-root-setup.sh
Initializes a new offline Root CA in the current directory.

**Usage:**
```
chmod +x offline-root-setup.sh
./offline-root-setup.sh
```

### 2. issue-host-cert.sh
Generates a new host certificate signed by the Root CA. Takes a single parameter for the DNS/hostname.

**Usage:**
```
chmod +x issue-host-cert.sh
./issue-host-cert.sh <hostname>
```
The certificate and key will be created in a subfolder named after the hostname.

### 3. issue-intermediate-cert.sh
Generates a new intermediate CA certificate signed by the Root CA. Takes a single parameter for the intermediate CA name.

**Usage:**
```
chmod +x issue-intermediate-cert.sh
./issue-intermediate-cert.sh <intermediate_name>
```
The intermediate CA certificate and key will be created in a subfolder named after the intermediate name.

### 4. copytodrive.sh
Copies the contents of the CA folder to a specified flash drive path. Defaults to `/media/sparks/BAA1-3D07/` if no path is given.

**Usage:**
```
chmod +x copytodrive.sh
./copytodrive.sh [destination_path]
```

## Notes
- Make sure to run `chmod +x` on each script before executing.
- Always keep your Root CA private key secure and offline.
- Run these scripts from the directory where they are located.

