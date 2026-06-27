#!/usr/bin/env bash

echo "======================================"
echo " CERTIFICATE STATUS REPORT"
echo "======================================"

check_cert() {
    cert="$1"
    name="$2"

    echo
    echo "--------------------------------------"
    echo "$name"
    echo "File: $cert"
    echo "--------------------------------------"

    if [ ! -f "$cert" ]; then
        echo "[MISSING] Certificate not found"
        return
    fi

    echo "[Subject]"
    openssl x509 -noout -subject -in "$cert"

    echo
    echo "[Issuer]"
    openssl x509 -noout -issuer -in "$cert"

    echo
    echo "[Serial Number]"
    openssl x509 -noout -serial -in "$cert"

    echo
    echo "[Validity]"
    openssl x509 -noout -dates -in "$cert"

    echo
    echo "[Expiration check: 30 days]"
    if openssl x509 -checkend 2592000 -noout -in "$cert"; then
        echo "[OK] Certificate will not expire within 30 days"
    else
        echo "[WARNING] Certificate will expire within 30 days"
    fi
}

check_cert "root-ca/certs/root-ca.cert.pem" "Root CA Certificate"
check_cert "intermediate-ca/certs/intermediate-ca.cert.pem" "Intermediate CA Certificate"
check_cert "leaf-certificates/server.cert.pem" "Server Certificate"
