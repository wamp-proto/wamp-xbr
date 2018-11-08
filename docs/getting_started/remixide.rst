.. _RemixIde:

Remix
=====

.. contents:: :local:

`Remix <https://remix.ethereum.org>`_ is a browser-only Solidity IDE and runtime environment.
It is available in a public hosted version, but can also be run locally as a NodeJS application.

For development, it is convenient to to give Remix access to a folder from your
host computer. For that, we recommend `remixd <https://remix.readthedocs.io/en/latest/tutorial_remixd_filesystem.html>`_.

Install **Remix** and **remixd**:

.. code-block:: console

    sudo npm install -g remix-ide
    sudo npm install -g remixd

Then start Remix in a first terminal:

.. code-block:: console

    remix-ide

and **remixd** in a second terminal:

.. code-block:: console

    remixd -s ${PWD}/contracts
