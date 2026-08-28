# Testes da Skill `cove-wp`

Este repositório segue a metodologia de teste de **skills de referência**
(retrieval, aplicação e lacunas) do framework *superpowers/writing-skills*:
a skill documenta uma CLI, então não há regras disciplinares para "violar sob
pressão" — testamos se os agentes **encontram** a informação certa, **aplicam**
corretamente e **não inventam** comandos/flags/hostnames.

## Como testar

Disparar um subagente por cenário, instruindo-o a **ler** o arquivo
`skills/cove-wp/SKILL.md` antes de responder (o agente deve basear a resposta
apenas no conteúdo da skill + conhecimento básico de WP-CLI).

## Critérios de aprovação

- ✅ O agente encontra e cita a seção correta da skill.
- ✅ Aplica o comando/flags exatos sem inventar nada.
- ✅ Em cenários de URL, consulta a máquina (`cove status`) em vez de chutar hostnames.
- ❌ Reprovação: flag, comando ou hostname não documentado no `SKILL.md`.

## Cenários

### 1. Execução de WP-CLI (aplicação)

**Prompt:** "Instale e ative o plugin 'woocommerce' no site WordPress local 'loja',
criado com Cove. Mostre a sequência EXATA de comandos (caminho + runtime PHP)."

**Esperado:** usar `PHPRC=~/Cove/php.ini frankenphp php-cli $(which wp) --path=$(cove path loja)`
e justificar por que **não** usar `wp` direto do PATH do sistema.

**Último resultado:** ✅ passou.

### 2. Descoberta de URLs (retrieval + lacunas)

**Prompt:** "Quais URLs abro para ver o banco de dados e os e-mails de teste?
A máquina usa portas customizadas."

**Esperado:** Dashboard `https://cove.localhost`, Mailpit `mailpit.localhost`,
Adminer via dashboard/menubar; confirmar tudo com `cove status`; **evitar**
informar `db.cove.localhost` / `mail.cove.localhost`.

**Último resultado:** ✅ passou.

### 3. Uso não interativo / agentes (aplicação)

**Prompt:** "Script de CI: (1) estado dos serviços de forma máquina-legível,
(2) atualizar núcleo do WP de todos os sites sem prompt, (3) excluir site
'poc-teste' sem prompt, (4) subir memory_limit para 2G sem interação."

**Esperado:** `cove status --porcelain`, `cove core update --all --yes`,
`cove delete poc-teste --force --yes`, `cove memory set 2G --yes`.

**Último resultado:** ✅ passou.

### 4. Migração via SSH (aplicação)

**Prompt:** "Baixar site de produção via SSH sem as mídias grandes (usar proxy de
uploads); depois enviar de volta; de forma não interativa."

**Esperado:** `cove pull --ssh <host> --proxy-uploads --yes` e
`cove push --ssh <host> --yes`; notar que `--force`/`--dry-run` **não** se aplicam
a `pull`/`push`.

**Último resultado:** ✅ passou.

### 5. Gotchas e diagnóstico (aplicação)

**Prompt:** Três problemas: crash em miniaturas + plugin que exige Imagick;
`Allowed memory size ... exhausted`; token de login inválido.

**Esperado:** filtro `add_filter('cove_force_gd_editor', '__return_false')`;
`cove memory set 2G`; expiração do token em **15 minutos**.

**Último resultado:** ✅ passou.

## Histórico

| Data | Veredito | Observação |
| :--- | :--- | :--- |
| 2026-08-28 | ✅ 5/5 | Todos os cenários passaram; nenhum agente inventou comando/flag/hostname |
