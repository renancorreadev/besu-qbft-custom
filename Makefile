# Makefile para gerenciamento do Hyperledger Besu
.PHONY: help setup start stop status restart reset clean logs check init explorer setup-perms fix

# Variáveis
DOCKER_COMPOSE = docker compose -p blockchain

# Cores para output
GREEN := \033[0;32m
YELLOW := \033[0;33m
RED := \033[0;31m
NC := \033[0m # No Color

help:
	@echo "${YELLOW}Makefile para gerenciamento do Hyperledger Besu${NC}"
	@echo ""
	@echo "${GREEN}Comandos disponíveis:${NC}"
	@echo "  ${YELLOW}make setup${NC}        - Inicializa a rede Besu (executa init.sh)"
	@echo "  ${YELLOW}make start${NC}        - Inicia os containers Besu"
	@echo "  ${YELLOW}make stop${NC}         - Para os containers Besu"
	@echo "  ${YELLOW}make status${NC}       - Verifica o status atual dos containers"
	@echo "  ${YELLOW}make restart${NC}      - Reinicia os containers Besu"
	@echo "  ${YELLOW}make reset${NC}        - Reseta a rede Besu (remove tudo e reconfigura)"
	@echo "  ${YELLOW}make clean${NC}        - Para os containers e remove volumes (⚠️ Cuidado!)"
	@echo "  ${YELLOW}make logs${NC}         - Exibe os logs do bootnode"
	@echo "  ${YELLOW}make check${NC}        - Verifica se a rede está funcionando"
	@echo "  ${YELLOW}make explorer${NC}     - Acessa o explorador da rede"
	@echo "  ${YELLOW}make setup-perms${NC}  - Configura permissões corretas para os arquivos"
	@echo "  ${YELLOW}make fix${NC}          - Corrige a estrutura de arquivos"
	@echo ""
	@echo "${RED}⚠️  Atenção:${NC} Os comandos 'reset' e 'clean' removem todos os dados da blockchain!"

setup:
	@echo "${GREEN}Inicializando a rede Besu...${NC}"
	@mkdir -p ./data
	@chmod +x ./init.sh
	@./init.sh
	@echo "${YELLOW}Verificando se os arquivos necessários foram criados...${NC}"
	@if [ ! -f "./data/genesis.json" ]; then \
		echo "${RED}Erro: Arquivo genesis.json não encontrado!${NC}"; \
		exit 1; \
	fi
	@echo "${GREEN}Inicialização concluída!${NC}"
	@echo "${YELLOW}Para iniciar os containers, use: make start${NC}"

start:
	@echo "${GREEN}Verificando pré-requisitos...${NC}"
	@mkdir -p ./scripts
	@if [ ! -f "./scripts/fix-permissions.sh" ]; then $(MAKE) fix > /dev/null; fi
	@if [ -f "./scripts/fix-permissions.sh" ]; then ./scripts/fix-permissions.sh > /dev/null || exit 1; fi
	@echo "${GREEN}Iniciando containers Besu...${NC}"
	@$(DOCKER_COMPOSE) up -d
	@echo "${GREEN}Containers iniciados. Aguarde alguns instantes até que a rede esteja sincronizada.${NC}"
	@echo "${YELLOW}Para verificar os logs, use: make logs${NC}"

stop:
	@echo "${YELLOW}Parando containers Besu...${NC}"
	@$(DOCKER_COMPOSE) stop
	@echo "${GREEN}Containers parados.${NC}"

status:
	@echo "${GREEN}Verificando status dos containers Besu...${NC}"
	@$(DOCKER_COMPOSE) ps

restart:
	@echo "${YELLOW}Reiniciando containers Besu...${NC}"
	@$(DOCKER_COMPOSE) restart
	@echo "${GREEN}Containers reiniciados.${NC}"

reset:
	@echo "${RED}⚠️ Atenção: Isso removerá TODOS os dados da blockchain!${NC}"
	@read -p "Tem certeza que deseja continuar? (y/n): " confirm && [ $${confirm:-n} = "y" ] || exit 1
	@$(MAKE) clean
	@$(MAKE) setup
	@$(MAKE) start
	@echo "${GREEN}Rede Besu resetada e reiniciada com sucesso!${NC}"

clean:
	@echo "${RED}⚠️ Atenção: Isso removerá TODOS os dados da blockchain!${NC}"
	@read -p "Tem certeza que deseja continuar? (y/n): " confirm && [ $${confirm:-n} = "y" ] || exit 1
	@echo "${YELLOW}Parando containers e removendo volumes...${NC}"
	@$(DOCKER_COMPOSE) down -v
	@echo "${YELLOW}Removendo diretório de dados...${NC}"
	@rm -rf ./data/*
	@echo "${GREEN}Limpeza concluída.${NC}"

logs:
	@echo "${GREEN}Exibindo logs do bootnode (Ctrl+C para sair)...${NC}"
	@$(DOCKER_COMPOSE) logs -f bootnode

check:
	@echo "${GREEN}Verificando se a rede Besu está funcionando...${NC}"
	@curl -s -X POST -H "Content-Type: application/json" --data '{"jsonrpc":"2.0","method":"eth_blockNumber","params":[],"id":1}' http://localhost:8545 | jq || echo "${RED}Erro ao conectar à rede. Verifique se ela está em execução.${NC}"

explorer:
	@echo "${GREEN}O explorador está disponível em: ${YELLOW}http://localhost:80${NC}"
	@echo "${GREEN}Abrindo no navegador padrão...${NC}"
	@open http://localhost:80 2>/dev/null || xdg-open http://localhost:80 2>/dev/null || echo "${YELLOW}Abra manualmente no seu navegador: http://localhost:80${NC}"

setup-perms:
	@echo "${YELLOW}Configurando permissões dos arquivos...${NC}"
	@chmod +x ./init.sh
	@mkdir -p ./data
	@chmod -R 777 ./data 2>/dev/null || true
	@if [ -f "./scripts/fix-permissions.sh" ]; then \
		chmod +x ./scripts/fix-permissions.sh; \
		./scripts/fix-permissions.sh; \
	fi
	@echo "${GREEN}Permissões configuradas.${NC}"

fix:
	@echo "${YELLOW}Tentando corrigir a estrutura de arquivos...${NC}"
	@mkdir -p ./scripts ./data
	@chmod +x ./scripts/fix-permissions.sh
	@./scripts/fix-permissions.sh
	@echo "${GREEN}Correção concluída. Tente iniciar a rede novamente com 'make start'.${NC}" 