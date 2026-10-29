# 🚀 Checklist Final: Infraestrutura de Build e CI

Este documento detalha tudo o que falta para que o projeto saia da fase de "esqueleto" e tenha um fluxo de desenvolvimento profissional, com build automatizado e testes contínuos.

## 📋 Resumo do Status Atual
- [x] **Configuração de Build:** `pom.xml` implementado nos 3 repositórios.
- [x] **Dependências:** Cliente configurado para usar o Módulo de Criptografia.
- [x] **CI (Integração Contínua):** Workflows do GitHub Actions configurados para rodar testes JUnit.
- [x] **Compatibilidade:** `.gitattributes` configurado para evitar conflitos entre Windows e Linux.

---

## 🛠️ O que falta fazer (Passo a Passo)

### 1. Estruturação de Pastas (Essencial)
O Maven exige uma estrutura específica para encontrar o código e os testes. Você deve criar as seguintes pastas em **cada um dos três repositórios**:

```bash
# Execute isso na raiz de cada repositório
mkdir -p src/main/java/br/edu/pi4/g6
mkdir -p src/test/java/br/edu/pi4/g6
```
*Se estiver no Windows, crie as pastas manualmente via Explorador de Arquivos seguindo esse caminho.*

### 2. Implementação do Código e Testes
O CI está configurado, mas ele "passa" sem testar nada porque não há classes.
- **Código:** Implemente as classes Java em `src/main/java`.
- **Testes:** Implemente as classes de teste JUnit 5 em `src/test/java`.
- **Validação:** Rode `mvn test` localmente antes de fazer o push para garantir que o CI não falhe.

### 3. Gestão do Módulo de Criptografia (O ponto crítico)
Como o Cliente depende da Criptografia, o build do Cliente falhará se ele não encontrar o JAR da Criptografia.

**Opção A (Local - Simples):**
Sempre que alterar o Módulo de Criptografia, execute:
```bash
cd pi4-0101-g6-backend-2
mvn install
```
Isso coloca o módulo no seu repositório local (`.m2`), permitindo que o Cliente o encontre.

**Opção B (Nuvem - Profissional):**
Para que o CI do GitHub funcione sem erros de "Dependency Not Found":
1. Configure o **GitHub Packages** para hospedar o artefato do `modulo-criptografia`.
2. Adicione as credenciais do GitHub Packages no `settings.xml` do Maven no workflow do Cliente.

### 4. Publicação e Ativação
1. Faça o `git add`, `git commit` e `git push` de todos os arquivos criados (`pom.xml`, `.github/workflows/ci.yml`, `.gitattributes`).
2. No GitHub, acesse a aba **Actions** para monitorar se os testes estão rodando a cada push.

---

## ⚠️ Lembretes para a Equipe (Windows & Linux)
- **Caminhos de Arquivos:** Nunca use `C:\` ou `/home/`. Use `Paths.get("caminho", "do", "arquivo")`.
- **Build:** Use sempre `mvn clean install` para garantir que versões antigas do código não interfiram no build novo.
- **Git:** Não alterem as quebras de linha manualmente; o `.gitattributes` cuidará disso.
