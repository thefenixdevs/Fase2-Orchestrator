# Docker Compose - Guia de Uso

Este arquivo `docker-compose.yml` orquestra toda a aplicação FIAP Fase 2, incluindo todos os microserviços e infraestrutura necessária.

## Arquitetura

### Microserviços
- **Gateway API** (porta 8000) - Ponto de entrada único para todas as requisições
- **Catalog API** (porta 8080) - Gerenciamento do catálogo de produtos
- **Users API** (porta 5000) - Gerenciamento de usuários
- **Payments API** (porta 8082) - Processamento de pagamentos
- **Notifications API** (worker) - Processamento assíncrono de notificações
- **Auth Service** (porta 3000) - Serviço de autenticação Node.js

### Infraestrutura
- **PostgreSQL Catalog** (porta 5432) - Banco de dados do Catalog API
- **PostgreSQL Users** (porta 5433) - Banco de dados do Users API
- **RabbitMQ** (portas 5672, 15672) - Message broker para comunicação assíncrona
- **Adminer** (porta 8081) - Interface web para gerenciar bancos de dados

## Como Usar

### Iniciar toda a aplicação
```bash
docker-compose up
```

### Iniciar em modo background
```bash
docker-compose up -d
```

### Ver logs de todos os serviços
```bash
docker-compose logs -f
```

### Ver logs de um serviço específico
```bash
docker-compose logs -f gateway-api
docker-compose logs -f catalog-api
docker-compose logs -f users-api
```

### Parar todos os serviços
```bash
docker-compose down
```

### Parar e remover volumes (dados serão perdidos)
```bash
docker-compose down -v
```

### Rebuild de um serviço específico
```bash
docker-compose up --build catalog-api
```

### Rebuild de todos os serviços
```bash
docker-compose up --build
```

## Endpoints Disponíveis

### Gateway API
- **URL**: http://localhost:8000
- **Health Check**: http://localhost:8000/health
- **Descrição**: Ponto de entrada principal que roteia requisições para os microserviços

### Catalog API
- **URL**: http://localhost:8080
- **Health Check**: http://localhost:8080/health
- **Swagger**: http://localhost:8080/swagger

### Users API
- **URL**: http://localhost:5000
- **Health Check**: http://localhost:5000/health
- **Swagger**: http://localhost:5000/swagger

### Payments API
- **URL**: http://localhost:8082

### Auth Service
- **URL**: http://localhost:3000

### RabbitMQ Management
- **URL**: http://localhost:15672
- **Usuário**: guest
- **Senha**: guest

### Adminer (Database UI)
- **URL**: http://localhost:8081
- **Sistema**: PostgreSQL
- **Servers**:
  - Catalog DB: `postgres-catalog`, usuário: `admin`, senha: `admin123`, database: `catalogdb`
  - Users DB: `postgres-users`, usuário: `postgres`, senha: `postgres`, database: `users_db`

## Estrutura de Rede

Todos os serviços estão conectados na rede `fiap-network`, permitindo comunicação interna entre containers usando os nomes dos serviços.

## Volumes Persistentes

Os seguintes volumes são criados para persistir dados:
- `postgres-catalog-data` - Dados do PostgreSQL Catalog
- `postgres-users-data` - Dados do PostgreSQL Users
- `rabbitmq-data` - Dados do RabbitMQ

## Health Checks

Os seguintes serviços possuem health checks configurados:
- PostgreSQL Catalog e Users (verifica conexão)
- RabbitMQ (verifica conectividade)
- Catalog API (curl no endpoint /health)
- Users API (curl no endpoint /health)
- Gateway API (curl no endpoint /health)

## Ordem de Inicialização

O Docker Compose garante a ordem correta de inicialização:
1. PostgreSQL (Catalog e Users) + RabbitMQ
2. Auth Service
3. Catalog API, Users API, Payments API, Notifications API
4. Gateway API (aguarda os demais serviços)
5. Adminer

## Troubleshooting

### Serviço não inicia
```bash
# Ver logs do serviço
docker-compose logs [nome-do-serviço]

# Restart de um serviço específico
docker-compose restart [nome-do-serviço]
```

### Problemas de conexão com banco de dados
```bash
# Verificar se o PostgreSQL está healthy
docker-compose ps

# Forçar recreação dos containers
docker-compose up --force-recreate
```

### Limpar tudo e começar do zero
```bash
# Para e remove containers, networks e volumes
docker-compose down -v

# Remove imagens antigas
docker-compose down --rmi all -v

# Rebuild completo
docker-compose build --no-cache
docker-compose up
```

## Variáveis de Ambiente

As variáveis de ambiente estão configuradas diretamente no docker-compose.yml. Para ambiente de produção, considere usar um arquivo `.env` ou secrets.

## Requisitos

- Docker Engine 20.10+
- Docker Compose 2.0+
- Mínimo 4GB RAM disponível
- Portas disponíveis: 3000, 5000, 5432, 5433, 5672, 8000, 8080, 8081, 8082, 15672

## Notas Importantes

1. **Primeira execução**: A primeira vez pode demorar devido ao download de imagens e build dos serviços
2. **Health checks**: Aguarde os health checks antes de fazer requisições aos serviços
3. **Dados persistentes**: Use `docker-compose down` sem `-v` para manter os dados entre reinicializações
4. **Desenvolvimento**: Este compose é otimizado para ambiente de desenvolvimento local
