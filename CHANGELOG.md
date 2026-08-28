# Changelog

Todas as mudanças notáveis neste repositório serão documentadas neste arquivo.

O formato segue [Keep a Changelog](https://keepachangelog.com/pt-BR/1.1.0/) e este
projeto adere ao [Versionamento Semântico](https://semver.org/lang/pt-BR/).

## [Unreleased]

## [1.0.0] - 2026-08-28

### Adicionado

- Skill `cove-wp`: referência completa para gerenciar sites WordPress locais com
  [Cove](https://cove.run) (v1.14) via WP-CLI através do runtime FrankenPHP.
- Execução correta de WP-CLI: `PHPRC=~/Cove/php.ini frankenphp php-cli $(which wp) --path=$(cove path <nome>) <comando>`.
- Seção **Uso não interativo** (agentes/scripts/CI): tabela de flags (`--yes`,
  `--force`, `--dry-run`, `--porcelain`, portas explícitas) e uso de
  `cove status --porcelain` como contrato máquina-legível.
- **Descoberta de serviços**: URLs de Dashboard/Mailpit/Adminer obtidas de
  `cove status` (fonte da verdade), sem hostnames inventados.
- Referência rápida completa: gestão de sites, migração (`pull`/`push`/`share`),
  rede (`lan`/`tailscale`/`ports`), banco (`db`/`memory`), manutenção
  (`php`/`core`/`upgrade`/`reload`), customização (`mappings`/`proxy`/`directive`).
- Seção **Gotchas**: editor GD forçado (não Imagick), expiração do token de login
  em 15 min, PHP pinado vs FrankenPHP, `cove upgrade` ≠ `cove core update`.
- Seção **Erros comuns**: tabela causa → correção.
- README em PT-BR (`README.pt-BR.md`) e EN (`README.md`), com links de idioma.
- `LICENSE` (MIT).
- GitHub Actions para validação automática do `SKILL.md`.
- `tests/scenarios.md` com os cenários de teste da metodologia de skills de referência.
- `install.sh` para instalação em um único comando.

### Corrigido

- URLs de serviços anteriormente inventadas (`db.cove.localhost`,
  `mail.cove.localhost`) e flag `cove log --error` inexistente — substituídas
  pela descoberta via `cove status`.

[1.0.0]: https://github.com/oparatecnologia/cove-skills/releases/tag/v1.0.0
