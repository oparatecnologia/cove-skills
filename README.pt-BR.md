# Cove & WP-CLI — Skills de Agente

> Gerencie sites WordPress locais com [Cove](https://cove.run) e execute WP-CLI através do runtime FrankenPHP — direto de agentes de IA (Claude Code, Codex, Cursor, Copilot, opencode…).

[![Licença: MIT](https://img.shields.io/badge/Licen%C3%A7a-MIT-yellow.svg)](LICENSE)
[![Cove](https://img.shields.io/badge/Cove-v1.14-green)](https://cove.run)
[![Validate Skills](https://github.com/oparatecnologia/cove-skills/actions/workflows/validate-skills.yml/badge.svg)](https://github.com/oparatecnologia/cove-skills/actions/workflows/validate-skills.yml)

**🇬🇧 [Read in English](README.md)**

---

## Índice

- [Visão geral](#visão-geral)
- [Por que esta skill existe](#por-que-esta-skill-existe)
- [O que a skill ensina](#o-que-a-skill-ensina)
- [Estrutura do repositório](#estrutura-do-repositório)
- [Pré-requisitos](#pré-requisitos)
- [Instalação](#instalação)
- [Uso](#uso)
- [Referência de comandos](#referência-de-comandos)
- [Uso não interativo / para agentes](#uso-não-interativo--para-agentes)
- [Gotchas](#gotchas)
- [Compatibilidade](#compatibilidade)
- [Testes](#testes)
- [Licença](#licença)

---

## Visão geral

Esta é uma **Agent Skill** (`SKILL.md`) que ensina agentes de IA a trabalhar com ambientes WordPress locais gerenciados pelo [Cove](https://cove.run). O Cove é um CLI mínimo que roda Caddy + FrankenPHP + MariaDB + Mailpit — sem Docker — e serve cada site em `https://<nome>.localhost`.

A skill foca nos dois pontos em que agentes mais erram:

1. **Executar WP-CLI no runtime PHP errado.** O Cove embute seu próprio PHP via FrankenPHP (`~/Cove/php.ini`). Um `wp`/`php` do sistema pode não ter as mesmas extensões ou configuração. A skill impõe a invocação correta.
2. **Hardcodar portas e hostnames.** As portas mudam por máquina (`cove ports`) e via Tailscale. A skill ensina que `cove status` é a fonte da verdade.

## Por que esta skill existe

Sem orientação, agentes:

- Chamam `wp` direto do PATH do sistema e obtêm comportamento diferente do que o site usa;
- Inventam URLs de Adminer/Mailpit que não existem (`db.cove.localhost`, `mail.cove.localhost`);
- Travam esperando prompts interativos em ambiente sem TTY;
- Não conhecem o pin de PHP (`cove php`), gestão de núcleo (`cove core`) ou migração (`cove pull`/`push`) do Cove;
- Se surpreendem com comportamentos específicos do Cove (editor GD forçado em vez de Imagick, páginas de erro Whoops, token de login com expiração de 15 minutos).

## O que a skill ensina

- **Execução de WP-CLI** via FrankenPHP: `PHPRC=~/Cove/php.ini frankenphp php-cli $(which wp) --path=$(cove path <nome>) <comando>`, além de um alias reutilizável.
- **Uso não interativo** para agentes/scripts/CI: todo prompt interativo tem uma flag (`--yes`, `--force`, `--dry-run`, `--porcelain`, portas explícitas), e `cove status --porcelain` é um contrato `chave=valor` estável.
- **Descoberta de serviços**: URLs do Dashboard, Mailpit e Adminer vêm de `cove status`, nunca de memória.
- **Ciclo de vida de sites**: criar (com versão/pin), clonar, renomear, excluir, login, path, url.
- **Migração e compartilhamento**: `cove pull`/`cove push` via SSH (incluindo `--proxy-uploads`), túnel público `cove share`.
- **Gestão de PHP e núcleo**: `cove php <site> <versao>`, `cove core check`/`update`.
- **Banco de dados**: `cove db list`, `cove db backup`, `cove memory`.
- **Diagnóstico**: `cove health`, `cove log <site> -f`, `cove reload`, `cove trust`, `cove upgrade`.
- **Customização**: `cove mappings`, `cove proxy`, `cove directive`.
- **Gotchas** e uma tabela de **erros comuns**.

## Estrutura do repositório

```
cove-skills/
├── README.md               # EN
├── README.pt-BR.md         # PT-BR
├── LICENSE                 # MIT
├── CHANGELOG.md
├── install.sh              # instalador de um comando
├── scripts/
│   └── validate-skill.sh   # validador de frontmatter/estrutura
├── tests/
│   └── scenarios.md        # cenários de teste de skill de referência
└── skills/
    └── cove-wp/            # a skill em si
        └── SKILL.md
```

## Pré-requisitos

- [Cove](https://cove.run) instalado e rodando (`cove status` mostra os serviços ativos).
- Um agente de IA que suporte skills (Claude Code, Codex, Cursor, Copilot, opencode, etc.).
- Um site WordPress local criado com `cove add <nome>`.

## Instalação

### Um comando

```bash
bash <(curl -sL https://raw.githubusercontent.com/oparatecnologia/cove-skills/main/install.sh)
```

Instala em `~/.agents/skills/`. Para mudar o destino use `AGENTS_SKILLS_DIR`
(ex.: `AGENTS_SKILLS_DIR=~/.claude/skills`) ou selecione skills específicas com
`SKILLS="cove-wp"`.

### Manual

Clone este repositório e copie (ou crie um symlink) a skill para o diretório de skills do seu agente:

```bash
git clone https://github.com/oparatecnologia/cove-skills.git
mkdir -p ~/.claude/skills            # Claude Code
cp -R cove-skills/skills/cove-wp ~/.claude/skills/cove-wp

# ou, alias entre runtimes:
mkdir -p ~/.agents/skills
cp -R cove-skills/skills/cove-wp ~/.agents/skills/cove-wp
```

### Por projeto

Para limitar a skill a um único repositório, coloque-a em um diretório local do projeto:

```bash
mkdir -p .claude/skills   # ou .agents/skills, .cursor/skills…
cp -R cove-skills/skills/cove-wp .claude/skills/cove-wp
```

## Uso

Instalada, a skill ativa automaticamente quando a tarefa envolve WordPress local + Cove. Gatilhos típicos:

> "Configure um novo site WordPress local com o Cove"
> "Instale e ative o plugin WooCommerce no site 'loja'"
> "Baixe meu site de produção via SSH sem as mídias"
> "Atualize o núcleo do WordPress de todos os sites do Cove"
> "Por que meu site está mostrando 'Allowed memory size exhausted'?"

O agente lê o `SKILL.md` e aplica os comandos corretos. Exemplo do que a skill produz:

```bash
SITE_PATH=$(cove path loja)
WP="PHPRC=~/Cove/php.ini frankenphp php-cli $(which wp) --path=$SITE_PATH"

$WP plugin install woocommerce --activate
```

## Referência de comandos

A skill documenta todos os grupos de comandos do Cove como tabela de referência rápida:

| Grupo | Comandos |
| :--- | :--- |
| **Gestão de sites** | `cove add` (com versão/`--plain`/`--php`), `cove delete`, `cove rename`, `cove clone`, `cove list`, `cove login`, `cove path`, `cove url` |
| **Migração e compartilhamento** | `cove pull`, `cove push`, `cove share`, `cove transfer probe` |
| **Rede** | `cove lan`, `cove tailscale`, `cove ports`, `cove wsl-hosts` |
| **Banco e serviços** | `cove db list`, `cove db backup`, `cove memory`, `cove trust`, `cove enable/disable`, `cove log`, `cove status`, `cove health` |
| **Manutenção e versões** | `cove php`, `cove core check/update`, `cove upgrade`, `cove reload`, `cove version` |
| **Customização** | `cove mappings`, `cove proxy`, `cove directive` |

## Uso não interativo / para agentes

A skill traz uma seção dedicada para agentes nunca travarem em prompts:

| Flag | Aplica a | Efeito |
| :--- | :--- | :--- |
| `--yes` | `pull`, `push`, `share`, `install`, `delete`, `ports`, `memory set`, `upgrade`, `core update --all` | Pula confirmação |
| `--force` | `delete`, `directive delete`, `proxy add/delete` | Pula confirmação/overwrite |
| `--dry-run` | `ports`, `core update --all` | Prévia sem alterar |
| `--porcelain` | `status` | Saída `chave=valor` estável para máquina |

## Gotchas

- **Editor de imagens GD (não Imagick):** o Cove força `WP_Image_Editor_GD` para evitar crash no FrankenPHP (SIGSEGV). Para voltar ao Imagick, use `add_filter('cove_force_gd_editor', '__return_false')`.
- **Sites com PHP pinado:** o WP-CLI de um site pinado com `cove php` roda sob aquele PHP, não o FrankenPHP — prefira os comandos nativos do Cove nesse caso.
- **Expiração do token de login:** tokens do `cove login` têm 7 caracteres e expiram em **15 minutos**.
- **`cove upgrade` ≠ `cove core update`:** um atualiza a ferramenta Cove; o outro atualiza o núcleo do WordPress dos sites.

## Compatibilidade

| Componente | Versão |
| :--- | :--- |
| Cove | testado contra v1.14 |
| WordPress | qualquer release do `cove add` (incl. `6.4.3`, `nightly`, `plain`) |
| PHP | FrankenPHP padrão ou pin por site via `cove php` |

## Testes

A skill é verificada com a metodologia de teste de skills de referência
(cenários de recuperação, aplicação e lacunas) usando subagentes — veja
[`tests/scenarios.md`](tests/scenarios.md) para os cenários e últimos resultados.
Uma [GitHub Action](.github/workflows/validate-skills.yml) também valida o
frontmatter e a estrutura de todo `SKILL.md` do repositório em push/PR.

Rode o validador localmente:

```bash
bash scripts/validate-skill.sh skills/cove-wp
```

## Contribuindo

- Mantenha o `SKILL.md` alinhado com a [documentação oficial do Cove](https://cove.run) e seu changelog.
- Quando o Cove lançar nova versão, rode novamente os cenários em [`tests/scenarios.md`](tests/scenarios.md).
- Atualize o [`CHANGELOG.md`](CHANGELOG.md) para qualquer mudança perceptível ao usuário.
- Garanta que `bash scripts/validate-skill.sh skills/cove-wp` passe.

## Licença

MIT — veja [LICENSE](LICENSE).
