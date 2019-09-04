IPFS
====

`IPFS <https://ipfs.io/>`__ is ..

``sha2-256``

https://multiformats.io/multihash/

``<varint hash function code><varint digest size in bytes><hash function output>``

``0x12 0x20 <64 characters with HEX string for raw 32 bytes of SHA2-256>``


https://github.com/ipfs/faq/issues/22

https://github.com/ipfs/js-ipfs/issues/1205



https://github.com/ipfs/js-ipfs/tree/master/examples/browser-browserify


Using curl to interact with IPFS
--------------------------------

Store a file on IPFS via Infura as gateway, and using ``curl``:

.. code-block:: console

    oberstet@intel-nuci7:/tmp$ echo "Hello, world!" > test.txt
    oberstet@intel-nuci7:/tmp$ openssl sha256 test.txt
    SHA256(test.txt)= d9014c4624844aa5bac314773d6b689ad467fa4e1d1a50a1b8a99d5a95f72ff5
    oberstet@intel-nuci7:/tmp$ curl "https://ipfs.infura.io:5001/api/v0/add?pin=false" -X POST -H "Content-Type: multipart/form-data" -F file=@"test.txt"
    {"Name":"test.txt","Hash":"QmeeLUVdiSTTKQqhWqsffYDtNvvvcTfJdotkNyi1KDEJtQ","Size":"22"}
    oberstet@intel-nuci7:/tmp$ curl "https://ipfs.infura.io:5001/api/v0/cat?arg=QmeeLUVdiSTTKQqhWqsffYDtNvvvcTfJdotkNyi1KDEJtQ" | openssl sha256
    % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                    Dload  Upload   Total   Spent    Left  Speed
    100    14  100    14    0     0     29      0 --:--:-- --:--:-- --:--:--    29
    (stdin)= d9014c4624844aa5bac314773d6b689ad467fa4e1d1a50a1b8a99d5a95f72ff5


Retrieve a file from IPFS via Infura as gateway, and using ``curl``:

.. code-block:: console

    oberstet@intel-nuci7:/tmp$ curl "https://ipfs.infura.io:5001/api/v0/cat?arg=QmeeLUVdiSTTKQqhWqsffYDtNvvvcTfJdotkNyi1KDEJtQ" --output test.bak
    % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                    Dload  Upload   Total   Spent    Left  Speed
    100    14  100    14    0     0     28      0 --:--:-- --:--:-- --:--:--    28
    oberstet@intel-nuci7:/tmp$ diff test.txt test.bak
    oberstet@intel-nuci7:/tmp$

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
