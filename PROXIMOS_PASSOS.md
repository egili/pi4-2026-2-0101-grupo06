# 🚀 Guia de Próximos Passos - Cofre de Senhas

Este documento detalha o que precisa ser implementado para que a infraestrutura Docker funcione com o código real.

## 🛠️ 1. Desenvolvimento do Código
Atualmente, a infraestrutura (Docker Compose) está pronta, mas os repositórios precisam de código:

### Back-ends (1 e 2)
- [ ] Criar projeto Java (Sugerido: **Spring Boot**).
- [ ] Configurar o arquivo `pom.xml` (Maven).
- [ ] Garantir que o build gere um arquivo `.jar` na pasta `/target`.
- [ ] Implementar as funcionalidades baseadas nos contratos (`docs/contratos`).

### Front-end
- [ ] Criar projeto Web (Sugerido: **React** ou **Vue.js**).
- [ ] Configurar o `package.json`.
- [ ] Implementar a interface baseada nos fluxos (`docs/fluxos`).

---

## 🌐 2. Configurações de Rede (Docker)
Dentro do ambiente Docker, os serviços não usam `localhost`. Utilize os nomes dos serviços:

| Serviço | URL de Conexão | Observação |
| :--- | :--- | :--- |
| **Banco de Dados** | `jdbc:postgresql://db:5432/vault_db` | Usar no Backend 1 |
| **Backend 2** | `http://backend-2:8081` | Usar no Backend 1 para criptografia |
| **Backend 1** | `http://backend-1:8080` | Usar no Frontend para API |

**Credenciais do Banco:**
- **Usuário:** `user_vault`
- **Senha:** `password_vault`
- **Banco:** `vault_db`

---

## 🗄️ 3. Banco de Dados Automático
**CONFIGURADO:** O `docker-compose.yml` já foi atualizado para mapear a pasta `database` do Backend 1. O Postgres executará automaticamente o `schema.sql` na primeira inicialização.

---

## 🚀 4. Comandos Úteis
Para subir o ambiente:
```bash
cd /home/egili/Documentos/github/pi4-2026-2-0101-grupo06/
docker compose up --build
```

Para derrubar o ambiente:
```bash
docker compose down
```

Para ver os logs do banco:
```bash
docker logs -f vault-db
```
