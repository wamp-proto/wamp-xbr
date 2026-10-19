Release Notes
=============

This page provides links to release artifacts for each version of wamp-xbr.

For detailed changelog entries, see :doc:`changelog`.

26.10.1
-------

**Release Date:** 2026-10-19

**Release Type:** Stable release

Release Artifacts
^^^^^^^^^^^^^^^^^

* Wheel: ``xbr-26.10.1-py3-none-any.whl``
* Source: ``xbr-26.10.1.tar.gz``

Release Links
^^^^^^^^^^^^^

* `GitHub Release <https://github.com/crossbario/wamp-xbr/releases/tag/v26_10_1>`__
* `PyPI Package <https://pypi.org/project/xbr/26.10.1/>`__
* `Documentation <https://xbr.readthedocs.io/en/v26.10.1/>`__

**Detailed Changes:** See :doc:`changelog` (26.10.1 section)


26.6.1
------

**Release Date:** 2026-06-19

**Release Type:** Stable release

Release Artifacts
^^^^^^^^^^^^^^^^^

* Wheel: ``xbr-26.6.1-py3-none-any.whl``
* Source: ``xbr-26.6.1.tar.gz``

Release Links
^^^^^^^^^^^^^

* `GitHub Release <https://github.com/crossbario/wamp-xbr/releases/tag/v26_6_1>`__
* `PyPI Package <https://pypi.org/project/xbr/26.6.1/>`__
* `Documentation <https://xbr.readthedocs.io/en/v26.6.1/>`__

**Detailed Changes:** See :doc:`changelog` (26.6.1 section)


25.12.2
-------

**Release Date:** 2025-12-17

**Release Type:** Stable release

Release Artifacts
^^^^^^^^^^^^^^^^^

* Wheel: ``xbr-25.12.2-py3-none-any.whl``
* Source: ``xbr-25.12.2.tar.gz``

Release Links
^^^^^^^^^^^^^

* `GitHub Release <https://github.com/wamp-proto/wamp-xbr/releases/tag/v25.12.2>`__
* `PyPI Package <https://pypi.org/project/xbr/25.12.2/>`__
* `Documentation <https://xbr.readthedocs.io/en/v25.12.2/>`__

**Detailed Changes:** See :doc:`changelog` (25.12.2 section)


25.12.1
-------

* `GitHub Release <https://github.com/wamp-proto/wamp-xbr/releases/tag/v25.12.1>`__
* `PyPI Package <https://pypi.org/project/xbr/25.12.1/>`__
* `Documentation <https://xbr.readthedocs.io/en/v25.12.1/>`__

21.2.1
------

* `GitHub Release <https://github.com/wamp-proto/wamp-xbr/releases/tag/v21.2.1>`__
* `PyPI Package <https://pypi.org/project/xbr/21.2.1/>`__

21.1.1
------

* `GitHub Release <https://github.com/wamp-proto/wamp-xbr/releases/tag/v21.1.1>`__
* `PyPI Package <https://pypi.org/project/xbr/21.1.1/>`__

20.5.1
------

* `GitHub Release <https://github.com/wamp-proto/wamp-xbr/releases/tag/v20.5.1>`__
* `PyPI Package <https://pypi.org/project/xbr/20.5.1/>`__

20.4.2
------

* `GitHub Release <https://github.com/wamp-proto/wamp-xbr/releases/tag/v20.4.2>`__
* `PyPI Package <https://pypi.org/project/xbr/20.4.2/>`__

20.4.1
------

* `GitHub Release <https://github.com/wamp-proto/wamp-xbr/releases/tag/v20.4.1>`__
* `PyPI Package <https://pypi.org/project/xbr/20.4.1/>`__

20.3.1
------

* `GitHub Release <https://github.com/wamp-proto/wamp-xbr/releases/tag/v20.3.1>`__
* `PyPI Package <https://pypi.org/project/xbr/20.3.1/>`__

20.2.2
------

* `GitHub Release <https://github.com/wamp-proto/wamp-xbr/releases/tag/v20.2.2>`__
* `PyPI Package <https://pypi.org/project/xbr/20.2.2/>`__

20.2.1
------

* `GitHub Release <https://github.com/wamp-proto/wamp-xbr/releases/tag/v20.2.1>`__
* `PyPI Package <https://pypi.org/project/xbr/20.2.1/>`__

--------------

.. _release-workflow:

Release Workflow (for Maintainers)
----------------------------------

This section documents the release process for maintainers.

Prerequisites
^^^^^^^^^^^^^

Before releasing, ensure you have:

* Push access to the repository
* PyPI credentials configured (or trusted publishing via GitHub Actions)
* ``just`` and ``uv`` installed

Step 1: Draft the Release
^^^^^^^^^^^^^^^^^^^^^^^^^

Generate changelog and release note templates:

.. code-block:: bash

   # Generate changelog entry from git history (for catching up)
   just prepare-changelog <version>

   # Generate release draft with templates for both files
   just draft-release <version>

This will:

* Add a changelog entry template to ``docs/changelog.rst``
* Add a release entry template to ``docs/releases.rst``
* Update the version in ``package.json``

Step 2: Edit Changelog
^^^^^^^^^^^^^^^^^^^^^^

Edit ``docs/changelog.rst`` and fill in the changelog details:

* **New**: New features and capabilities
* **Fix**: Bug fixes
* **Other**: Breaking changes, deprecations, other notes

Step 3: Validate the Release
^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Ensure everything is in place:

.. code-block:: bash

   just prepare-release <version>

This validates:

* Changelog entry exists for this version
* Release entry exists for this version
* Version in ``package.json`` matches
* All tests pass
* Documentation builds successfully

Step 4: Disable Git Hooks (if needed)
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: bash

   git config core.hooksPath /dev/null
   git config core.hooksPath

Step 5: Commit and Tag
^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: bash

   git add docs/changelog.rst docs/releases.rst package.json
   git commit -m "Release <version>"
   git tag v<version>
   git push && git push --tags

Step 6: Enable Git Hooks (if previously disabled)
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: bash

   git config core.hooksPath .ai/.githooks
   git config core.hooksPath

Step 7: Automated Release
^^^^^^^^^^^^^^^^^^^^^^^^^

After pushing the tag:

1. GitHub Actions builds and tests the release
2. Wheels and source distributions are uploaded to GitHub Releases
3. PyPI publishing is triggered via trusted publishing (OIDC)
4. Read the Docs builds documentation for the tagged version

Manual PyPI Upload (if needed)
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

If automated publishing fails:

.. code-block:: bash

   just download-github-release v<version>
   just publish-pypi "" v<version>
