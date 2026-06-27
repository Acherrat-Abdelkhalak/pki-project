#!/usr/bin/env bash

echo "======================================"
echo " PKI SECURITY AUDIT"
echo "======================================"
echo

check_permission() {
    path="$1"
    expected="$2"

    if [ ! -e "$path" ]; then
        echo "[MISSING] $path"
        return
    fi

    perm=$(stat -c "%a" "$path")

    if [ "$perm" = "$expected" ]; then
        echo "[OK] $path permissions = $perm"
    else
        echo "[WARNING] $path permissions = $perm, expected $expected"
    fi
}

check_encryption() {
    key="$1"

    if [ ! -f "$key" ]; then
        echo "[MISSING] $key"
        return
    fi

    if grep -q "ENCRYPTED" "$key"; then
        echo "[OK] $key is encrypted"
    else
        echo "[WARNING] $key does not appear to be encrypted"
    fi
}

echo "1. Checking private directories"
check_permission "root-ca/private" "700"
check_permission "intermediate-ca/private" "700"

echo
echo "2. Checking private keys"
check_permission "root-ca/private/root-ca.key.pem" "400"
check_permission "intermediate-ca/private/intermediate-ca.key.pem" "400"
check_permission "leaf-certificates/server.key.pem" "400"

echo
echo "3. Checking encryption of CA private keys"
check_encryption "root-ca/private/root-ca.key.pem"
check_encryption "intermediate-ca/private/intermediate-ca.key.pem"

echo
echo "Recommendation: In a real PKI, the Root CA private key should be stored offline."
