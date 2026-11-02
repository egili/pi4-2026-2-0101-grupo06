# ADR 0001: adotar Java como linguagem principal do projeto

**Status:** aceito

**Contexto:** O projeto é um sistema cliente-servidor de cofre de senhas desenvolvido em um semestre letivo A linguagem precisa oferecer suporte nativo a criptografia (hash e cifragem de credenciais), boa integração com HTTP/REST para a comunicação cliente-servidor e empacotamento via Docker. A linguagem definida para o semestre é Java.

**Decisão:** Utilizar Java (JDK 17 ou superior, com Spring Boot) como linguagem do cliente (Back-end 2) e do servidor (Back-end 1), concentrando toda a lógica de criptografia, autenticação e comunicação. O front-end web (HTML/CSS/JavaScript) é apenas a interface do usuário e conversa somente com o cliente.

**Alternativas consideradas:**
- Python: descartada pela ausência de tipagem estática forte, que ajudaria na verificação de contratos entre módulos.
- Kotlin: descartada pela curva de aprendizado adicional desnecessária ao escopo.
- TypeScript/Node.js: descartada pela menor maturidade em criptografia de baixo nível e pela dispersão entre front-end e back-end.

**Consequências:**
- Positivas: criptografia nativa no JDK sem dependências externas; multiplataforma; ferramental consolidado de build e teste; Docker empacota o servidor sem exigir instalação manual no cliente; atende à exigência acadêmica do semestre.
- Negativas: verbosidade maior que linguagens como Python para tarefas simples; a interface web exige HTML/CSS/JavaScript, fora do Java.
