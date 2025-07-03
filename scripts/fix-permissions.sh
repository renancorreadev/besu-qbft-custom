#!/bin/bash

echo "🔧 Corrigindo permissões e estrutura de arquivos para o Besu..."

# Diretório base
BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DATA_DIR="$BASE_DIR/data"

# Criar diretórios se não existirem
mkdir -p "$DATA_DIR"
for node in node1 node2 node3 node4; do
    mkdir -p "$DATA_DIR/$node/data"
done

# Verificar genesis.json
if [ ! -f "$DATA_DIR/genesis.json" ] && [ -f "$DATA_DIR/networkFiles/genesis.json" ]; then
    echo "📄 Copiando genesis.json para o diretório correto..."
    cp "$DATA_DIR/networkFiles/genesis.json" "$DATA_DIR/"
fi

# Se ainda não existir, criar um erro
if [ ! -f "$DATA_DIR/genesis.json" ]; then
    echo "❌ Erro: genesis.json não encontrado!"
    echo "   Execute 'make setup' para inicializar a rede Besu."
    exit 1
fi

# Verificar existência de arquivo log-config.xml
if [ ! -f "$DATA_DIR/log-config.xml" ]; then
    echo "📄 Criando arquivo log-config.xml padrão..."
    cat > "$DATA_DIR/log-config.xml" << LOGXML
<?xml version="1.0" encoding="UTF-8"?>
<Configuration status="INFO">
  <Appenders>
    <Console name="Console" target="SYSTEM_OUT">
      <PatternLayout pattern="%d{yyyy-MM-dd HH:mm:ss.SSS} | %p | %c | %msg%n" />
    </Console>
  </Appenders>
  <Loggers>
    <Root level="INFO">
      <AppenderRef ref="Console" />
    </Root>
  </Loggers>
</Configuration>
LOGXML
fi

# Corrigir permissões
echo "🔒 Ajustando permissões..."
chmod -R 755 "$DATA_DIR"
if [ -f "$DATA_DIR/genesis.json" ]; then
    chmod 644 "$DATA_DIR/genesis.json"
fi
if [ -f "$DATA_DIR/log-config.xml" ]; then
    chmod 644 "$DATA_DIR/log-config.xml"
fi

echo "✅ Verificação e correção concluídas!" 