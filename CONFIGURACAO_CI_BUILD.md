# Guia de Finalização da Infraestrutura de Build e CI

A infraestrutura básica de CI e Build foi implementada. Para que ela funcione plenamente, siga os passos abaixo:

## 1. Publicação do Módulo de Criptografia
O Cliente depende do `modulo-criptografia`. Para que o Maven consiga resolver essa dependência durante o build do Cliente:
- Entre na pasta `pi4-0101-g6-backend-2`.
- Execute `mvn install`. Isso instalará o JAR do módulo de criptografia no seu repositório local (`~/.m2/repository`).
- **Para o CI do GitHub:** Você precisará de um GitHub Packages (ou similar) para publicar o artefato do módulo de criptografia, ou configurar o workflow do Cliente para fazer o checkout de ambos os repositórios e buildar o módulo de criptografia antes do Cliente.

## 2. Implementação de Código e Testes
Atualmente, os builds do CI vão falhar ou passar sem fazer nada porque não há código.
- Crie as pastas `src/main/java` e `src/test/java` em cada repositório.
- Adicione classes de teste JUnit em `src/test/java` para validar a lógica. O CI executará automaticamente `mvn test` a cada push.

## 3. Estrutura de Pastas Recomendada
Certifique-se de seguir este padrão para que o Maven funcione:
```
/repo-root
  ├── pom.xml
  └── src
      ├── main
      │   └── java
      │       └── br/edu/pi4/g6/... (seu código)
      └── test
          └── java
              └── br/edu/pi4/g6/... (seus testes)
```

## 4. Configuração do GitHub
Para ativar o CI:
- Faça o push desses arquivos para os repositórios no GitHub.
- Verifique a aba **Actions** no GitHub para monitorar a execução dos testes.
