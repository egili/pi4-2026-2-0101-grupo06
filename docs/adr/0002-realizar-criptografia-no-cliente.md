# ADR 0002: realizar toda a criptografia no lado do cliente (zero-knowledge)

**Status:** aceito

**Contexto:** O sistema armazena credenciais (senhas e dados pessoais) em um servidor central. O problema central do projeto é a desconfiança de que o servidor tenha acesso aos dados em texto claro. Se a criptografia ocorrer no servidor, uma invasão ou um operador mal-intencionado pode expor todas as credenciais. O escopo define explicitamente que o servidor central não pode ter acesso às informações em texto claro.

**Decisão:** Realizar toda a cifragem e decifragem de credenciais exclusivamente no cliente, enviando ao servidor apenas dados já criptografados. O servidor nunca recebe a senha mestra nem os dados em texto claro, caracterizando a arquitetura zero-knowledge.

**Alternativas consideradas:**
- Criptografar no servidor após o recebimento: descartada porque expõe os dados em texto claro durante o tráfego e o processamento no servidor.
- Criptografia híbrida (parte no cliente, parte no servidor): descartada pela complexidade adicional e pela perda da garantia de que o servidor nunca vê dados em claro.
- Usar apenas TLS/HTTPS sem criptografia adicional: descartada porque protege o tráfego, mas não protege os dados armazenados no banco de dados do servidor.

**Consequências:**
- Positivas: mesmo que o banco de dados do servidor seja vazado, o atacante só encontra dados cifrados; o usuário mantém controle total sobre suas credenciais; alinhamento direto com o critério de sucesso do projeto.
- Negativas: se o usuário perder a senha mestra, não há como recuperar os dados (recuperação está fora de escopo); o cliente assume maior carga de processamento; o backup precisa ser exportado já cifrado para manter a garantia.
