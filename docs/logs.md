# Logs do sistema Cofre Digital

Este documento explica os logs do Servidor (`backend-1`) e do Cliente (`backend-2`): onde ficam, o que significa cada mensagem, como achar erros e sucessos, como guardar cópias e como apagar.

> Os logs registram nome de usuário e IP. Esses dados são pessoais. Por isso eles devem ser apagados quando não forem mais necessários (veja [Como apagar](#como-apagar)).

## 1. Onde ficam os logs

| Programa | Arquivo atual | Arquivos antigos | Volume Docker |
|---|---|---|---|
| Servidor (`backend-1`) | `/app/logs/servidor.log` | `/app/logs/servidor-AAAA-MM-DD.log` | `logs_servidor` |
| Cliente (`backend-2`) | `/app/logs/cliente.log` | `/app/logs/cliente-AAAA-MM-DD.log` | `logs_cliente` |

- Um arquivo novo começa a cada dia. Quando o dia vira, o arquivo do dia anterior recebe a data no nome e continua guardado.
- Não há limite de tempo: os arquivos antigos ficam até alguém apagá-los.
- Os logs ficam em volumes do Docker. Eles continuam existindo mesmo depois de `docker compose down` e `docker compose up`.
- O horário das linhas é o do contêiner, que pode estar em UTC.

## 2. Como ler os logs

### Acompanhar em tempo real

```bash
docker compose exec backend-1 tail -f /app/logs/servidor.log
docker compose exec backend-2 tail -f /app/logs/cliente.log
```

### Ver as últimas linhas

```bash
docker compose exec backend-1 tail -n 50 /app/logs/servidor.log
```

### Copiar um arquivo para o seu computador

```bash
docker compose cp backend-1:/app/logs/servidor.log ./servidor.log
```

### Ver o log do contêiner (saída do terminal)

Além dos arquivos, o mesmo conteúdo aparece na saída do contêiner, com um formato mais curto:

```bash
docker compose logs -f backend-1
```

## 3. Formato de uma linha

```
2026-11-14 20:39:00.975 WARN  [supervisora-54698] NegocioServidor - Login recusado: usuário joao pelo IP 172.18.0.4
│                       │     │                    │                │
│                       │     │                    │                └─ mensagem
│                       │     │                    └─ classe que registrou o evento
│                       │     └─ thread que executou o trabalho
│                       └─ nível (ERROR, WARN, INFO ou DEBUG)
└─ data e hora, com milissegundos
```

## 4. Níveis de log

| Nível | Quando aparece | Exemplo |
|---|---|---|
| `ERROR` | Algo inesperado falhou no servidor. Precisa de atenção. | `Erro inesperado ao processar PedidoDeCriacao: java.sql.SQLException` |
| `WARN` | Uma tentativa foi recusada ou algo não saiu como esperado. Vale conferir quando se repete. | `Login recusado: usuário joao pelo IP 10.0.0.5` |
| `INFO` | Um evento normal e importante aconteceu. É o nível padrão. | `Login: usuário joao (id 3) pelo IP 10.0.0.5` |
| `DEBUG` | Detalhe técnico, para diagnóstico. Não aparece no nível padrão. | `Conexão recebida de /10.0.0.5:52114` |

O nível padrão é `INFO`. Para mudar, veja [Como ajustar o nível](#como-ajustar-o-nível).

## 5. Mensagens do Servidor

### 5.1 Eventos de sucesso (`INFO`)

| Mensagem | O que significa |
|---|---|
| `Cadastro criado: usuário X (id N)` | Uma conta nova foi criada. |
| `Login: usuário X (id N) pelo IP Y` | Login feito com sucesso. |
| `Exportação: usuário N com M credenciais` | Um backup foi exportado, com M credenciais. |
| `Importação: usuário N com M credenciais` | Um backup foi restaurado, com M credenciais. |
| `Conexão aberta: IP` | Um Cliente conectou ao Servidor. |
| `Conexão fechada: IP` | Um Cliente desconectou. |
| `Aguardando conexões na porta 8090` | O Servidor está pronto para receber Clientes. |
| `Servidor ativo. Para desativá-lo, use o comando "desativar"` | O Servidor iniciou. |
| `Servidor desativado pelo terminal` | O comando `desativar` foi usado. |
| `Servidor encerrando: avisando N cliente(s)` | O Servidor está desligando e avisando os Clientes conectados. |

### 5.2 Tentativas recusadas (`WARN`)

| Mensagem | O que significa | O que fazer |
|---|---|---|
| `Login recusado: usuário X pelo IP Y` | Senha errada, ou usuário que não existe. | Se for uma só, é normal. Se repetir muito, veja a seção de segurança. |
| `Login bloqueado por excesso de tentativas: usuário X pelo IP Y` | O limite de tentativas foi atingido. O bloqueio dura 1 minuto (teste; 15 min na entrega final). | Aguardar 1 minuto. |
| `Cadastro recusado: nome já existe (X)` | Alguém tentou criar um usuário com um nome que já existe. | Escolher outro nome. |
| `Pedido PedidoDeX recusado: SESSAO_INVALIDA` | O token da sessão é inválido ou expirou. | Fazer login de novo. |
| `Pedido PedidoDeX recusado: ACESSO_NEGADO` | Alguém tentou alterar uma credencial que não é sua. | Conferir se é uma tentativa indevida. |
| `Pedido PedidoDeX recusado: CREDENCIAL_NAO_ENCONTRADA` | A credencial pedida não existe. | Conferir o identificador. |
| `Pedido PedidoDeX recusado: DADOS_INVALIDOS` | Algum campo obrigatório veio vazio. | Conferir o formulário. |
| `Pedido PedidoDeX recusado: BACKUP_VAZIO` | Não há credenciais para exportar, ou a importação veio sem nenhuma. | Nada a fazer. |
| `Comando inválido no terminal` | Alguém digitou algo diferente de `desativar` no terminal do Servidor. | Nada a fazer. |
| `Conexão de IP encerrada com erro: Classe` | Uma conexão caiu de forma inesperada. | Se for pontual, é normal. Se repetir, veja a seção de diagnóstico. |
| `Falha ao aceitar conexão: mensagem` | O Servidor não conseguiu aceitar uma conexão. | Veja a seção de diagnóstico. |

### 5.3 Erros do Servidor (`ERROR`)

| Mensagem | O que significa | O que fazer |
|---|---|---|
| `Erro inesperado ao processar PedidoDeX: classe` | Uma operação falhou por causa do banco ou de outro problema interno. O Cliente recebe `ERRO_BANCO`. | Ver a classe citada e o horário. Veja a seção de diagnóstico. |

## 6. Mensagens do Cliente

### 6.1 Conexão com o Servidor

| Nível | Mensagem | O que significa |
|---|---|---|
| `INFO` | `Conectado ao Servidor host:porta` | O Cliente conectou ao Servidor. |
| `WARN` | `Não foi possível conectar ao Servidor host:porta` | O Servidor está fora do ar, ou a porta está errada. |
| `WARN` | `Servidor não respondeu em 15 s` | Um pedido ficou sem resposta. O Cliente desconecta e tenta de novo no próximo pedido. |
| `WARN` | `Conexão com o Servidor perdida: Classe` | A conexão caiu. O Cliente reconecta sozinho no próximo pedido. |
| `WARN` | `O servidor vai ser desligado agora; volte mais tarde` | O Servidor foi desligado com o comando `desativar`. |

### 6.2 Contas e backup

| Nível | Mensagem | O que significa |
|---|---|---|
| `INFO` | `Login: usuário X (id N)` | Login feito com sucesso. |
| `WARN` | `Login recusado: usuário X (CODIGO)` | O login falhou. O código indica o motivo, como `SENHA_INCORRETA` ou `MUITAS_TENTATIVAS`. |
| `WARN` | `Falha ao decifrar a credencial N` | Uma credencial não pôde ser decifrada. A senha mestra pode ter mudado, ou o dado pode estar corrompido. |
| `INFO` | `Exportação de backup: N credenciais` | Um backup foi montado no Cliente. |
| `INFO` | `Importação de backup: N credenciais` | Um backup foi restaurado com sucesso. |
| `WARN` | `Importação recusada: senha do backup incorreta` | A senha informada não abre o arquivo `.vault`. |

## 7. O que nunca aparece nos logs

Por segurança, os logs **nunca** registram:

- senhas digitadas, nem a senha mestra;
- hashes de autenticação;
- tokens de sessão;
- chaves de cifragem;
- senhas de serviços e dados cifrados;
- o conteúdo das credenciais.

Os logs registram apenas o nome de usuário, o IP, o identificador de uma credencial e contagens. Os testes automatizados do Servidor e do Cliente verificam que senhas e tokens não aparecem nos logs.

## 8. Como identificar erros e sucessos

Os comandos abaixo funcionam dentro do contêiner, com `docker compose exec backend-1 sh -c '...'`, ou depois de copiar o arquivo com `docker compose cp`.

```bash
# Todos os erros e avisos
grep -E " (WARN|ERROR) " servidor.log

# Só erros inesperados do Servidor
grep " ERROR " servidor.log

# Logins que deram certo e os que foram recusados
grep "Login:" servidor.log
grep "Login recusado" servidor.log

# Bloqueios por excesso de tentativas
grep "bloqueado" servidor.log

# Contar quantos logins falharam de um mesmo usuário
grep "Login recusado: usuário joao" servidor.log | wc -l

# Eventos de um dia específico (arquivo com a data no nome)
grep "Login" servidor-2026-11-14.log

# Problemas de conexão com o Servidor, vistos pelo Cliente
grep -E "WARN.*(Servidor|conexão)" cliente.log
```

### Sinais de alerta

- **Muitos `Login recusado` seguidos do mesmo usuário ou IP:** pode ser alguém tentando adivinhar uma senha. O sistema bloqueia depois de 5 falhas do usuário e de 20 falhas do IP.
- **`ERROR` com `Erro inesperado ao processar`:** algo falhou dentro do Servidor. Veja a classe citada e o horário.
- **`Não foi possível conectar` no Cliente:** o Servidor está fora do ar. Confira com `docker compose ps`.
- **`Falha ao decifrar a credencial`:** a credencial não abre com a chave atual. Não apague nada até entender a causa.

## 9. Como ajustar o nível

O nível é definido pela variável `LOG_NIVEL`, com `INFO` como padrão.

```bash
# Mais detalhes (inclui conexões recebidas)
LOG_NIVEL=DEBUG docker compose up -d

# Menos ruído: só avisos e erros
LOG_NIVEL=WARN docker compose up -d
```

Para voltar ao padrão, suba o sistema sem a variável: `docker compose up -d`.

## 10. Como apagar

### Opção 1: o script (recomendado)

```bash
./scripts/limpar-logs.sh
```

O script:

1. Lista os volumes de log que serão apagados.
2. Explica que os contêineres `backend-1` e `backend-2` serão recriados.
3. Pede a palavra `APAGAR`. Qualquer outra resposta cancela, e nada é apagado.
4. Remove os contêineres do Servidor e do Cliente e apaga os dois volumes de log.

Depois, para voltar a gravar logs:

```bash
docker compose up -d
```

O banco de dados não é afetado.

### Opção 2: copiar antes de apagar

Se você quiser guardar os logs antes, copie-os para o seu computador antes de rodar o script:

```bash
docker compose cp backend-1:/app/logs ./logs-servidor
docker compose cp backend-2:/app/logs ./logs-cliente
```

### Cuidado

- `docker compose down -v` apaga **também o banco de dados**. Não use para apagar só os logs.
- Apagar os logs não desfaz nada no cofre. Só remove o histórico.

## 11. Diagnóstico de problemas comuns

| Sintoma | Onde procurar | Causa provável |
|---|---|---|
| Login não funciona e aparece `ERRO_CONEXAO` | `cliente.log`: `Não foi possível conectar` | Servidor fora do ar ou porta errada. |
| Login aparece como `MUITAS_TENTATIVAS` | `servidor.log`: `bloqueado` | Excesso de tentativas. Aguardar 1 minuto. |
| Salvar ou listar credenciais dá `SESSAO_INVALIDA` | `servidor.log`: `SESSAO_INVALIDA` | Token expirado. Fazer login de novo. |
| Credencial não abre | `cliente.log`: `Falha ao decifrar` | Chave diferente da que cifrou o dado. |
| Servidor não sobe | `docker compose logs backend-1` | Veja a mensagem de erro na saída do contêiner, porque o arquivo pode não ter sido criado ainda. |
| Muitas linhas `Conexão aberta` e `fechada` sem uso | Normal | Clientes conectando e desconectando. |

## 12. Retenção e privacidade

- Os arquivos ficam guardados até alguém apagá-los, como foi decidido.
- Nome de usuário e IP são dados pessoais. Apague os logs quando não precisar mais deles.
- Antes de compartilhar um log, confira se ele não contém informação pessoal que não deva sair do grupo.
