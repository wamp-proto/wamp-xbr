Changelog
=========

This document contains a reverse-chronological list of changes to wamp-xbr.

.. note::

    For detailed release information including artifacts,
    see :doc:`releases`.

Unreleased
----------

*No unreleased changes yet.*

26.6.1 (2026-06-19)
-------------------

**Dependencies**

* Require ``autobahn >= 26.6.2`` and ``zlmdb >= 26.6.1`` for the coordinated WAMP 26.6.1 release. xbr uses ``zlmdb.flatbuffers.reflection`` together with autobahn, so it needs the FlatBuffers-compatible pair (autobahn synced to FlatBuffers v25.12.19 at 26.6.1). The autobahn floor is ``26.6.2`` specifically because ``import xbr`` pulls in ``autobahn.wamp.cryptosign``, whose import was broken on CPython 3.11/3.12/3.13 in autobahn 26.6.1 (autobahn #1878). ``txaio`` is left at its existing permissive floor (`#176 <https://github.com/crossbario/wamp-xbr/issues/176>`_)

**Build & CI/CD**

* Bump the shared ``wamp-ai`` (→ ``4669dc8``) and ``wamp-cicd`` (→ ``f77ca2b``) Git submodules to match the rest of the WAMP project group; the ``wamp-cicd`` bump carries the GHSA-6658 shell-injection hardening in the shared ``identifiers.yml`` reusable workflow (`#176 <https://github.com/crossbario/wamp-xbr/issues/176>`_)
* Converge the GitHub Discussions release announcement onto a single mechanism, matching autobahn-python / txaio / cfxdb: the ``release-post-comment.yml`` workflow now resolves the ``ci-cd`` Discussions category **by name** (case-insensitive) and posts for both nightly and stable releases, and the redundant ``softprops`` ``discussion_category_name`` was removed from the release steps so a release posts exactly one announcement (`#176 <https://github.com/crossbario/wamp-xbr/issues/176>`_)
* Fix the ``ty`` type-checker config for current ty: rename the removed rule ``non-subscriptable`` → ``not-subscriptable`` (an unknown ``--ignore`` rule is a fatal error) and ignore ``possibly-missing-submodule`` (a false positive from zlmdb's dynamic FlatBuffers re-exports) (`#176 <https://github.com/crossbario/wamp-xbr/issues/176>`_)
* Remove the obsolete ``.github/workflows/deploy.yml.orig`` attic file (`#176 <https://github.com/crossbario/wamp-xbr/issues/176>`_)

25.12.2 (2025-12-17)
--------------------

**New**

* Added comprehensive smoke tests for wheel and sdist installation verification (#168)
* Added ``test-wheel-install`` and ``test-sdist-install`` recipes for CI verification
* Added Python 3.14 support to test matrix and classifiers

**Fix**

* Fixed wheel missing ``xbr/abi/`` directory with compiled Solidity ABIs (#168)
* Fixed yapf import for Python 3.13+ compatibility (lib2to3 was removed)
* Fixed CI to verify final built wheel in clean, separate venv (#168)

**Other**

* Updated zlmdb dependency to >=25.12.3 (fixes FlatBuffers reflection imports)
* Added verify job to main.yml workflow for distribution testing

25.12.1 (2025-12-16)
--------------------

**New**

* Modernized build system: migrated from setup.py to pyproject.toml with hatch backend
* Added comprehensive just recipes for development workflow (create, install-dev, check, test, docs, dist)
* Added uv for fast Python environment management
* Added ruff for code formatting and linting (replaces flake8/black)
* Added ty (Astral) for type checking
* Added Sphinx documentation with MyST Markdown support and furo theme
* Added sphinx-autoapi for automatic API documentation generation
* Modernized CI/CD workflows with chain-of-custody verification using wamp-cicd reusable actions

**Fix**

* Fixed import sorting (I001) errors across source files
* Fixed documentation build configuration for Read the Docs
* Fixed release.yml workflow check-release-fileset parameters (wheel was missing from releases)
* Aligned justfile download-github-release recipe with autobahn-python/zlmdb/cfxdb
* Synced package.json version with pyproject.toml (was 21.4.1)

**Other**

* Updated dependencies: autobahn>=25.12.2, txaio>=25.12.2, zlmdb>=25.12.2
* Rewrote download-github-release recipe to use curl (no gh auth required)
* Added Python 3.11, 3.12, 3.13 support in CI
* Dropped Python 3.9, 3.10 support (minimum is now Python 3.11)

..
    Format for entries:

    vX.Y.Z (YYYY-MM-DD)
    -------------------

    **New**

    * Description of new feature (#issue)

    **Fix**

    * Description of bug fix (#issue)

    **Other**

    * Description of other changes (#issue)
