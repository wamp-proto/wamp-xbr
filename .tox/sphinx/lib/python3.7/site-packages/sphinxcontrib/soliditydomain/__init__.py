import os

from .domain import SolidityDomain
from .documenters import all_solidity_documenters
from .sourceregistry import build_source_registry, teardown_source_registry

with open(os.path.join(os.path.dirname(__file__), 'VERSION')) as version_file:
    __version__ = version_file.read().strip()

def setup(app):
    app.add_config_value('autodoc_lookup_path',
                         os.path.join('..', 'contracts'), 'env')

    app.add_domain(SolidityDomain)

    app.connect('builder-inited', build_source_registry)
    app.connect('env-before-read-docs', read_all_docs)
    app.connect('build-finished', teardown_source_registry)

    for documenter in all_solidity_documenters.values():
        app.add_autodocumenter(documenter)


def read_all_docs(app, env, doc_names):
    """Add all found docs to the to-be-read list, because we have no way of
    telling which ones reference Solidity that might have changed.

    Otherwise, builds go stale until you touch the stale RSTs or do a ``make
    clean``.

    This is straight-up lifted from `sphinx-js <https://github.com/erikrose/sphinx-js#sphinx-js>`_.

    """
    doc_names[:] = env.found_docs
