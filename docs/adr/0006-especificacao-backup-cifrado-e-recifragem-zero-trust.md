# ADR 0006: especificação do contêiner de backup (.vault) com cabeçalho aberto e re-cifragem no cliente na restauração (Zero-Trust)

**Status:** aceito

**Contexto:**  
Durante a revisão arquitetural e detalhamento dos fluxos de contingência e persistência (Tarefa #821), foram identificados três requisitos técnicos essenciais que precisavam de formalização antes da codificação:
1. **Estrutura e Portabilidade do Backup (.vault):** O backup do cofre (E8) precisa ser um arquivo portátil, capaz de ser restaurado em qualquer máquina ou nova instalação. Para que o Cliente consiga decifrar o arquivo sem depender de dados remotos no banco de dados, os parâmetros de derivação e inicialização criptográfica precisam acompanhar o arquivo de forma padronizada.
2. **Re-cifragem Obrigatória na Restauração (E9):** Um backup pode ter sido gerado com uma senha mestra antiga (antes de uma troca de senha) ou ter sido exportado de outro cofre. Se o Cliente simplesmente enviasse os dados cifrados originais ao Servidor, tais credenciais ficariam permanentemente ilegíveis no cofre atual (pois foram cifradas com uma chave diferente). Por outro lado, o Servidor não tem capacidade técnica de re-cifrar porque, por definição Zero-Trust, ele nunca possui acesso às chaves nem ao texto claro.
3. **Consolidação dos Papéis Arquiteturais:** A visão geral precisava explicitar de forma inequívoca que o Módulo de Criptografia (Back-end 2) opera estritamente dentro do processo do Cliente CLI (Front-end), operando como biblioteca interna e mantendo a fronteira de rede livre de qualquer dado não cifrado.

**Decisão:**
1. **Estrutura em Duas Camadas do Arquivo `.vault`:**
   - O arquivo de backup conterá duas partes bem definidas:
     - **Cabeçalho Aberto (Plaintext Header):** Estrutura pública de metadados contendo `versao`, `algoritmo` (AES-256), `salt` (usado para estirar a senha informada no backup) e `iv` (vetor de inicialização do envelope de dados). Manter `salt` e `iv` em aberto no cabeçalho é padrão universal de criptografia simétrica; tais valores não representam segredos e não permitem a decifragem dos dados sem a senha mestra.
     - **Corpo Cifrado (Ciphertext Payload):** Conjunto serializado de credenciais cifrado pelo Módulo de Criptografia do Cliente com a chave derivada da senha do backup e do salt do arquivo.
2. **Fluxo de Re-cifragem no Cliente (E9 / CT8):**
   - Ao importar um arquivo `.vault`, o Cliente extrai o cabeçalho, solicita a senha mestra do backup ao usuário e decifra o corpo do arquivo no espaço de memória local.
   - Em seguida, o Cliente decifra e **re-cifra cada credencial individualmente utilizando a chave de cifragem ativa do cofre atual e um novo IV exclusivo (`gerarIV()`)**.
   - Somente as credenciais já re-cifradas com a chave da sessão ativa são enviadas via comando `IMPORT_BACKUP` (CT8) ao Servidor. O Servidor valida a sessão e insere os registros na tabela `credencial` (CT10), sem jamais ter contato com a chave de origem, a chave atual ou as senhas em texto claro.
3. **Fronteira de Segurança e Módulo Local:**
   - Formalizar nos diagramas de contêineres e documentação que toda a inteligência criptográfica roda em tempo de execução na JVM do Cliente CLI. Pelo canal Socket TCP trafegam unicamente identificadores, hashes de autenticação unidirecionais, tokens e blobs cifrados.

**Alternativas consideradas:**
- *Criptografar o arquivo com chave hardcoded no código para omitir o cabeçalho:* descartada por ser péssima prática de segurança (chave estática compartilhada anula o sigilo e facilita engenharia reversa).
- *Enviar o arquivo `.vault` bruto para o Servidor processar e decifrar:* descartada frontalmente por ferir o pilar Zero-Trust / Zero-Knowledge (o servidor precisaria receber a senha mestra em texto claro).
- *Inserir os registros no banco sem re-cifrar:* descartada porque geraria corrupção lógica de acesso: se a senha mestra do usuário na época do backup fosse diferente da senha do cofre de destino, o usuário nunca mais conseguiria decifrar essas credenciais após o login.

**Consequências:**
- **Positivas:**
  - Arquivos de backup 100% autossuficientes e portáveis para qualquer ambiente.
  - Segurança matemática estrita ponta a ponta (Zero-Knowledge): o Servidor não tem visão do conteúdo em nenhuma etapa de exportação ou restauração.
  - O cofre atual permanece homogêneo e íntegro: todas as credenciais passam a ser decifráveis com a chave de sessão ativa do usuário.
- **Negativas:**
  - Custo computacional local no Cliente para decifrar o lote do backup e re-cifrar individualmente cada registro antes de despachar ao Servidor (desprezível para o volume de dados do escopo do projeto, da ordem de milissegundos).
