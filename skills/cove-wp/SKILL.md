---
name: cove-wp
description: "Use quando precisar gerenciar sites WordPress locais com Cove (cove.run): criar/clonar/renomear/excluir sites, executar comandos WP-CLI via runtime FrankenPHP, migrar sites remotos (pull/push), compartilhar via túnel público, trocar versão de PHP/WP, ajustar portas, diagnosticar logs e inspecionar banco de dados ou e-mails de teste (Mailpit)."
version: 1.0.0
license: MIT
source: https://github.com/oparatecnologia/cove-skills/tree/main/skills/cove-wp
allowed-tools:
  - bash
  - read
  - grep
  - glob
---

# Cove & WP-CLI Integration

Referência para gerenciar o ambiente de desenvolvimento local WordPress usando o **Cove** (`cove`) e executar comandos **WP-CLI** através do runtime do **FrankenPHP**.

O Cove roda Caddy + FrankenPHP + MariaDB + Mailpit sem Docker. Cada site fica em `~/Cove/Sites/<nome>.localhost/public`. Nada de portas/domínios: usa `https://<nome>.localhost` e o token de login resolve tudo.

## Execução do WP-CLI

Sempre execute comandos WP-CLI através do runtime FrankenPHP do Cove (o `php`/`wp` do PATH do sistema pode não ter as mesmas extensões ou o `php.ini`):

```bash
PHPRC=~/Cove/php.ini frankenphp php-cli $(which wp) --path=$(cove path <nome>) <comando>
```

> **Dica:** dentro do diretório do site (`~/Cove/Sites/<nome>.localhost/public`) use `--path=.`.

### Atalho reutilizável

```bash
SITE_PATH=$(cove path <nome>)
WP="PHPRC=~/Cove/php.ini frankenphp php-cli $(which wp) --path=$SITE_PATH"

$WP plugin list
$WP plugin install <slug> --activate
$WP option get siteurl
$WP option update blogname "Novo Título"
$WP cache flush
$WP rewrite flush
```

> **Atenção (PHP versionado):** sites pinados com `cove php <site> <versao>` servem WP-CLI sob o mesmo PHP pinado, **não** o FrankenPHP padrão. Para esses, prefira os comandos nativos do Cove (`cove login`, `cove core update`, backups) que já roteiam o WP-CLI certo, ou confirme a versão efetiva com `cove php` antes de usar o alias `$WP`.

## Uso Não Interativo (agentes / scripts)

Cove suporta flag para **todo** prompt interativo, para que scripts, CI e agentes nunca travem esperando resposta:

| Flag | Aplica a | Efeito |
| :--- | :--- | :--- |
| `--yes` | `pull`, `push`, `share`, `install`, `delete`, `ports`, `memory set`, `upgrade`, `core update --all` | Pula confirmação |
| `--force` | `delete`, `directive delete`, `proxy add/delete` | Pula confirmação/overwrite |
| `--dry-run` | `ports`, `core update --all` | Prévia sem alterar |
| `--porcelain` | `status` | Saída `key=value` estável (contrato) |
| `--http PORT --https PORT` | `ports`, `install` | Pula o menu de portas |

**Estado da stack para agentes:** `cove status --porcelain` emite uma linha `chave=valor` por serviço (`caddy=running`, `mariadb=stopped`, `php-fpm-8.2=running`, `version=`). As chaves são um contrato estável; use-as em automação em vez de parsear a saída humana.

## Quick Reference

### Gestão de sites

| Operação | Comando | Observações |
| :--- | :--- | :--- |
| Criar site WP | `cove add <nome>` | `latest` por padrão |
| Criar com versão específica | `cove add <nome> <versao>` | ex.: `6.4.3`, `6.9-RC1`, `nightly`, `plain` |
| Criar com PHP pinado | `cove add <nome> <versao> --php=8.1` | |
| Criar site estático | `cove add <nome> --plain` | sem WordPress |
| Listar sites | `cove list [--totals]` | colunas WP e PHP; `--totals` = disco |
| Login admin | `cove login <site> [<usuario>]` | token de 7 chars, expira em 15 min |
| Login via WP-CLI | `wp user login <user>` | comando do MU-plugin do Cove |
| Caminho absoluto | `cove path <nome>` | `~/Cove/Sites/<nome>.localhost/public` |
| URL do site | `cove url <nome>` | `https://<nome>.localhost` |
| Clonar site (fixture) | `cove clone <origem> <destino>` | arquivos + DB + search-replace; copy-on-write em APFS/btrfs |
| Renomear site | `cove rename <antigo> <novo>` | diretório + DB + URLs (`wp search-replace`) |
| Excluir site | `cove delete <nome> [--force] [--yes]` | remove diretório e banco |

### Migração & compartilhamento

| Operação | Comando |
| :--- | :--- |
| Baixar site remoto | `cove pull [--ssh ...] [--path ...] [--site ...] [--proxy-uploads] [--yes]` |
| Enviar site para remoto | `cove push [--site ...] [--ssh ...] [--path ...] [--yes]` |
| URL pública (túnel) | `cove share [site] [--yes]` |
| Diagnóstico de transferência | `cove transfer probe [site]` |

- `--proxy-uploads` no `pull` baixa o site **sem** `wp-content/uploads` e configura o Caddy para `reverse_proxy` de mídia para o site de produção.
- `pull`/`push` usam o motor próprio do Cove (via SSH) e funcionam em hosts sem `zip`/`mysql`/WP-CLI.

### Rede

| Operação | Comando |
| :--- | :--- |
| Acesso LAN (mDNS/Bonjour) | `cove lan enable` / `cove lan trust` |
| Acesso via tailnet | `cove tailscale enable` |
| Ajustar portas | `cove ports --http 8090 --https 8453 [--yes] [--dry-run] [--skip-urls]` |
| Hosts para Windows (WSL2) | `cove wsl-hosts` |

- `cove ports` migra automaticamente os sites existentes com `wp search-replace --all-tables --skip-plugins --skip-themes`. Use `--dry-run` primeiro se estiver com receio.
- Portas fixas no Tailscale: Dashboard `9900`, Mailpit `9901`, Adminer `9902`.

### Banco de dados & serviços

| Operação | Comando |
| :--- | :--- |
| Backup de todos os bancos | `cove db backup` |
| Credenciais dos bancos | `cove db list` |
| Ajustar `memory_limit` | `cove memory [set <valor>] [--yes]` |
| Confiar no CA local | `cove trust` |
| Iniciar/parar serviços | `cove enable` / `cove disable` |
| Logs de erro | `cove log [site] [-f]` |
| Status da stack | `cove status [--porcelain]` |
| Diagnóstico completo | `cove health` |

### Manutenção & versões

| Operação | Comando |
| :--- | :--- |
| Versão de PHP por site | `cove php [site] [<versao>\|default]` |
| Verificar núcleo do WP | `cove core check` |
| Atualizar núcleo | `cove core update <site> [<versao>]` |
| Atualizar todos | `cove core update --all [--dry-run] [--yes]` |
| Atualizar o próprio Cove | `cove upgrade [--yes]` |
| Recarregar Caddy | `cove reload` |
| Versão do Cove | `cove version` |

### Customização

| Operação | Comando |
| :--- | :--- |
| Domínio extra para um site | `cove mappings add` |
| Reverse-proxy | `cove proxy add <nome> <dominio> <alvo> [--force]` / `cove proxy delete <nome> [--force]` |
| Regras Caddyfile por site | `cove directive add <site> [--rules "..."\|--file <path>\|stdin]` / `update` / `delete` / `list` |

---

## Descoberta de Serviços & URLs

Não hardcode portas nem hostnames: portas e domínios variam por máquina (`cove ports`) e via Tailscale. **A fonte de verdade são as URLs reportadas por `cove status`.**

- **Dashboard:** `https://cove.localhost` — cada site à vista, filtro com `/`, um clique para login, links para Adminer e Mailpit.
- **Mailpit (e-mails de teste):** `mailpit.localhost` — todo e-mail enviado pelo WordPress é capturado aqui.
- **Adminer (banco de dados):** acesso via dashboard/menubar (auto-login sem senha) ou direto pelo schema do site; no Tailscale usa a porta fixa `9902`.

---

## Banco de Dados & Credenciais

O Cove gerencia um MariaDB compartilhado para todos os sites.

```bash
cove db list      # Site, DB Name, DB User, DB Password e tamanho
cove db backup    # snapshot de cada banco em .sql com timestamp (não sobrescreve)
```

---

## Diagnóstico, Logs & Manutenção

```bash
cove health               # diagnóstico somente-leitura (serviços, crash do FrankenPHP, pressão de OPcache, higiene de disco)
cove log <nome> -f        # tail do log de erros, -f segue em tempo real
cove status --porcelain   # estado da stack em formato máquina
cove reload               # regenera Caddyfile + reload (erros apontam para caddy-reload.log)
cove trust                # instala o CA raiz local (resolve "conexão não privada" em *.localhost)
cove memory               # audita memory_limit; cove memory set 2G corrige "Allowed memory size exhausted"
cove enable / disable     # inicia/para Caddy, MariaDB e Mailpit juntos
cove upgrade              # atualiza o Cove (diferente de cove core update)
```

---

## Gotchas (comportamento do Cove que costuma surpreender)

- **Editor de imagens GD (não Imagick):** o MU-plugin do Cove força `WP_Image_Editor_GD` porque `Imagick` dentro do FrankenPHP causa crash (SIGSEGV). Se um plugin exigir Imagick, opte de volta com `add_filter( 'cove_force_gd_editor', '__return_false' )`.
- **Página de erro Whoops:** erros fatais e exceções não capturadas renderizam uma página bonita de crash; avisos comuns (`E_WARNING`) não viram tela cheia.
- **Login expira rápido:** o token de `cove login` tem 7 caracteres e expira em **15 minutos** — gere o link próximo do uso.
- **`cove upgrade` ≠ `cove core update`:** o primeiro atualiza o Cove (a ferramenta); o segundo atualiza o núcleo do WordPress dos sites.

---

## Quando NÃO usar

- **Sites estáticos:** `cove add <nome> --plain` cria site sem WordPress; comandos WP-CLI e `cove login` não se aplicam.
- **Domínio público/`*.com`:** o Cove gerencia `*.localhost`; para um site real use `cove pull`/`cove push` ou publique por outro meio.
- **Ambiente sem FrankenPHP/Cove:** se o WP local não foi criado pelo Cove, os comandos deste guia não se aplicam.

---

## Erros Comuns

| Erro | Causa | Correção |
| :--- | :--- | :--- |
| `command not found: wp` | `wp` não está no PATH | use `$(which wp)` ou o binário do WP-CLI do Cove |
| "conexão não privada" | CA raiz não instalado | `cove trust` |
| `Allowed memory size ... exhausted` | `memory_limit` baixo | `cove memory set 2G` |
| Comando trava sem TTY | prompt interativo em script | adicione `--yes`/`--force`/flags explícitas |
| URL errada de Adminer/Mailpit | hostname inventado | leia as URLs de `cove status` |
| `wp` do sistema usado por engano | PATH global | sempre use `PHPRC=~/Cove/php.ini frankenphp php-cli $(which wp)` |
