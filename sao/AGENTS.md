# AGENTS.md — sao (web client)

Tryton's JavaScript web client (Grunt build, QUnit tests). Upstream mirror of
`code.tryton.org/sao`.

## Layout

- `src/` — ES modules (sao.js entry, `gui/`, `view/`, `action/`, `model.js`, ...)
- `tests/` — QUnit test HTML pages (`*.html` per test file)
- `Gruntfile.js` — build tasks: `concat`, `less`, `qunit`, `test`, `msgmerge`/`xgettext` (i18n)
- `locale/` — translation files

## Setup & Verification

```bash
cd src/sao
npm install          # once; pulls grunt + toolchain
npm run check        # eslint over src + tests — fast, preferred quick check
npm test             # grunt test: concat + less + QUnit — needs headless Chromium
```

`npm test` may fail on this Windows machine (headless browser dependency). If it fails for
environment reasons, fall back to `npm run check` and record that as Verification Evidence —
state clearly which command ran.

## Conventions

- Keep upstream JS style (ESLint config: `eslint.config.mjs`) — run `npm run check` after changes.
- New UI behavior gets a QUnit test page in `tests/` and a matching entry in `Gruntfile.js`
  qunit file list if needed.
- Translatable strings use the sao i18n helpers; regenerating locale files uses grunt
  `xgettext`/`msgmerge` tasks (requires the sao toolchain, not a manual edit).
