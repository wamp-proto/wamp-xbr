IPFS
====

`IPFS <https://ipfs.io/>`__ is ..

sha2-256

https://multiformats.io/multihash/

``<varint hash function code><varint digest size in bytes><hash function output>``

``0x12 0x20 <64 characters with HEX string for raw 32 bytes of SHA2-256>``


https://github.com/ipfs/faq/issues/22

https://github.com/ipfs/js-ipfs/issues/1205



https://github.com/ipfs/js-ipfs/tree/master/examples/browser-browserify


.. code-block:: console

    # sha2-256 0x12 - sha2-256("multihash")
    12209cbc07c3f991725836a3aa2a581ca2029198aa420b9d99bc0e131d9f3e2cbe47 # sha2-256 in hex
    CIQJZPAHYP4ZC4SYG2R2UKSYDSRAFEMYVJBAXHMZXQHBGHM7HYWL4RY= # sha256 in base32
    QmYtUc4iTCbbfVSDNKvtQqrfyezPPnFvE33wFmutw9PBBk # sha256 in base58
    EiCcvAfD+ZFyWDajqipYHKICkZiqQgudmbwOEx2fPiy+Rw== # sha256 in base64


`Install IPFS <https://docs.ipfs.io/introduction/install/>`__:

.. code-block:: console

    cd /tmp
    wget https://dist.ipfs.io/go-ipfs/v0.4.18/go-ipfs_v0.4.18_linux-amd64.tar.gz
    tar xvf go-ipfs_v0.4.18_linux-amd64.tar.gz
    sudo cp go-ipfs/ipfs /usr/local/bin/

Now run ``ipfs init`` (once as personal user):

.. code-block:: console

    oberstet@thinkpad-x1:~$ ipfs init
    initializing IPFS node at /home/oberstet/.ipfs
    generating 2048-bit RSA keypair...done
    peer identity: Qmf2BYtn692hqvQPRJQvUbUC228Ufoq1bn3cMsNW1iJc3P
    to get started, enter:

        ipfs cat /ipfs/QmS4ustL54uo8FzR9455qaxZwuMiUhyvMcX9Ba8nUH4uVv/readme

Then start the IPFS daemon with ``ipfs daemon``:

.. code-block:: console

    oberstet@thinkpad-x1:~$ ipfs daemon
    Initializing daemon...
    go-ipfs version: 0.4.18-
    Repo version: 7
    System version: amd64/linux
    Golang version: go1.11.1
    Successfully raised file descriptor limit to 2048.
    Swarm listening on /ip4/127.0.0.1/tcp/4001
    Swarm listening on /ip4/172.17.0.1/tcp/4001
    Swarm listening on /ip4/172.18.0.1/tcp/4001
    Swarm listening on /ip4/172.19.0.1/tcp/4001
    Swarm listening on /ip4/172.20.0.1/tcp/4001
    Swarm listening on /ip4/172.21.0.1/tcp/4001
    Swarm listening on /ip4/192.168.1.174/tcp/4001
    Swarm listening on /ip4/192.168.122.1/tcp/4001
    Swarm listening on /ip6/::1/tcp/4001
    Swarm listening on /p2p-circuit
    Swarm announcing /ip4/127.0.0.1/tcp/4001
    Swarm announcing /ip4/172.17.0.1/tcp/4001
    Swarm announcing /ip4/172.18.0.1/tcp/4001
    Swarm announcing /ip4/172.19.0.1/tcp/4001
    Swarm announcing /ip4/172.20.0.1/tcp/4001
    Swarm announcing /ip4/172.21.0.1/tcp/4001
    Swarm announcing /ip4/192.168.1.174/tcp/4001
    Swarm announcing /ip4/192.168.122.1/tcp/4001
    Swarm announcing /ip6/::1/tcp/4001
    API server listening on /ip4/127.0.0.1/tcp/5001
    Gateway (readonly) server listening on /ip4/127.0.0.1/tcp/8080
    Daemon is ready
