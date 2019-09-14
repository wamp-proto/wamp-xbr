Network Membership
==================

.. contents:: :local:

----------

Register in the Network
-----------------------

All stakeholders or participants in XBR, that is XBR Market Owners, XBR Data Providers and
XBR Data Consumers must be registered in the XBR Network first.

When registering in the XBR Network, users accept the XBR projects terms of use
and legal provisions, and optionally can submit a link to a user profile.

EULA
....

The XBR EULA of the XBR Network with end user license agreement, terms and
legal documents is published by the XBR Project on IPFS, and the current latest
version has the following `Multihash <https://multiformats.io/multihash/>`__ ID:

* XBR EULA on IPFS: ``QmU7Gizbre17x6V2VR1Q2GJEjz6m8S1bXmBtVxS2vmvb81``

Here is how to get the XBR EULA file and unzip the documents:

.. code-block:: console

    oberstet@thinkpad-x1:~$ cd /tmp
    oberstet@thinkpad-x1:/tmp$ ipfs get QmU7Gizbre17x6V2VR1Q2GJEjz6m8S1bXmBtVxS2vmvb81
    Saving file(s) to QmU7Gizbre17x6V2VR1Q2GJEjz6m8S1bXmBtVxS2vmvb81
    1.13 KiB / 1.13 KiB [=======================================================================================================] 100.00% 0s
    oberstet@thinkpad-x1:/tmp$ unzip QmU7Gizbre17x6V2VR1Q2GJEjz6m8S1bXmBtVxS2vmvb81
    Archive:  QmU7Gizbre17x6V2VR1Q2GJEjz6m8S1bXmBtVxS2vmvb81
    creating: xbr-eula/
    inflating: xbr-eula/README.txt
    inflating: xbr-eula/XBR-EULA.txt
    inflating: xbr-eula/COPYRIGHT.txt

Member Profile
..............

When registering on the XBR Network, a user (stakeholder) can have another
IPFS Multihash stored that points to a member profile file.
If provided, the file must be a `RDF/Turtle <https://www.w3.org/TR/turtle/>`__ file
with `FOAF <https://en.wikipedia.org/wiki/FOAF_(ontology)>`__ data.

.. note::

    .. figure:: /_static/img/Rdf_logo.svg
        :align: left
        :width: 60px
        :alt: RDF
        :figclass: align-left

    The `Resource Description Framework (RDF) <https://en.wikipedia.org/wiki/Resource_Description_Framework>`__
    is a family of World Wide Web Consortium (W3C) specifications originally designed as a metadata data model.
    RDF represents information using semantic triples, which comprise a subject, predicate,
    and object. Each item in the triple is expressed as a Web URI.

    .. figure:: /_static/img/rfd_triple.png
        :align: center
        :width: 100%
        :alt: RDF Triple
        :figclass: rdftriple

    `Terse RDF Triple Language (Turtle) <https://en.wikipedia.org/wiki/Turtle_(syntax)>`__
    is a syntax and file format for expressing data in the Resource Description Framework (RDF)
    data model.

    .. figure:: /_static/img/FoafLogo.svg
        :align: left
        :width: 60px
        :alt: FOAF
        :figclass: align-left

    `FOAF (an acronym of friend of a friend) <https://en.wikipedia.org/wiki/FOAF_(ontology)>`__
    is a machine-readable ontology describing persons,
    their activities and their relations to other people and objects. Anyone can use FOAF to
    describe themselves. FOAF allows groups of people to describe social networks without
    the need for a centralized database.

Here is an example FOAF member profile:

.. code-block:: console

    <rdf:RDF
        xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
        xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
        xmlns:foaf="http://xmlns.com/foaf/0.1/"
        xmlns:admin="http://webns.net/mvcb/">
    <foaf:PersonalProfileDocument rdf:about="">
    <foaf:maker rdf:resource="#me"/>
    <foaf:primaryTopic rdf:resource="#me"/>
    <admin:generatorAgent rdf:resource="http://www.ldodds.com/foaf/foaf-a-matic"/>
    <admin:errorReportsTo rdf:resource="mailto:leigh@ldodds.com"/>
    </foaf:PersonalProfileDocument>
    <foaf:Person rdf:ID="me">
    <foaf:name>Tobias Oberstein</foaf:name>
    <foaf:title>Mr</foaf:title>
    <foaf:givenname>Tobias</foaf:givenname>
    <foaf:family_name>Oberstein</foaf:family_name>
    <foaf:nick>oberstet</foaf:nick>
    <foaf:mbox_sha1sum>8c61973dd1948a8ca9f57a153c2502265c7787d8</foaf:mbox_sha1sum>
    <foaf:homepage rdf:resource="https://crossbar.io"/>
    <foaf:workplaceHomepage rdf:resource="https://crossbario.com"/></foaf:Person>
    </rdf:RDF>

.. tip::

    Instead of writing FOAF manually, `FOAF-a-Matic <http://www.ldodds.com/foaf/foaf-a-matic.html>`__
    is a browser-based JavaScript FOAF generator that allow to quickly create FOAF.
    If you want to process FOAF (and RDF in general) in Python, we recommend
    `rdflib <https://rdflib.readthedocs.io/en/stable/>`__

Upload your FOAF profile file to IPFS:

.. code-block:: console

    (cpy370_1) oberstet@thinkpad-x1:~$ ipfs add oberstet.rdf
    added QmdeJDNEimpjWPsHCVTDCowQSK9j1tpoW9eW3mjhrTw6wu oberstet.rdf
    3.42 KiB / 3.42 KiB [==========================================================================================================] 100.00%

The multihash ``QmdeJDNEimpjWPsHCVTDCowQSK9j1tpoW9eW3mjhrTw6wu`` returned is what you
provide to ``XBRNetwork.register`` (see below).

Given EULA and Member Profile, here is how to register in the XBR Network in
Python and JavaScript.

Register in Python
..................

.. code-block:: python

    def main(account):
        eula = 'QmU7Gizbre17x6V2VR1Q2GJEjz6m8S1bXmBtVxS2vmvb81'
        profile = 'QmdeJDNEimpjWPsHCVTDCowQSK9j1tpoW9eW3mjhrTw6wu'

        xbr.xbrNetwork.functions.register(eula, profile).transact({'from': account, 'gas': 1000000})

Register in JavaScript
......................

.. code-block:: javascript

    async function main (account) {
        const eula = 'QmU7Gizbre17x6V2VR1Q2GJEjz6m8S1bXmBtVxS2vmvb81'
        const profile = 'QmdeJDNEimpjWPsHCVTDCowQSK9j1tpoW9eW3mjhrTw6wu'

        await xbr.xbrNetwork.register(eula, profile, {from: account});
    }


Query Member Information
------------------------

Query Member in Python
......................

.. code-block:: python

    def main(account):

        level = xbr.xbrNetwork.functions.getMemberLevel(account).call()
        if (level):
            print('account is already member in the XBR network (level={})'.format(level))
        else:
            print('account is not yet member in the XBR network')

Query Member in JavaScript
..........................

.. code-block:: javascript

    async function main (account) {

        const level = await xbr.xbrNetwork.getMemberLevel(account);
        if (level > 0) {
            console.log('account is already member in the XBR network (level=' + level + ')');
        } else {
            console.log('account is not yet member in the XBR network');
        }
    }

Using the XBR ABI files, you can interact with the XBR smart contracts and e.g. register in the network
from within other programming languages.
