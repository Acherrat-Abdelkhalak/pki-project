# Three-Level Public Key Infrastructure Project

**GitHub Repository:** [https://github.com/Acherrat-Abdelkhalak/pki-project](https://github.com/Acherrat-Abdelkhalak/pki-project)

## Project Title

Mise en place d’une Infrastructure à Clés Publiques PKI à Trois Niveaux

---

## Description

This project implements a three-level Public Key Infrastructure using OpenSSL and Flask.

The infrastructure is composed of:

1. Root CA
2. Intermediate CA
3. Leaf / Server Certificate

The Root CA is self-signed and signs the Intermediate CA.  
The Intermediate CA signs the final server certificate.

---

## Architecture

```text
Root CA
   |
   v
Intermediate CA
   |
   v
Server / Leaf Certificate
```

---

## Technologies Used

- Ubuntu Linux
- OpenSSL
- Python 3
- Flask
- Bash scripts
- Markdown documentation

---

## Main Features

- Generation of RSA private keys.
- Creation of a self-signed Root CA certificate.
- Creation of an Intermediate CA signed by the Root CA.
- Creation of a server certificate signed by the Intermediate CA.
- CSR management.
- Certificate chain verification.
- Certificate revocation.
- CRL generation.
- Simple Flask web interface.
- Security audit.
- Certificate status report.
- Performance test.

---

## Project Structure

```text
pki-project/
├── root-ca/
├── intermediate-ca/
├── leaf-certificates/
├── chain/
├── flask-app/
├── tools/
├── reports/
├── screenshots/
├── documentation/
├── commands.md
└── README.md
```

---

## Running the Flask Interface

```bash
cd ~/pki-project
source venv/bin/activate
cd flask-app
python app.py
```

Then open the browser at:

```text
http://127.0.0.1:5000
```

---

## Advanced Tools

Run the security audit:

```bash
./tools/security_audit.sh
```

Show certificate status:

```bash
./tools/cert_status.sh
```

Run performance test:

```bash
./tools/performance_test.sh 100
```

---

## Security Notes

The private keys of the Root CA and Intermediate CA are encrypted and protected with strict permissions.

Recommended permissions:

```text
private directories: 700
private keys: 400
```

In a real PKI environment, the Root CA private key should be stored offline and never exposed.

---

## Documentation

The main technical report is located in:

```text
documentation/rapport-technique.md
```

The list of commands is located in:

```text
commands.md
```
