# Sistema de Cofre de Senhas Criptografadas

Sistema cliente-servidor desenvolvido em Java para o gerenciamento, armazenamento seguro e cifragem de credenciais pessoais, garantindo que o servidor central não tenha acesso aos dados em texto claro.

Repositório com a documentação formal do projeto: relatórios de entrega, PDFs, cronogramas e artefatos auxiliares.

## Projeto

Sistema cliente-servidor de cofre digital que armazena credenciais de forma segura. Toda a criptografia ocorre no cliente; o servidor recebe apenas dados cifrados e nunca acessa a senha mestra.

## Repositórios do projeto

| Módulo | Repositório | Responsável |
|---|---|---|
| Front-end (Cliente) | [pi4-0101-g6-frontend](https://github.com/egili/pi4-0101-g6-frontend) | Guilherme Heron|
| Back-end 1 (Servidor) | [pi4-0101-g6-backend-1](https://github.com/egili/pi4-0101-g6-backend-1) | Eliseu Gili |
| Back-end 2 (Módulo de Criptografia) | [pi4-0101-g6-backend-2](https://github.com/egili/pi4-0101-g6-backend-2) | Leonardo Maciel |
| Documentos | este repositório | Pietra Bortolato |

## Como Executar o Sistema (Docker Compose)

O sistema foi arquitetado para ser inicializado de forma automatizada e reproduzível através do Docker Compose, permitindo subir todo o ecossistema com um único comando em uma máquina limpa.

### 1. Pré-requisitos
* **Docker** e **Docker Compose** instalados (versão 20.10+ ou Docker Desktop).
* Portas de rede livres no host: `3000` (Front-end Web), `5432` (PostgreSQL), `8080` (Back-end 1) e `8081` (Back-end 2).
* Todos os 4 repositórios do projeto clonados no mesmo diretório pai:
  ```text
  repositorios/
  ├── pi4-2026-2-0101-grupo06/   (este repositório com o docker-compose.yml)
  ├── pi4-0101-g6-frontend/       (código do Front-end / Cliente Web)
  ├── pi4-0101-g6-backend-1/      (código do Servidor Central e banco)
  └── pi4-0101-g6-backend-2/      (código do Módulo de Criptografia)
  ```

### 2. Passo a Passo para Subir em Máquina Limpa

1. Abra um terminal e acerte o diretório até a pasta deste repositório:
   ```bash
   cd pi4-2026-2-0101-grupo06
   ```

2. Execute o comando para construir as imagens e iniciar todos os serviços em segundo plano:
   ```bash
   docker compose up --build -d
   ```

3. Aguarde o término do processo de build e inicialização dos serviços. O Docker Compose cuidará da compilação e da ordem de dependências automaticamente.

### 3. Os 4 Contêineres do Ecossistema

O `docker-compose.yml` orquestra e inicializa os 4 contêineres essenciais do sistema:

| Contêiner | Serviço | Descrição | Porta Mapeada |
|---|---|---|---|
| `vault-db` | `db` | Banco de dados PostgreSQL 15. Executa automaticamente o script de inicialização DDL (`schema.sql`) na primeira subida, criando as tabelas `usuario` (CT9) e `credencial` (CT10). | `5432:5432` |
| `vault-backend-1` | `backend-1` | Servidor Central em Java / Spring Boot. Recebe os pedidos do Cliente por socket TCP, com uma thread por conexão. Autenticação por tokens JWT; gerencia o cofre sem acesso a senhas ou dados em texto claro. | `8090:8090` |
| `vault-backend-2` | `backend-2` | Módulo de Criptografia em Java / Spring Boot. Biblioteca e serviço local que executa a derivação de chaves (PBKDF2) e cifragem simétrica (AES-GCM). | `8081:8081` |
| `vault-frontend` | `frontend` | Servidor da Interface do Usuário (Cliente Web) em Node.js / HTML / CSS / JS. Serve a aplicação web para os navegadores. | `3000:3000` |

### 4. Verificação e Comandos Úteis

* **Verificar o status dos contêineres:**
  ```bash
  docker compose ps
  ```
  Todos os 4 contêineres devem exibir o status `Up` ou `running`.

* **Visualizar logs em tempo real:**
  ```bash
  docker compose logs -f
  ```
  Para filtrar os logs de um contêiner específico (ex: front-end ou servidor central):
  ```bash
  docker compose logs -f frontend
  docker compose logs -f backend-1
  ```

* **Parar todo o sistema:**
  ```bash
  docker compose down
  ```
  *(Para resetar também os dados persistidos no banco de dados, utilize `docker compose down -v`).*

---

## Acesso e Uso do Cliente / Front-end Web

Com os contêineres ativos, a interface web do Cofre Digital está pronta para acesso direto via navegador.

### 1. Acesso no Navegador
Abra o navegador web de sua preferência e acesse o endereço padrão:
> **[http://localhost:3000](http://localhost:3000)**

### 2. Fluxo de Navegação e Operação

1. **Tela de Login e Desbloqueio (`index.html`):**
   * Ponto de entrada padrão da aplicação em `http://localhost:3000`.
   * Permite informar o nome de usuário e a senha mestra para desbloquear o cofre.

2. **Cadastro de Usuário (`registro.html`):**
   * Em uma instalação inicial ou máquina limpa, clique no link **"Registrar"** (ou acesse diretamente `http://localhost:3000/registro.html`).
   * Informe o nome de usuário desejado e a senha mestra. O cliente gera o `salt` e deriva o hash de autenticação localmente antes de registrar o usuário no servidor.

3. **Painel do Cofre de Senhas (`cofre.html`):**
   * Após o login, o cofre é desbloqueado e a sessão ativa fica disponível em memória.
   * **Salvar Nova Credencial (`+Conta`):** Clique no botão **`+Conta`** para abrir o modal interativo seguro. Digite o nome do serviço (ex: *Gmail*, *GitHub*), o usuário/login e a senha. A digitação da senha é mascarada visualmente por padrão e a cifragem com AES-GCM ocorre localmente no processo do cliente antes do envio e persistência no servidor.
   * **Ferramentas Integradas:** Na barra lateral de ferramentas, é possível utilizar o **Gerador de Senhas**, alterar a senha mestra ou realizar operações de **Backup e Restauração** criptografada.
   * **Bloquear Cofre:** Clique em "Bloquear Cofre" para encerrar a sessão e retornar à tela inicial com segurança.

## Integrantes do Grupo
* Eliseu Pereira Gili — [@eliseugili](https://github.com/egili)
* Guilherme Heron da Silva — [@GuilhermeHeron](https://github.com/GuilhermeHeron)
* Leonardo Maciel Ferreira de Moraes — [@leomacifs](https://github.com/leomacifs)
* Pietra Façanha Bortolato — [@piborto](https://github.com/piborto)

## Decisões Arquiteturais (ADRs)

* [ADR 0001: Usar Java como linguagem](docs/adr/0001-usar-java-como-linguagem.md)
* [ADR 0002: Realizar toda a criptografia no lado do cliente (zero-knowledge)](docs/adr/0002-realizar-criptografia-no-cliente.md)
* [ADR 0003: Adotar PostgreSQL como banco de dados do servidor](docs/adr/0003-adotar-postgresql-como-banco-do-servidor.md)
* [ADR 0004: Usar Docker em todas as partes do sistema](docs/adr/0004-usar-docker-em-todas-as-partes-do-sistema.md)
* [ADR 0005: Especificar obtenção do salt pré-login, derivação separada de chaves e ajuste de sessão nos contratos (Zero-Trust)](docs/adr/0005-especificacao-login-e-derivacao-chaves-zero-trust.md)
* [ADR 0006: Especificação do contêiner de backup (.vault) com cabeçalho aberto e re-cifragem no cliente na restauração (Zero-Trust)](docs/adr/0006-especificacao-backup-cifrado-e-recifragem-zero-trust.md)
