///////////////////////////////////////////////////////////////////////////////
//
//  Copyright (C) 2018-2020 Crossbar.io Technologies GmbH and contributors.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//
///////////////////////////////////////////////////////////////////////////////

pragma solidity ^0.6.0;
pragma experimental ABIEncoderV2;

// https://openzeppelin.org/api/docs/math_SafeMath.html
import "openzeppelin-solidity/contracts/math/SafeMath.sol";

import "./XBRMaintained.sol";
import "./XBRTypes.sol";
import "./XBRToken.sol";
import "./XBRNetwork.sol";


/// XBR API catalogs contract.
contract XBRDomain is XBRMaintained {

    // Add safe math functions to uint256 using SafeMath lib from OpenZeppelin
    using SafeMath for uint256;

    /// Event emitted when a new domain was created.
    event DomainCreated (bytes16 indexed domainId, uint32 domainSeq, XBRTypes.DomainStatus status, address owner,
        bytes32 domainKey, string license, string terms, string meta);

    /// Event emitted when a domain was updated.
    event DomainUpdated (bytes16 indexed domainId, uint32 domainSeq, XBRTypes.DomainStatus status, address owner,
        bytes32 domainKey, string license, string terms, string meta);

    /// Event emitted when a domain was closed.
    event DomainClosed (bytes16 indexed domainId, XBRTypes.DomainStatus status);

    /// Event emitted when a new node was paired with the domain.
    event NodePaired (bytes16 indexed domainId, bytes16 nodeId, bytes32 nodeKey, string config);

    /// Event emitted when a node was updated.
    event NodeUpdated (bytes16 indexed domainId, bytes16 nodeId, bytes32 nodeKey, string config);

    /// Event emitted when a node was released from a domain.
    event NodeReleased (bytes16 indexed domainId, bytes16 nodeId);

    /// Instance of XBRNetwork contract this contract is linked to.
    XBRNetwork public network;

    /// Created domains are sequence numbered using this counter (to allow deterministic collision-free IDs for domains)
    uint32 private domainSeq = 1;

    /// Current XBR Domains ("domain directory")
    mapping(bytes16 => XBRTypes.Domain) private domains;

    /// Current XBR Nodes ("node directory");
    mapping(bytes16 => XBRTypes.Node) private nodes;

    /// Index: node public key => (market ID, node ID)
    mapping(bytes32 => bytes16) private nodesByKey;

    /// List of IDs of current XBR Domains.
    bytes16[] public domainIds;

    // Constructor for this contract, only called once (when deploying the network).
    //
    // @param networkAdr The XBR network contract this instance is associated with.
    constructor (address networkAdr) public {
        network = XBRNetwork(networkAdr);
    }

    /// Create a new XBR domain.
    ///
    /// @param domainId The ID of the domain to create. Must be globally unique (not yet existing).
    /// @param domainKey The domain signing key. A Ed25519 (https://ed25519.cr.yp.to/) public key.
    /// @param license The license for the software stack running the domain. IPFS Multihash
    ///                pointing to a JSON/YAML file signed by the project release key.
    /// @param terms Multihash for terms that apply to the domain and to all APIs as published to this catalog.
    /// @param meta Multihash for optional domain meta-data.
    function createDomain (bytes16 domainId, bytes32 domainKey, string memory license, string memory terms,
        string memory meta) private {

        _createDomain(msg.sender, block.number, domainId, domainKey, license, terms, meta, "");
    }

    /// Create a new XBR domain.
    ///
    /// Note: This version uses pre-signed data where the actual blockchain transaction is
    /// submitted by a gateway paying the respective gas (in ETH) for the blockchain transaction.
    ///
    /// @param member Member that creates the domain and will become owner.
    /// @param created Block number when the catalog was created.
    /// @param domainId The ID of the domain to create. Must be globally unique (not yet existing).
    /// @param domainKey The domain signing key. A Ed25519 (https://ed25519.cr.yp.to/) public key.
    /// @param license The license for the software stack running the domain. IPFS Multihash
    ///                pointing to a JSON/YAML file signed by the project release key.
    /// @param terms Multihash for terms that apply to the domain and to all APIs as published to this catalog.
    /// @param meta Multihash for optional domain meta-data.
    /// @param signature Signature created by the member.
    function createDomainFor (address member, uint256 created, bytes16 domainId, bytes32 domainKey,
        string memory license, string memory terms, string memory meta, bytes memory signature) private {

        require(XBRTypes.verify(member, XBRTypes.EIP712DomainCreate(network.verifyingChain(), network.verifyingContract(),
            member, created, domainId, domainKey, license, terms, meta), signature),
            "INVALID_SIGNATURE");

        // signature must have been created in a window of 5 blocks from the current one
        require(created <= block.number && created >= (block.number - 4), "INVALID_BLOCK_NUMBER");

        _createDomain(member, created, domainId, domainKey, license, terms, meta, signature);
    }

    function _createDomain (address member, uint256 created, bytes16 domainId, bytes32 domainKey,
        string memory license, string memory terms, string memory meta, bytes memory signature) private {
        (, , , XBRTypes.MemberLevel member_level, ) = network.members(member);

        // the domain owner must be a registered member
        require(member_level == XBRTypes.MemberLevel.ACTIVE ||
                member_level == XBRTypes.MemberLevel.VERIFIED, "SENDER_NOT_A_MEMBER");

        // domain must not yet exist
        require(domains[domainId].owner == address(0), "DOMAIN_ALREADY_EXISTS");

        // store new domain object
        domains[domainId] = XBRTypes.Domain(domainSeq, XBRTypes.DomainStatus.ACTIVE, member,
            domainKey, license, terms, meta, new bytes16[](0));

        // add domainId to list of all domain IDs
        domainIds.push(domainId);

        // notify observers of new domains
        emit DomainCreated(domainId, domainSeq, XBRTypes.DomainStatus.ACTIVE, member,
            domainKey, license, terms, meta);

        // increment domain sequence for next domain
        domainSeq = domainSeq + 1;
    }

    /**
     * Close an existing XBR domain. The sender must be owner of the domain, and the domain
     * must not have any nodes paired (anymore).
     *
     * @param domainId The ID of the domain to close.
     */
    function closeDomain (bytes16 domainId) public {
        // require(members[msg.sender].level == MemberLevel.ACTIVE ||
        //         members[msg.sender].level == MemberLevel.VERIFIED, "NOT_A_MEMBER");
        // require(domains[domainId].owner != address(0), "NO_SUCH_DOMAIN");
        // require(domains[domainId].owner == msg.sender, "NOT_AUTHORIZED");
        // require(domains[domainId].status == DomainStatus.ACTIVE, "DOMAIN_NOT_ACTIVE");

        // // FIXME: check that the domain has no active objects associated anymore

        // domains[domainId].status = DomainStatus.CLOSED;

        // emit DomainClosed(domainId, DomainStatus.CLOSED);
    }

    /**
     * Returns domain status.
     *
     * @param domainId The ID of the domain to lookup status.
     * @return The current status of the domain.
     */
    function getDomainStatus(bytes16 domainId) public view returns (XBRTypes.DomainStatus) {
        return domains[domainId].status;
    }

    /**
     * Returns domain owner.
     *
     * @param domainId The ID of the domain to lookup owner.
     * @return The address of the owner of the domain.
     */
    function getDomainOwner(bytes16 domainId) public view returns (address) {
        return domains[domainId].owner;
    }

    /**
     * Returns domain (signing) key.
     *
     * @param domainId The ID of the domain to lookup key.
     * @return The Ed25519 public signing key for the domain.
     */
    function getDomainKey(bytes16 domainId) public view returns (bytes32) {
        return domains[domainId].domainKey;
    }

    /**
     * Returns domain license.
     *
     * @param domainId The ID of the domain to lookup license.
     * @return IPFS Multihash pointer to domain license file on IPFS.
     */
    function getDomainLicense(bytes16 domainId) public view returns (string memory) {
        return domains[domainId].license;
    }

    /**
     * Returns domain terms.
     *
     * @param domainId The ID of the domain to lookup terms.
     * @return IPFS Multihash pointer to domain terms on IPFS.
     */
    function getDomainTerms(bytes16 domainId) public view returns (string memory) {
        return domains[domainId].terms;
    }

    /**
     * Returns domain meta data.
     *
     * @param domainId The ID of the domain to lookup meta data.
     * @return IPFS Multihash pointer to domain metadata file on IPFS.
     */
    function getDomainMeta(bytes16 domainId) public view returns (string memory) {
        return domains[domainId].meta;
    }

    /**
     * Pair a node with an existing XBR Domain. The sender must be owner of the domain.
     *
     * @param nodeId The ID of the node to pair. Must be globally unique (not yet existing).
     * @param domainId The ID of the domain to pair the node with.
     * @param nodeType The type of node to pair the node under.
     * @param nodeKey The Ed25519 public node key.
     * @param config Optional IPFS Multihash pointing to node configuration stored on IPFS
     */
    function pairNode (bytes16 nodeId, bytes16 domainId, XBRTypes.NodeType nodeType, bytes32 nodeKey,
        string memory config) public {

        // require(domains[domainId].owner != address(0), "NO_SUCH_DOMAIN");
        // require(domains[domainId].owner == msg.sender, "NOT_AUTHORIZED");
        // require(uint8(nodes[nodeId].nodeType) == 0, "NODE_ALREADY_PAIRED");
        // require(nodesByKey[nodeKey] == bytes16(0), "DUPLICATE_NODE_KEY");
        // require(uint8(nodeType) == uint8(NodeType.MASTER) ||
        //         uint8(nodeType) == uint8(NodeType.EDGE), "INVALID_NODE_TYPE");

        // nodes[nodeId] = Node(domainId, nodeType, nodeKey, config);
        // nodesByKey[nodeKey] = nodeId;
        // domains[domainId].nodes.push(nodeId);

        // emit NodePaired(domainId, nodeId, nodeKey, config);
    }

    /**
     * Release a node currently paired with an XBR domain. The sender must be owner of the domain.
     *
     * @param nodeId The ID of the node to release.
     */
    function releaseNode (bytes16 nodeId) public {
        // require(uint8(nodes[nodeId].nodeType) != 0, "NO_SUCH_NODE");
        // require(domains[nodes[nodeId].domain].owner == msg.sender, "NOT_AUTHORIZED");

        // bytes16 domainId = nodes[nodeId].domain;
        // bytes32 nodeKey = nodes[nodeId].key;

        // nodes[nodeId].domain = bytes16(0);
        // nodes[nodeId].nodeType = NodeType.NULL;
        // nodes[nodeId].key = bytes32(0);
        // nodes[nodeId].config = "";

        // nodesByKey[nodeKey] = bytes16(0);

        // emit NodeReleased(domainId, nodeId);
    }

    /**
     * Lookup node ID by node public key.
     *
     * @param nodeKey The node public key to lookup
     * @return The Ed25519 public key of the node.
     */
    function getNodeByKey(bytes32 nodeKey) public view returns (bytes16) {
        return nodesByKey[nodeKey];
    }

    /**
     * Returns domain for a node.
     *
     * @param nodeId The ID of the node to lookup the domain for.
     * @return The domain the node is currently paired with.
     */
    function getNodeDomain(bytes16 nodeId) public view returns (bytes16) {
        return nodes[nodeId].domain;
    }

    /**
     * Returns node type for a node.
     *
     * @param nodeId The ID of the node to lookup the node type for.
     * @return The node type.
     */
    function getNodeType(bytes16 nodeId) public view returns (XBRTypes.NodeType) {
        return nodes[nodeId].nodeType;
    }

    /**
     * Returns node public key for a node.
     *
     * @param nodeId The ID of the node to lookup the node public key for.
     * @return The node public key.
     */
    function getNodeKey(bytes16 nodeId) public view returns (bytes32) {
        return nodes[nodeId].key;
    }

    /**
     * Returns config for a node.
     *
     * @param nodeId The ID of the node to lookup the config for.
     * @return IPFS Multihash pointer to node config.
     */
    function getNodeConfig(bytes16 nodeId) public view returns (string memory) {
        return nodes[nodeId].config;
    }
}
