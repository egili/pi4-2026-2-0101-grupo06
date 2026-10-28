# ADR 0005: especificar obtenção do salt pré-login, derivação separada de chaves e ajuste de sessão nos contratos (Zero-Trust)

**Status:** aceito

**Contexto:**  
Durante a revisão arquitetural e preparação para a codificação da autenticação e do cofre (Tarefa #820), identificaram-se três pontos críticos a formalizar:
1. **Obtenção do Salt pré-login:** O fluxo original de autenticação (E3) e o contrato CT3 assumiam que o Cliente já conhecia o `salt` do usuário para derivar a chave mestra antes de efetuar o login. Na prática, o usuário fornece na CLI apenas seu `username` e `senhaMestra`. Como o `salt` foi gerado no cadastro e está persistido no banco de dados do Servidor (tabela `usuario` - CT9), o Cliente precisa obter esse `salt` do Servidor antes de executar a derivação criptográfica.
2. **Reutilização de chave / Falha potencial de Zero-Trust:** Se o mesmo hash enviado ao Servidor para autenticação for utilizado como chave para cifrar/decifrar as credenciais do cofre, um operador mal-intencionado ou um invasor que tenha acesso ao banco de dados terá a chave necessária para decifrar todos os registros do cofre, anulando a garantia de Zero-Trust (ADR 0002).
3. **Inconsistência de sessão no Contrato CT2:** O contrato `salvarCredencial` (CT2) não exigia o identificador de sessão ativa (`tokenSessao`), ao contrário de todos os outros contratos de manipulação do cofre (CT4 a CT8), o que permitiria persistência de dados sem verificação de autenticidade da sessão.

**Decisão:**
1. **Handshake de Autenticação em Duas Fases (CT3):**
   - **Fase 1 (`GET_SALT`):** O Cliente envia `username`. O Servidor localiza o usuário na tabela `usuario` e retorna o `salt` cadastrado (ou `USUARIO_NAO_ENCONTRADO`).
   - **Fase 2 (`AUTH`):** O Cliente computa a derivação de chaves no seu processo local e envia `username` e `senhaMestraHash`. O Servidor valida o hash e retorna `tokenSessao` e `usuarioId`.
2. **Derivação de Chaves Separadas (Separação de Domínio Zero-Trust):**
   - A partir de `senhaMestra` e `salt`, o processo local do Cliente (Módulo de Criptografia / Back-end 2) deriva duas entidades criptográficas distintas:
     - **Chave de Cifragem (`chaveCifragem` / AES-256):** Derivada via função com custo computacional (PBKDF2WithHmacSHA256). Fica residente **estritamente na memória volátil do Cliente** durante a sessão. Nunca é transmitida pela rede nem conhecida pelo Servidor.
     - **Hash de Autenticação (`senhaMestraHash`):** Gerado aplicando-se uma função unidirecional (ex.: HMAC-SHA256 ou hash com propósito exclusivo de autenticação) sobre a chave ou senha. É este hash que é enviado nos comandos `REGISTER` (CT1) e `AUTH` (CT3).
   - Por ser uma operação unidirecional, é matematicamente inviável para o Servidor (ou um invasor com acesso ao banco) reverter o `senhaMestraHash` para obter a `chaveCifragem`. Os dados do cofre permanecem indecifráveis pelo Servidor.
3. **Padronização do Contrato CT2 (`salvarCredencial`):**
   - Adicionar o parâmetro obrigatório `tokenSessao` na Entrada do contrato CT2.
   - Adicionar o retorno de erro `SESSAO_INVALIDA` na tabela de erros do contrato CT2, alinhando-o a CT4, CT5, CT6, CT7 e CT8.

**Alternativas consideradas:**
- *Armazenar o salt localmente em arquivo de configuração no Cliente:* descartada por quebrar a portabilidade do usuário (o usuário não conseguiria acessar seu cofre a partir de outro terminal).
- *Enviar a senha mestra pura com TLS para o servidor calcular o hash:* descartada por violar frontalmente o modelo Zero-Trust / Zero-Knowledge (o servidor teria acesso à senha mestra em memória).
- *Manter CT2 sem token e validar apenas a conexão do socket:* descartada por fragilidade de segurança (falta de controle sobre validade, expiração e fechamento da sessão autenticada).

**Consequências:**
- **Positivas:**
  - Garantia matemática estrita da arquitetura Zero-Trust: vazamento total do banco de dados do servidor não compromete o texto claro das credenciais.
  - Viabilização prática do login em arquitetura cliente-servidor distribuída sem ferir a segurança.
  - Consistência e uniformidade no controle de sessão em todos os contratos de negócio do servidor.
- **Negativas:**
  - Uma etapa adicional de comunicação de rede (`GET_SALT`) antes do envio do comando `AUTH` (impacto em tempo na casa dos milissegundos).
