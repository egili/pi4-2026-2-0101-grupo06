#!/usr/bin/env bash
# Apaga os logs do Servidor e do Cliente. Os contêineres são parados e recriados depois.
set -euo pipefail
cd "$(dirname "$0")/.."

volumes=""
for nome in logs_servidor logs_cliente; do
  encontrado=$(docker volume ls -q -f "label=com.docker.compose.volume=$nome")
  [ -n "$encontrado" ] && volumes="$volumes$encontrado"$'\n'
done
volumes=$(printf "%s" "$volumes" | sed '/^$/d')
if [ -z "$volumes" ]; then
  echo "Nenhum volume de logs encontrado. Suba o sistema com 'docker compose up -d' antes."
  exit 0
fi

echo "Serão apagados os volumes de log:"
echo "$volumes" | sed 's/^/  /'
echo "Os contêineres backend-1 e backend-2 serão removidos e recriados. O banco não é afetado."
read -r -p "Digite APAGAR para confirmar: " resposta
if [ "$resposta" != "APAGAR" ]; then
  echo "Cancelado. Nada foi apagado."
  exit 1
fi

docker compose rm -sf backend-1 backend-2 > /dev/null
echo "$volumes" | xargs docker volume rm > /dev/null
echo "Logs apagados. Para voltar a gravar: docker compose up -d"
