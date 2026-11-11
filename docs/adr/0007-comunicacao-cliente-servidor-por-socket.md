# ADR 0007: comunicação entre Cliente e Servidor por socket TCP com threads

**Status:** aceito

**Contexto:** O escopo pede um servidor multiconexão e a disciplina exige sockets e threads entre cliente e servidor, no modelo do material "Fazedor de Continhas". Até este ADR, o Cliente falava com o Servidor por HTTP/REST, o que atendia a concorrência, mas não cumpria o requisito.

**Decisão:**
1. O Cliente (Back-end 2) e o Servidor (Back-end 1) trocam mensagens por `Socket` e `ServerSocket`, com objetos `Serializable` que estendem `Comunicado` (pacote `cofre.protocolo`, idêntico nos dois repositórios).
2. O Servidor tem uma thread `AceitadoraDeConexao` que aceita conexões e uma thread `SupervisoraDeConexao` por conexão. A lista de conexões é protegida por `synchronized`.
3. Cada lado usa a classe `Parceiro`, com semáforo e os métodos `receba`, `espie`, `envie` e `adeus`. O leitor de mensagens é uma única thread por conexão (`LeitorDoServidor` no Cliente), para evitar dois leitores no mesmo stream.
4. O receptor usa `ObjectInputFilter` com lista de classes permitidas (`cofre.protocolo`, `java.lang` e `java.util`), para não desserializar classes arbitrárias vindas da rede.
5. O navegador continua falando REST (HTTP/JSON) só com o Cliente. O Servidor não tem API REST.
6. O comando `desativar` no terminal do Servidor avisa todos os Clientes com `ComunicadoDeDesligamento` e encerra o processo.

**Consequências:**
- Positivas: atende ao requisito de sockets e threads; a concorrência é explícita no código; o Servidor fica fechado à rede por HTTP.
- Negativas: o Cliente faz um pedido por vez na conexão (pedidos são serializados); o protocolo fica duplicado nos dois repositórios, então qualquer mudança precisa ser feita nos dois; o desligamento depende de um terminal interativo, o que exige `stdin_open` e `tty` no contêiner.
