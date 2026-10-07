# ADR 0004: usar Docker em todas as partes do sistema

**Status:** aceito

**Contexto:** O sistema é cliente-servidor e será executado por quatro integrantes em máquinas diferentes, além da máquina de avaliação. Sem padronização, cada integrante enfrentaria problemas distintos de configuração de dependências, versão de Java e porta de rede, atrasando o desenvolvimento e as demonstrações. O escopo prevê um servidor multiconexão que precisa subir de forma padronizada, um banco PostgreSQL com configuração inicial de usuário, senha e volume, um cliente em Java que precisa do JDK instalado e um front-end que depende de ferramentas de build próprias. Padronizar apenas parte do sistema ainda deixaria lacunas de ambiente que comprometeriam a reprodutibilidade do projeto.

**Decisão:** Empacotar **todas as partes do sistema** em containers Docker — o servidor, o cliente, o front-end e o banco de dados PostgreSQL — com Docker Compose coordenando os serviços em uma única rede. Cada parte tem seu próprio `Dockerfile` e serviço definido no `docker-compose.yml`, garantindo que qualquer integrante ou avaliador suba o ambiente completo com um único comando, sem instalar Java, Node.js, PostgreSQL ou qualquer outra dependência diretamente na máquina.

**Alternativas consideradas:**
- Containerizar apenas o servidor e o banco, deixando cliente e front-end na máquina local: descartada porque ainda exigiria que cada integrante instalasse o JDK e as ferramentas de build do front-end, mantendo o risco de divergência entre ambientes.
- Instalação manual em cada máquina: descartada pelo retrabalho de configuração e pela alta chance de divergência entre ambientes.
- Uso de máquina virtual completa: descartada pelo peso, tempo de inicialização e complexidade desnecessária para o escopo.
- Scripts de instalação automatizada sem containers: descartada pela ausência de isolamento e pela dificuldade de reproduzir o ambiente em sistemas operacionais diferentes.

**Consequências:**
- Positivas: ambiente idêntico para todos os integrantes e para a avaliação; subida do sistema completo com um único comando via Docker Compose; nenhuma dependência precisa ser instalada diretamente na máquina (nem Java, nem Node.js, nem PostgreSQL); facilita demonstrações e testes de integração; padroniza a configuração do banco, do servidor, do cliente e do front-end; o mesmo conjunto de containers pode ser reproduzido em qualquer máquina com Docker instalado.
- Negativas: exige que todos os integrantes tenham Docker instalado e saibam operar comandos básicos; adiciona uma camada de abstração que precisa ser compreendida pela equipe; o consumo de memória cresce com o número de containers ativos (servidor, cliente, front-end e banco ao mesmo tempo); a comunicação entre cliente e servidor dentro do Docker exige configuração correta de rede interna (nomes de serviço em vez de `localhost`); a imagem do front-end precisa ser reconstruída a cada alteração no código, o que pode tornar o ciclo de desenvolvimento mais lento se não houver volume mapeado.
