#!/usr/bin/env bash
# Valida o frontmatter e a estrutura de uma Agent Skill.
# Uso: bash scripts/validate-skill.sh <caminho-da-skill>
set -uo pipefail

SKILL_DIR="${1:-.}"
SKILL_FILE="$SKILL_DIR/SKILL.md"

fail() {
  echo "  ✖ $1" >&2
  exit 1
}

[ -f "$SKILL_FILE" ] || fail "SKILL.md não encontrado em $SKILL_DIR"

# 1. Frontmatter delimitado por ---
if ! head -1 "$SKILL_FILE" | grep -q '^---$'; then
  fail "o arquivo deve começar com '---' (frontmatter YAML)"
fi

# 2. Campos obrigatórios (name e description)
for field in name description; do
  grep -qE "^$field:" "$SKILL_FILE" || fail "campo obrigatório '$field' ausente no frontmatter"
done

# 3. Descrição: terceira pessoa, começa com "Use quando" e está sob limite de chars
DESC_LINE="$(grep -E '^description:' "$SKILL_FILE" | head -1)"
[ -n "$DESC_LINE" ] || fail "descrição não encontrada"
DESC_TEXT="$(printf '%s' "$DESC_LINE" | sed -E 's/^description:[[:space:]]*"?(.*)"?[[:space:]]*$/\1/')"
case "$DESC_TEXT" in
  "Use quando"*) : ;;
  *) fail "description deve começar com 'Use quando' (critério de ativação)" ;;
esac
[ "${#DESC_TEXT}" -le 1024 ] || fail "description excede 1024 caracteres (${#DESC_TEXT})"

# 4. Name: apenas letras, números e hífens
NAME="$(grep -E '^name:' "$SKILL_FILE" | head -1 | sed -E 's/^name:[[:space:]]*"?([^"]*)"?[[:space:]]*$/\1/')"
case "$NAME" in
  *' '*|*[!a-zA-Z0-9-]*|'') fail "name deve conter apenas letras, números e hífens: '$NAME'" ;;
esac

# 5. Diretório e name devem bater
DIR_NAME="$(basename "$SKILL_DIR")"
[ "$NAME" = "$DIR_NAME" ] || fail "o name no frontmatter ('$NAME') difere do nome do diretório ('$DIR_NAME')"

# 6. Cabeçalho H1 deve existir
grep -qE '^# ' "$SKILL_FILE" || fail "falta cabeçalho H1 (título da skill)"

echo "  ✔ '$NAME' válido (description: ${#DESC_TEXT} chars)"
exit 0
