<!-- Managed in https://github.com/teamniteo/claude — edit there, not here.
     If you have project-specific instructions to add, README.md is the best place. -->

---
paths:
  - "backend/**/*"
---

# Backend

Read the @backend/README.md for project-specific context.

Read @backend/Makefile to learn which commands are available for backend development and testing. Most common commands are:

* `make up` - start Postgres and Redis
* `make check` - run static analysis on changed files
* `make unit` - run unit tests
* `make devdb` - populate the local DB with dummy data
* `make run` - start the Pyramid server

Before every commit you should run `make test` which runs all of the above.

## Folder Structure

```
backend/
├── src/
│   ├── foo/                 # Main application
│   │   ├── auth/            # Authentication & authorization
│   │   ├── db/              # Database layer & Alembic migrations
│   │   ├── email/           # Transactional emails
│   │   ├── static/          # Static file serving (including frontend dist)
│   │   ├── trail/           # Audit trail
│   │   ├── tweens/          # Pyramid middleware (CSP, OpenAPI hash)
│   │   ├── <module>/        # Each business-logic domain has its own module
│   │   ├── cors.py          # CORS configuration
│   │   ├── customerio.py    # Customer.io integration
│   │   ├── logs.py          # Logging configuration
│   │   ├── metrics.py       # Prometheus metrics collection
│   │   ├── openapi.py       # OpenAPI schema integration
│   │   └── redis.py         # Redis client configuration
│   └── bar/                 # Additional vendored dependencies
├── etc/                     # Environment configs (development/production/test.ini)
├── pyproject.toml           # Python project configuration
├── Procfile                 # Heroku process definitions
└── process-compose.yml      # Development server configuration
```

### `src/foo/<module>/`

Each business-logic domain has its own module, following this structure:

```
<module>/
├── models.py        # SQLAlchemy models, JSON renderers and permissions
├── views.py         # Pyramid OpenAPI views
└── tests/           # pytest tests specific to this module
    ├── test_<module>_models.py # tests for models.py
    └── test_<module>_views.py  # tests for views.py
```

If the domain is small, then models and views can be in the `<module>.py` file
and the tests in a single `test_<module>.py` file in the top-level `tests/` folder.

## Code Style

- Error handling: Use HTTP exceptions with JSON payloads, proper status codes
- Docstrings: Brief first line, details after blank line. Never use `Args:` and `Returns:` - use type annotations instead

## Testing

- 100% test coverage is enforced.
- Write tests for all new features and bug fixes.
- Follow the naming pattern of existing test files and cases.
- Use the `responses` library for mocking external HTTP requests - **never use `@patch`**.
- Use `freezegun` for time-dependent tests.

## Playwright

Help the user by giving them this advice:
- `make browsertests` runs all browser tests in headless mode.
- `make browsertests filter="foo"` runs browser tests matching "foo", in headed mode.
- Force headed mode by prepending `PWDEBUG=1 ` to the command. Remind the user to click the "play" icon in Playwright inspector window for tests to actually start running.

### Troubleshooting

### DB manipulation in `pshell`

In `pshell` you can manipulate the DB via `request.db` shortcut, but you need
to wrap it in a transaction. For example:

```python
# pshell etc/development.ini
>>> with request.tm:
...     from foo.models import Foo
...     request.db.add(Foo(bar='bam'))
>>>
```

### RuntimeError: Failed creating fsevent stream

If you see this error when running `make run`, it means your file descriptor limits are too low.

Run `ulimit -n` to confirm the limit. If it's less than 4096, you can increase it by running `ulimit -n 4096`. To make the increase permanent, either add `ulimit -n 4096` to your shell profile or increase the limit in `/etc/security/limits.conf`. On a nix-darwin setup, you do it like this:
https://github.com/zupo/dotfiles/commit/81f34f0f4a0db7a851bfbd789dbf1c8ea309e58a
