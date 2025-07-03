# **Guia para Configuração e Execução da Rede Hyperledger Besu**

## **Descrição**

Este guia explica como configurar e executar uma rede privada Hyperledger Besu usando Docker Compose, sem a necessidade de instalar o Besu localmente. Todo o processo de geração de chaves e arquivos de configuração será executado dentro de um container Docker.

---

## **Pré-requisitos**

1. **Docker** instalado.
2. **Docker Compose** instalado.

---

## **Estrutura do Projeto**

A estrutura do projeto deve ser como segue:

```bash
infra/
└── compose/
    └── besu/
        ├── data/
        │   ├── genesis.json  # Será gerado pelo script init.sh
        │   ├── node1/
        │   │   └── data/
        │   ├── node2/
        │   ├── node3/
        │   └── node4/
        ├── docker-compose.yaml
        └── init.sh
```

---

## **Passos para Configuração e Execução**

### 1. **Clone o Repositório ou Estruture o Projeto**

Certifique-se de que o diretório `infra/compose/besu/` contém os seguintes arquivos:

- `init.sh`
- `docker-compose.yaml`

---

### 2. **Executar o Script de Inicialização**

Entre na pasta `infra/compose/besu/` e execute o script:

```bash
cd infra/compose/besu/
chmod +x init.sh
./init.sh
```

O script irá:

- Criar diretórios para cada nó (node1, node2, node3, node4).
- Gerar o arquivo `genesis.json` e as chaves dos nós dentro de um container Docker.
- Copiar as chaves para os diretórios de cada nó.
- Subir os containers da rede Besu automaticamente.

---

## **Verificação dos Arquivos Gerados**

Após a execução do script, a estrutura de arquivos deve ficar assim:

```bash
infra/compose/besu/data/
├── genesis.json
├── node1/data/key
├── node1/data/key.pub
├── node2/data/key
├── node2/data/key.pub
├── node3/data/key
├── node3/data/key.pub
└── node4/data/key
└── node4/data/key.pub
```

---

## **Verificar se os Containers Estão Rodando**

Use o seguinte comando para verificar se os containers estão ativos:

```bash
docker ps
```

Você deve ver algo assim:

```bash
CONTAINER ID   IMAGE                    COMMAND                  PORTS                            NAMES
abcd1234       hyperledger/besu:24.9.1  "/bin/bash -c 'sleep…"   0.0.0.0:8545->8545/tcp, ...      besu_node_1
efgh5678       hyperledger/besu:24.9.1  "/bin/bash -c 'sleep…"   0.0.0.0:8546->8546/tcp, ...      besu_node_2
ijkl9012       hyperledger/besu:24.9.1  "/bin/bash -c 'sleep…"   0.0.0.0:8547->8547/tcp, ...      besu_node_3
mnop3456       hyperledger/besu:24.9.1  "/bin/bash -c 'sleep…"   0.0.0.0:8548->8548/tcp, ...      besu_node_4
```

---

## **Acessar RPC HTTP e WebSocket**

- **RPC HTTP**: `http://localhost:8545`
- **WebSocket**: `ws://localhost:6174`

---

## **Parar os Containers**

Se você precisar parar a rede, use o seguinte comando:

```bash
docker compose down
```

---

## **Conclusão**

Com este guia, você poderá configurar e rodar uma rede privada Hyperledger Besu usando Docker Compose, sem a necessidade de instalar o Besu localmente. Se encontrar problemas, verifique os logs dos containers com:

```bash
docker logs <container_name>
```

Isso ajudará a identificar e resolver quaisquer erros.
