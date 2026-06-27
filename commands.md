# Commands Used in the Three-Level PKI Project

This file contains the main commands used during the implementation of the three-level PKI project.

---

## 1. Environment Setup

```bash
sudo apt update
sudo apt install -y openssl python3-full python3-venv python3-pip tree

python3 -m venv venv
source venv/bin/activate
pip install --upgrade pip
pip install flask
```

---

## 2. Root CA Creation

```bash
mkdir -p root-ca/{certs,crl,newcerts,private}
chmod 700 root-ca/private
touch root-ca/index.txt
echo 1000 > root-ca/serial
echo 1000 > root-ca/crlnumber

openssl genrsa -aes256 -out root-ca/private/root-ca.key.pem 4096
chmod 400 root-ca/private/root-ca.key.pem
```

---

## 3. Root CA Self-Signed Certificate

```bash
openssl req -config root-ca/openssl.cnf \
  -key root-ca/private/root-ca.key.pem \
  -new -x509 -days 3650 -sha256 \
  -extensions v3_ca \
  -out root-ca/certs/root-ca.cert.pem
```

---

## 4. Intermediate CA Creation

```bash
mkdir -p intermediate-ca/{certs,crl,csr,newcerts,private}
chmod 700 intermediate-ca/private
touch intermediate-ca/index.txt
echo 1000 > intermediate-ca/serial
echo 1000 > intermediate-ca/crlnumber

openssl genrsa -aes256 -out intermediate-ca/private/intermediate-ca.key.pem 4096
chmod 400 intermediate-ca/private/intermediate-ca.key.pem
```

---

## 5. Intermediate CA CSR

```bash
openssl req -config intermediate-ca/openssl.cnf \
  -new -sha256 \
  -key intermediate-ca/private/intermediate-ca.key.pem \
  -out intermediate-ca/csr/intermediate-ca.csr.pem
```

---

## 6. Signing Intermediate CA with Root CA

```bash
openssl ca -config root-ca/openssl.cnf \
  -extensions v3_intermediate_ca \
  -days 1825 -notext -md sha256 \
  -in intermediate-ca/csr/intermediate-ca.csr.pem \
  -out intermediate-ca/certs/intermediate-ca.cert.pem

chmod 444 intermediate-ca/certs/intermediate-ca.cert.pem
```

---

## 7. Chain of Trust File

```bash
mkdir -p chain

cat intermediate-ca/certs/intermediate-ca.cert.pem \
    root-ca/certs/root-ca.cert.pem \
    > chain/ca-chain.cert.pem

chmod 444 chain/ca-chain.cert.pem
```

---

## 8. Server / Leaf Certificate Creation

```bash
mkdir -p leaf-certificates

openssl genrsa -out leaf-certificates/server.key.pem 2048
chmod 400 leaf-certificates/server.key.pem

openssl req -new -sha256 \
  -key leaf-certificates/server.key.pem \
  -out leaf-certificates/server.csr.pem \
  -config leaf-certificates/server.cnf
```

---

## 9. Signing Server Certificate with Intermediate CA

```bash
openssl ca -config intermediate-ca/openssl.cnf \
  -extensions server_cert \
  -days 825 -notext -md sha256 \
  -in leaf-certificates/server.csr.pem \
  -out leaf-certificates/server.cert.pem

chmod 444 leaf-certificates/server.cert.pem
```

---

## 10. Chain Verification

```bash
openssl verify -CAfile root-ca/certs/root-ca.cert.pem \
  intermediate-ca/certs/intermediate-ca.cert.pem

openssl verify -CAfile chain/ca-chain.cert.pem \
  leaf-certificates/server.cert.pem
```

---

## 11. Certificate Revocation

```bash
openssl ca -config intermediate-ca/openssl.cnf \
  -revoke leaf-certificates/server.cert.pem
```

---

## 12. CRL Generation

```bash
openssl ca -config intermediate-ca/openssl.cnf \
  -gencrl \
  -out intermediate-ca/crl/intermediate-ca.crl.pem

chmod 444 intermediate-ca/crl/intermediate-ca.crl.pem
```

---

## 13. CRL Verification

```bash
openssl crl -in intermediate-ca/crl/intermediate-ca.crl.pem \
  -noout -text

openssl verify -crl_check \
  -CAfile chain/ca-chain.cert.pem \
  -CRLfile intermediate-ca/crl/intermediate-ca.crl.pem \
  leaf-certificates/server.cert.pem
```

---

## 14. Flask Interface

```bash
cd ~/pki-project
source venv/bin/activate
cd flask-app
python app.py
```

Browser URL:

```text
http://127.0.0.1:5000
```

---

## 15. Advanced Tools

```bash
./tools/security_audit.sh
./tools/cert_status.sh
./tools/performance_test.sh 100
```

---

## 16. Useful Inspection Commands

```bash
tree -L 2

openssl x509 -noout -text -in root-ca/certs/root-ca.cert.pem

openssl x509 -noout -text -in intermediate-ca/certs/intermediate-ca.cert.pem

openssl x509 -noout -text -in leaf-certificates/server.cert.pem

cat intermediate-ca/index.txt
```
