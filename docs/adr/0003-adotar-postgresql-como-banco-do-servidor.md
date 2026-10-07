# ADR 0003: adotar PostgreSQL como banco de dados do servidor

**Status:** aceito

**Contexto:** O servidor precisa armazenar credenciais cifradas de múltiplos usuários e suportar múltiplas conexões simultâneas, com usuários interagindo ao mesmo tempo sem travamento. O projeto tem prazo de um semestre e precisa de um banco que ofereça boa concorrência, integração via JDBC e empacotamento simples com Docker. A migração para um banco mais robusto já era prevista como evolução natural caso o MVP evoluísse para múltiplos usuários simultâneos.

**Decisão:** Utilizar PostgreSQL como banco de dados do servidor, armazenando as credenciais como blobs cifrados. O PostgreSQL será executado em container Docker, ao lado do servidor, garantindo o suporte a múltiplas conexões simultâneas.

**Alternativas consideradas:**
- SQLite: descartado por não suportar bem múltiplos acessos simultâneos de escrita, o que conflita diretamente com o servidor multiconexão; seria viável apenas para um MVP com um único usuário por vez.
- MongoDB ou outro banco NoSQL: descartado pela ausência de vantagem clara sobre PostgreSQL no estágio atual e pela complexidade de integração com JDBC.
- Armazenar em arquivos JSON diretamente: descartado pela dificuldade de consulta, integridade e concorrência em múltiplos acessos simultâneos.

**Consequências:**
- Positivas: suporte nativo a múltiplas conexões simultâneas; transações ACID para garantir integridade das credenciais; integração consolidada via JDBC; dados armazenados como blobs cifrados, mantendo a garantia zero-knowledge; Docker Compose sobe o banco junto com o servidor sem configuração manual.
- Negativas: exige um container adicional para o banco, consumindo mais memória que o SQLite; requer configuração inicial de usuário, senha e volume persistente; aumenta levemente o tempo de subida do ambiente em relação a um banco em arquivo único.
