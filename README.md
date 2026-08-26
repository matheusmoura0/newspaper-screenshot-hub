# Newspaper Screenshot Hub

Plataforma interna para capturar, organizar e consultar screenshots diários de páginas de jornais.

## MVP

- Contas e senhas gerenciadas por administradores
- Perfis de administrador e membro
- Cadastro e configuração de jornais
- Capturas desktop e mobile
- Acervo organizado por data
- Histórico, falhas e reprocessamento
- Deploy no Render com PostgreSQL e disco persistente

## Stack

- Ruby on Rails 8.1
- PostgreSQL
- Hotwire
- Active Storage
- Playwright/Chromium
- Render

## Desenvolvimento local

Pré-requisitos: Ruby 3.3, PostgreSQL, Python 3 e Chromium do Playwright.

```bash
cp .env.example .env
bundle install
pip3 install -r requirements.txt
python3 -m playwright install chromium
bin/rails db:prepare db:seed
bin/dev
```

## Capturas

Executar todos os jornais ativos:

```bash
bin/rails captures:run
```

Reprocessar falhas de uma data:

```bash
DATE=2026-08-26 bin/rails captures:retry_failed
```

Cada jornal pode configurar seletores e tempos específicos no campo JSON `capture_options`, incluindo `wait_for_selector`, `click_selectors`, `hide_selectors`, `extra_delay_ms` e timeouts.

## Render

O `render.yaml` cria:

- serviço web Rails;
- PostgreSQL;
- disco persistente de 10 GB montado em `/rails/storage`;
- execução do Solid Queue dentro do Puma;
- captura diária às 11:00 UTC (08:00 em São Paulo) pelo próprio serviço web.

Antes do primeiro deploy, preencha `ADMIN_EMAIL` e `ADMIN_PASSWORD`. Não é necessário configurar S3 nem SMTP. Os usuários são criados pelo administrador, com uma senha inicial compartilhada diretamente.

As imagens ficam no volume persistente do Render. O serviço deve permanecer com uma única instância, pois esse disco não é compartilhado horizontalmente. O disco evita a perda de arquivos em deploys e reinicializações, mas ainda é recomendado manter um backup externo periódico do acervo.

## Fluxo Git

A branch `main` é mantida estável e o desenvolvimento acontece em `develop` por meio do PR rascunho do MVP.
