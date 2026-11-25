# AGENTS.md — trytond (server core)

The Tryton application server: ORM, modules framework, RPC protocols (JSON-RPC, XML-RPC),
WSGI app, admin/cli tools. Upstream mirror of `code.tryton.org/trytond`.

## Layout (key directories)

- `trytond/` — the package. `model.py`, `models.py`, `ir/` (framework: ModelData, Attachments,
  Lang, Rule engine, cron), `res/` (users, groups, companies), `pool.py` (module registry),
  `wsgi.py`, `protocols/`, `tests/`
- `bin/` — server launchers
- `pyproject.toml` — deps + extras (`test`, `barcode`, `qrcode`, `email-validation`, `mjml`, ...)
- `tox.ini` — full matrix: py310–py314 × sqlite/postgresql

## Setup

`init.sh` at the repo root installs trytond (non-editable, upstream-tox-style) with test
extras into the shared venv `.venv`. Tests run against the installed copy in
`.venv/Lib/site-packages/trytond` — **so after editing source, refresh before testing**:

```bash
source .venv/Scripts/activate
pip install --no-deps src/trytond      # fast local rebuild, no network
```

## Testing

Always set before running tests:

```bash
export TRYTOND_DATABASE_URI=sqlite://
export DB_NAME=:memory:
```

```bash
cd src/trytond
python -m unittest trytond.tests.test_<name>      # targeted (start here)
python -m unittest discover -s trytond.tests      # full core suite (slow, hundreds of modules)
```

Notes:
- Tests are DB-integration tests that self-provision sqlite databases — no server needed.
- PostgreSQL variants require a local server; only use when testing backend-specific code.
- New tests go in `trytond/tests/`, named `test_<topic>.py`.

## Conventions

- GPL-3.0 header block at the top of every source file (copy from an existing file).
- Upstream is conservative about new dependencies — don't add third-party packages without asking.
- Keep upstream naming, file order, and docstring style (`__all__` at module top).
- `hatch_build.py` + `hatch-tryton` derive version from `CHANGELOG` — don't hand-edit version fields.
- Windows caveat: file-path resolution in `trytond.tools.misc.find_path` splits on `os.sep`, so
  core `ir`/`res` XML loading works but third-party-module `test_xml_files` tests fail on Windows
  (path quirk, not content). Everything else in the suite runs against the sqlite backend.
