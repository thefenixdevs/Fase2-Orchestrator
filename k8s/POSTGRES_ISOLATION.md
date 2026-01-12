# Isolamento de PostgreSQL por Microserviço

## Visão Geral

Cada microserviço que precisa de banco de dados PostgreSQL possui seu **próprio banco isolado**. **NÃO existe** um PostgreSQL geral/compartilhado no namespace.

## Microserviços com PostgreSQL

### CatalogAPI
- **Banco de Dados**: `catalogdb`
- **Service**: `postgres-catalog-service`
- **Deployment**: `postgres-catalog`
- **PVC**: `postgres-catalog-pvc`
- **Secret**: `catalog-api-secret`
- **Namespace**: `fiap-gamestore`

### UsersAPI
- **Banco de Dados**: `users_db`
- **Service**: `postgres-users-service`
- **Deployment**: `postgres-users`
- **PVC**: `postgres-users-pvc`
- **Secret**: `users-api-secret`
- **Namespace**: `fiap-gamestore`

## Microserviços SEM PostgreSQL

- **PaymentsAPI**: Não usa banco de dados (apenas RabbitMQ)
- **NotificationsAPI**: Não usa banco de dados (apenas RabbitMQ)

## Arquitetura

```
Namespace: fiap-gamestore
├── postgres-catalog (isolado para CatalogAPI)
│   ├── Service: postgres-catalog-service
│   ├── Deployment: postgres-catalog
│   └── PVC: postgres-catalog-pvc
│
├── postgres-users (isolado para UsersAPI)
│   ├── Service: postgres-users-service
│   ├── Deployment: postgres-users
│   └── PVC: postgres-users-pvc
│
└── (NÃO existe postgres geral/compartilhado)
```

## Connection Strings

### CatalogAPI
```
Host=postgres-catalog-service;Port=5432;Database=catalogdb;Username=admin;Password=admin123
```

### UsersAPI
```
Host=postgres-users-service;Port=5432;Database=users_db;Username=postgres;Password=postgres
```

## Verificação

Para verificar o isolamento:

```bash
# Listar apenas os PostgreSQL específicos
kubectl get deployments -n fiap-gamestore | grep postgres
# Deve mostrar apenas: postgres-catalog e postgres-users

# Verificar services
kubectl get services -n fiap-gamestore | grep postgres
# Deve mostrar apenas: postgres-catalog-service e postgres-users-service

# Verificar PVCs
kubectl get pvc -n fiap-gamestore | grep postgres
# Deve mostrar apenas: postgres-catalog-pvc e postgres-users-pvc
```

## Configurações Locais (Desenvolvimento)

As configurações em:
- `Fase2-CatalogAPI/k8s/postgres/` (namespace `catalogapi`)
- `Fase2-UsersAPI/src/k8s/postgres-*.yaml` (namespace `gamestore`)

São **apenas para desenvolvimento local/testes isolados** e **NÃO devem ser usadas em produção**.

Para produção, sempre use as configurações do Orchestrator em `Fase2-Orchestrator/k8s/postgres-*/`.
