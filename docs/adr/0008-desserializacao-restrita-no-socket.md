# ADR 0008: restringir a desserialização no socket a uma lista exata de classes, com limites de profundidade e tamanho

**Status:** aceito

**Contexto:** O SonarCloud marcou a leitura do `ObjectInputStream` em `Parceiro.lerProximo()` (regra S5135, Insecure Deserialization via network socket) como BLOCKER. O filtro anterior aceitava pacotes inteiros (`java.lang.*` e `java.util.*`) e não limitava a profundidade nem o número de elementos. A disciplina exige que a comunicação continue por socket com `ObjectInputStream` (ADR 0007), então trocar o mecanismo de serialização não era opção.

**Decisão:**
1. O receptor continua sendo `ObjectInputStream`, com `ObjectInputFilter`. A lista de permissão é exata: `cofre.protocolo.*`, `java.lang.Long`, `java.lang.Integer`, `java.lang.String`, `java.lang.Number`, `java.lang.Object`, `java.util.ArrayList`, `java.util.HashMap` e `java.util.Map$Entry`. Nenhum pacote inteiro entra na lista.
2. O filtro tem limites: `maxdepth=6`, `maxrefs=2000` e `maxarray=2000`. O padrão final `!*` recusa tudo o que não estiver na lista.
3. O padrão `maxbytes` não é usado. Ele funciona no JDK 21, mas o CI roda em Java 17, e não foi verificado nessa versão.
4. A classe `Parceiro` é idêntica nos dois repositórios. O teste de sincronia (`protocolo.sha256`) falha se as cópias divergirem.
5. O teste `ParceiroFiltroTest` confirma que uma classe fora da lista é recusada e que as mensagens do protocolo passam.

**Consequências:**
- Positivas: classes de cadeias de gadgets, fora da lista, não são desserializadas. O protocolo funciona como antes.
- Negativas: uma nova classe que trafegue pelo socket (por exemplo, outro tipo de coleção) precisa entrar na lista e no teste. O analisador do SonarCloud não reconhece o filtro, então a regra S5135 pode continuar aberta. Fechá-la exige marcá-la como aceita na interface do SonarCloud, com a justificativa deste ADR.
