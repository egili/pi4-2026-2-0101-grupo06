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

