#!/usr/bin/env bash

CERT="leaf-certificates/server.cert.pem"
CHAIN="chain/ca-chain.cert.pem"
N=${1:-100}

echo "======================================"
echo " PKI PERFORMANCE TEST"
echo "======================================"
echo
echo "Test: Certificate chain verification"
echo "Certificate: $CERT"
echo "Iterations: $N"
echo

if [ ! -f "$CERT" ]; then
    echo "[ERROR] Server certificate not found."
    exit 1
fi

if [ ! -f "$CHAIN" ]; then
    echo "[ERROR] Chain file not found."
    exit 1
fi

start=$(date +%s%N)

for i in $(seq 1 "$N"); do
    openssl verify -CAfile "$CHAIN" "$CERT" > /dev/null 2>&1
done

end=$(date +%s%N)

duration_ns=$((end - start))
duration_ms=$((duration_ns / 1000000))

echo "Total time: ${duration_ms} ms"

if [ "$N" -gt 0 ]; then
    avg=$((duration_ms / N))
    echo "Average verification time: ${avg} ms"
fi

echo
echo "Performance test completed."
