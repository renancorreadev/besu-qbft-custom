#!/bin/bash

BESU_IMAGE="hyperledger/besu:24.9.1"
NETWORK_DIR="./data"


check_error() {
  if [ $? -ne 0 ]; then
    echo "Error: $1"
    exit 1
  fi
}

# Criar diretórios para os nós
echo "Creating directories for nodes..."
mkdir -p "$NETWORK_DIR"
for node in node1 node2 node3 node4; do
    mkdir -p "$NETWORK_DIR/$node/data"
done

# Gerar o arquivo de configuração QBFT
cat <<EOF > "$NETWORK_DIR/qbftConfigFile.json"
{
  "genesis": {
    "config": {
      "chainId": 1337,
      "berlinBlock": 0,
      "qbft": {
        "blockperiodseconds": 4,
        "epochlength": 30000,
        "requesttimeoutseconds": 4
      }
    },
    "nonce": "0x0",
    "timestamp": "0x58ee40ba",
    "gasLimit": "0x47b760",
    "difficulty": "0x1",
    "mixHash": "0x63746963616c2062797a616e74696e65206661756c7420746f6c6572616e6365",
    "coinbase": "0x0000000000000000000000000000000000000000",
    "alloc": {
        "fe3b557e8fb62b89f4916b721be55ceb828dbd73": {
          "privateKey": "8f2a55949038a9610f50fb23b5883af3b4ecb3c3bb792cbcefbd1542c692be63",
          "comment": "private key and this comment are ignored.  In a real chain, the private key should NOT be stored",
          "balance": "0xad78ebc5ac6200000"
        },
        "627306090abaB3A6e1400e9345bC60c78a8BEf57": {
          "privateKey": "c87509a1c067bbde78beb793e6fa76530b6382a4c0241e5e4a9ec0a0f44dc0d3",
          "comment": "private key and this comment are ignored.  In a real chain, the private key should NOT be stored",
          "balance": "90000000000000000000000"
        },
        "f17f52151EbEF6C7334FAD080c5704D77216b732": {
          "privateKey": "ae6ae8e5ccbfb04590405997ee2d52d2b330726137b875053c36d94e974d162f",
          "comment": "private key and this comment are ignored.  In a real chain, the private key should NOT be stored",
          "balance": "90000000000000000000000"
        }
      }
    },
  "blockchain": { "nodes": { "generate": true, "count": 4 } }
}
EOF

# Gerar a configuração do blockchain
echo "Generating blockchain config..."
docker run --rm -v "$(pwd)/$NETWORK_DIR:/network" \
  "$BESU_IMAGE" operator generate-blockchain-config \
  --config-file=/network/qbftConfigFile.json \
  --to=/network/networkFiles \
  --private-key-file-name=key
check_error "Failed to generate blockchain config."

# Copiar o arquivo genesis.json para o diretório principal
cp "$NETWORK_DIR/networkFiles/genesis.json" "$NETWORK_DIR/"

# Distribuir as chaves para cada nó
index=1
for nodeDir in "$NETWORK_DIR/networkFiles/keys/"*; do
    cp "$nodeDir/key"* "$NETWORK_DIR/node$index/data/"
    index=$((index + 1))
done

