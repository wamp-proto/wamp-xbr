XBR Overview
============

XBR contains many moving parts. The following is a high-level overview of these parts and how they interact to provide the functionality for XBR data markets.

XBR is split into **on-chain** and **off-chain** parts.

The XBR smart contracts (the **on-chain part**) provide the functionality for central registration of market participants, markets and some interactions.

The bulk of the activity in XBR takes place **off-chain** within the data markets infrastructure, e.g. the actual data access and the setting of live balances between participants.


XBR Smart Contracts
-------------------

The **XBR token contract** is deployed once. This uses the OpenZeppelin (https://openzeppelin.org/) reference implementation for ERC20 tokens.

The **XBR network proxy contract** is deployed once and serves as a fixed entry point which redirects to the most current version of the XBR network contract.

The **XBR network contract** is deployed once. It is the central point for the registration of XBR network participants, XBR data markets and for the deployed XBR payment channels.

Instances of the **XBR payment channels** contract are deployed as required for the handling of payments in markets, where each channel is between a participant and the respective market maker component within a data market.


Participants
------------

Participants are natural persons or legal entities which act in the XBR network and markets.

To participate in the XBR network, registration as a participant with the XBR network contract is required.

Participants can then create data markets, join them and act as data providers and/or data consumers within markets.

A **market operator** is a participant who has registered (and is thus the owner of) a XBR data market. Market operators get an adjustable cut of transaction values within their data market.

A **data provider** is a participant in a data market who offers access to data within the market. Data providers can require payment for such data access and receive the proceeds (minus the cuts for the market provider and the XBR network).

A **data consumer** is a participant in a data market who accesses data offered by data providers within the market. Data consumers may have to pay for such access.

A participant can act as both data provider and data consumer within a data market.

Participants can have different roles across data markets.


Other Components
----------------

Data markets work mostly off-chain, and thus require technical infrastructure.

The off-chain functionality is built on the Crossbar.io message router, using a combination of existing Crossbar.io functionality and components added for XBR.

Individual Crossbar.io routers are called "**nodes**". For functioning as the infrastructure for a XBR data market, it needs to join the domain for that data market.

The **domain**, in turn, is registered for a particular data market.

The offering of data via PubSub and procedure calls is handled using standard Crossbar.io functionality. The events and the call results are end-to-end encrypted.

The transfer of these keys between a data provider and data consumer, and the payment generally involved in such transactions, is handled by a **market maker** component. This is run within Crossbar.io, and a single market maker handles all transactions within a data market.

The financial side of transactions (the transfer of XBR tokens) is handled through **state channels**. Both the data provider and the data consumer forming part of a transaction open a channel with the market maker. Unlike with the data transfer, which is directly between participants, there are no direct connections between both at this level.

Within the markets, data providers and data consumers do not act directly but through **delegates**. A delegate is a software component (usually an application) which is granted certain rights by a participant, e.g. that to use a payment channel for payments. A participant needs to have at least one delegate to be active in a data market, but can and often will have several delegates.
