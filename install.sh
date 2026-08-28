#!/usr/bin/env bash
# Instala as skills deste repositório no diretório de skills do agente.
# Uso:
#   bash install.sh                     # instala em ~/.agents/skills (padrão cross-runtime)
#   AGENTS_SKILLS_DIR=~/.claude/skills bash install.sh
#   SKILLS="cove-wp" bash install.sh    # instala apenas skills selecionadas
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET="${AGENTS_SKILLS_DIR:-$HOME/.agents/skills}"
SELECT="${SKILLS:-*}"

mkdir -p "$TARGET"

installed=0
for skill_dir in "$REPO_ROOT"/skills/$SELECT; do
  [ -d "$skill_dir" ] || continue
  name="$(basename "$skill_dir")"
  cp -R "$skill_dir" "$TARGET/$name"
  echo "✔ instalada: $name → $TARGET/$name"
  installed=$((installed + 1))
done

if [ "$installed" -eq 0 ]; then
  echo "✖ nenhuma skill instalada (verifique SKILLS ou o diretório skills/)" >&2
  exit 1
fi

echo "Concluído. Reinicie o agente para carregar as skills."
