from flask import Flask, render_template
import subprocess
from pathlib import Path

app = Flask(__name__)

PROJECT_ROOT = Path(__file__).resolve().parent.parent

def run_command(command):
    result = subprocess.run(
        command,
        cwd=PROJECT_ROOT,
        capture_output=True,
        text=True
    )

    output = ""

    if result.stdout:
        output += result.stdout

    if result.stderr:
        output += "\n" + result.stderr

    if not output.strip():
        output = "Command executed successfully."

    return output


@app.route("/")
def index():
    return render_template("index.html")


@app.route("/view-root", methods=["POST"])
def view_root():
    command = [
        "openssl", "x509",
        "-noout", "-text",
        "-in", "root-ca/certs/root-ca.cert.pem"
    ]
    output = run_command(command)
    return render_template("result.html", title="Root CA Certificate", output=output)


@app.route("/view-intermediate", methods=["POST"])
def view_intermediate():
    command = [
        "openssl", "x509",
        "-noout", "-text",
        "-in", "intermediate-ca/certs/intermediate-ca.cert.pem"
    ]
    output = run_command(command)
    return render_template("result.html", title="Intermediate CA Certificate", output=output)


@app.route("/view-server", methods=["POST"])
def view_server():
    command = [
        "openssl", "x509",
        "-noout", "-text",
        "-in", "leaf-certificates/server.cert.pem"
    ]
    output = run_command(command)
    return render_template("result.html", title="Server Certificate", output=output)


@app.route("/verify-chain", methods=["POST"])
def verify_chain():
    command = [
        "openssl", "verify",
        "-CAfile", "chain/ca-chain.cert.pem",
        "leaf-certificates/server.cert.pem"
    ]
    output = run_command(command)
    return render_template("result.html", title="Certificate Chain Verification", output=output)


@app.route("/view-crl", methods=["POST"])
def view_crl():
    command = [
        "openssl", "crl",
        "-in", "intermediate-ca/crl/intermediate-ca.crl.pem",
        "-noout", "-text"
    ]
    output = run_command(command)
    return render_template("result.html", title="Certificate Revocation List", output=output)


@app.route("/verify-crl", methods=["POST"])
def verify_crl():
    command = [
        "openssl", "verify",
        "-crl_check",
        "-CAfile", "chain/ca-chain.cert.pem",
        "-CRLfile", "intermediate-ca/crl/intermediate-ca.crl.pem",
        "leaf-certificates/server.cert.pem"
    ]
    output = run_command(command)
    return render_template("result.html", title="Certificate Verification with CRL", output=output)


@app.route("/view-database", methods=["POST"])
def view_database():
    db_path = PROJECT_ROOT / "intermediate-ca" / "index.txt"

    if db_path.exists():
        output = db_path.read_text()
        if not output.strip():
            output = "The database is empty."
    else:
        output = "index.txt not found."

    return render_template("result.html", title="Intermediate CA Database", output=output)




@app.route("/security-audit", methods=["POST"])
def security_audit():
    command = ["bash", "tools/security_audit.sh"]
    output = run_command(command)
    return render_template("result.html", title="Security Audit", output=output)


@app.route("/certificate-status", methods=["POST"])
def certificate_status():
    command = ["bash", "tools/cert_status.sh"]
    output = run_command(command)
    return render_template("result.html", title="Certificate Status Report", output=output)


@app.route("/performance-test", methods=["POST"])
def performance_test():
    command = ["bash", "tools/performance_test.sh", "100"]
    output = run_command(command)
    return render_template("result.html", title="Performance Test", output=output)


if __name__ == "__main__":
    app.run(debug=True)
