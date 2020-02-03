///////////////////////////////////////////////////////////////////////////////
//
//  Copyright (C) 2018-2019 Crossbar.io Technologies GmbH and contributors.
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

pragma solidity ^0.5.0;


contract XBRTest {
function coverage_0x8c0db600(bytes32 c__0x8c0db600) public pure {}

    // Adapted from: https://github.com/ethereum/EIPs/blob/master/assets/eip-712/Example.sol

    struct EIP712Domain {
        string  name;
        string  version;
        uint256 chainId;
        address verifyingContract;
    }

    struct Person {
        string name;
        address wallet;
    }

    struct Mail {
        Person from;
        Person to;
        string contents;
    }

    bytes32 constant EIP712DOMAIN_TYPEHASH = keccak256(
        "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"
    );

    bytes32 constant PERSON_TYPEHASH = keccak256(
        "Person(string name,address wallet)"
    );

    bytes32 constant MAIL_TYPEHASH = keccak256(
        "Mail(Person from,Person to,string contents)Person(string name,address wallet)"
    );

    bytes32 DOMAIN_SEPARATOR;

    constructor () public {coverage_0x8c0db600(0x2dc4644f16fc58d0deb4f3e55f62ef003b94268dadd728dc0be560db245b7dc6); /* function */ 

coverage_0x8c0db600(0xb1fe2e7b3f68f91351e39646926ebad6a5085d7b57462ecf06622dbb3e9616bd); /* line */ 
        coverage_0x8c0db600(0x9215a0ac19b2d3e5dde0d491819ce0e567842212169e5b3253d7e8d63e7e641b); /* statement */ 
DOMAIN_SEPARATOR = hash(EIP712Domain({
            name: "Ether Mail",
            version: "1",
            chainId: 1,
            // verifyingContract: this
            verifyingContract: 0xCcCCccccCCCCcCCCCCCcCcCccCcCCCcCcccccccC
        }));
    }

    function hash(EIP712Domain memory eip712Domain) internal pure returns (bytes32) {coverage_0x8c0db600(0x03bc766d31881778707859e7da1384adceddbbbc1299172a37c62a14ca281f71); /* function */ 

coverage_0x8c0db600(0xaa9796c302ff3983a898faae32fce962e6393c84144e78eec402dcea664486dc); /* line */ 
        coverage_0x8c0db600(0x9b82bbd7c734f92d6f16215f013efea0138eefec113546e74fd18d39080f792c); /* statement */ 
return keccak256(abi.encode(
            EIP712DOMAIN_TYPEHASH,
            keccak256(bytes(eip712Domain.name)),
            keccak256(bytes(eip712Domain.version)),
            eip712Domain.chainId,
            eip712Domain.verifyingContract
        ));
    }

    function hash(Person memory person) internal pure returns (bytes32) {coverage_0x8c0db600(0xb4e7f72a9f0369055201d7fb585a40504e06ee57e0af103264b72c286770ae62); /* function */ 

coverage_0x8c0db600(0x720236cfae76708f1712fb08e3775803db473a34dfa74d56e8fe194f49c2c4a7); /* line */ 
        coverage_0x8c0db600(0x1b154a81d869d6029f8d456b1e63ee83c0709a39832ca974e684857266c38e99); /* statement */ 
return keccak256(abi.encode(
            PERSON_TYPEHASH,
            keccak256(bytes(person.name)),
            person.wallet
        ));
    }

    function hash(Mail memory mail) internal pure returns (bytes32) {coverage_0x8c0db600(0xeb3c51edc17b6d8bfa6fb1ed9e6c323e2aebc017212b35925cfa256e2764a0e0); /* function */ 

coverage_0x8c0db600(0x4a08c48aab2f3b94d368d0c7e2ddf28ec9d35dfbe7167f29578c41051b32f40d); /* line */ 
        coverage_0x8c0db600(0x21d41888931fa2dabcb56f0d24a628091e832410f399a0d8b58786ccf5270619); /* statement */ 
return keccak256(abi.encode(
            MAIL_TYPEHASH,
            hash(mail.from),
            hash(mail.to),
            keccak256(bytes(mail.contents))
        ));
    }

    function verify(Mail memory mail, uint8 v, bytes32 r, bytes32 s) internal view returns (bool) {coverage_0x8c0db600(0xad41a9e702cff5fee1d940bc220ccf2d924d290e4c223c8b44a077ad20de7a2f); /* function */ 

        // Note: we need to use `encodePacked` here instead of `encode`.
coverage_0x8c0db600(0x879a863d149b3af8acc9c46fdc6d9aa74798df6f5aefed3deab1677caebda6f3); /* line */ 
        coverage_0x8c0db600(0xd8a1664a45d64f5030c23354a52cfed0ce1bb894a8c553fda79bf8f67854a6f6); /* statement */ 
bytes32 digest = keccak256(abi.encodePacked(
            "\x19\x01",
            DOMAIN_SEPARATOR,
            hash(mail)
        ));
coverage_0x8c0db600(0xd7281c7492e0f15b8b7421a16886c921752c3a1f27d2c24f5fabaa81dc026b8f); /* line */ 
        coverage_0x8c0db600(0xffc5693ba3235d25f8d6e1ea8d5fd243ff3dc9d30cd649646dad9c6843ee4920); /* statement */ 
return ecrecover(digest, v, r, s) == mail.from.wallet;
    }

    function splitSignature (bytes memory signature_rsv) private pure returns (uint8 v, bytes32 r, bytes32 s) {coverage_0x8c0db600(0xeccbad42b3c8ee395d1c05bcb3b533bc06d4b360357ed1a87d444437d482b6a6); /* function */ 


coverage_0x8c0db600(0xaa1a26e15f00035132af8e19ce9a20510380bc4fd52cc924cfe4ba5f882a7719); /* line */ 
        assembly {
            r := mload(add(signature_rsv, 32))
            s := mload(add(signature_rsv, 64))
            v := and(mload(add(signature_rsv, 65)), 255)
        }
coverage_0x8c0db600(0x2ca847708579d5e067531d938b997c3ebb9b31b6fbd4c758680ff346488e08f8); /* line */ 
        coverage_0x8c0db600(0x6f2849051ac060381c22ec4b66af22dad533a4b8d844f52f161a5f7c695b4940); /* statement */ 
if (v < 27) {coverage_0x8c0db600(0x3e1138da8abcf33283bac0fd6d3e7d54b2f7ac2a72ddda157caa4e0cf96255e0); /* branch */ 

coverage_0x8c0db600(0x8c1829ecdbd8e086ae8aef559b349b9268898c157a974de934c225f8430cf820); /* line */ 
            coverage_0x8c0db600(0x7a6bec1ca0e71edeb13352bf0ffac4601d8be8e28aa0c669d93e13053e8e3c35); /* statement */ 
v += 27;
        }else { coverage_0x8c0db600(0xfeed7f4198bb2c2e5dfcf74bbc5603b2c97e31e54a8914ee8fbce4120681dcd8); /* branch */ 
}
coverage_0x8c0db600(0x7f0161f63a1dde7c2dd1c0e5dbbe00b685d2c6584b6e25149b89b643f1ddf7a6); /* line */ 
        coverage_0x8c0db600(0x23e8aed8700d1a8bc8be762e2032071a9b4bc97e069451bc768435c350653cbd); /* statement */ 
return (v, r, s);
    }

    function test_verify1(address signer, string memory from_name, address from_wallet, string memory to_name,
        address to_wallet, string memory contents, bytes memory sig_rsv) public view returns (bool) {coverage_0x8c0db600(0x7bb22d3dabd0c26963fc90bb2b244dd96e99262bebba78c1a4dee64a74525549); /* function */ 


coverage_0x8c0db600(0x2ef677bfaa8822b52fdd6fa6baa57e528ec174d5f3d0e4e924a33ea1d62e564b); /* line */ 
        coverage_0x8c0db600(0x541a1120eb2f923053b8717602c632437b3c5f29e87b4155cff46053afa7d4b2); /* statement */ 
(uint8 v, bytes32 r, bytes32 s) = splitSignature(sig_rsv);

coverage_0x8c0db600(0x831a2156d712ed266ab6aa1429b3a221d3c13d42fadd3ed9d7eec2b4d5a89e2b); /* line */ 
        coverage_0x8c0db600(0xac3df5cc500cbd9e06de575cce75016893a5e363dbbbfaa0a6065e5b7db1d1d1); /* statement */ 
Mail memory mail = Mail({
            from: Person({
                name: from_name,
                wallet: from_wallet
            }),
            to: Person({
                name: to_name,
                wallet: to_wallet
            }),
            contents: contents
        });

coverage_0x8c0db600(0xd9347bc8510ab4c54e066fdd832335842fc67c04c92c2eaec78b9bdb57ad6ec0); /* line */ 
        coverage_0x8c0db600(0xa2e2bb999199e64ac12e19c05b47b65b81faac54da295071e3c6fc44a6ffaf7e); /* statement */ 
bytes32 digest = keccak256(abi.encodePacked(
            "\x19\x01",
            DOMAIN_SEPARATOR,
            hash(mail)
        ));

coverage_0x8c0db600(0x289ca72184f02d9c991fab58b83c7f83d8ffb151e353a3f061dd5c2f760c5a6b); /* line */ 
        coverage_0x8c0db600(0x277f48c5525942c27cf462abf9e1546e83ec5728b1bdd7f1a387354b989bda85); /* statement */ 
return ecrecover(digest, v, r, s) == signer;
    }

    function test_verify2(address signer, string memory from_name, address from_wallet, string memory to_name,
        address to_wallet, string memory contents, uint8 v, bytes32 r, bytes32 s) public view returns (bool) {coverage_0x8c0db600(0x78357e4c471bfd1cdaeeaaebe7050fbcfdcb6deef689c5bfd46471269f5ebb56); /* function */ 


coverage_0x8c0db600(0x253ed3d597ec47de6ec9bbd22d8585c4628097f9a799a121516d3f565116c69f); /* line */ 
        coverage_0x8c0db600(0x49c1ed2f56179d53ec62ce512993cc5f1a8667f4423c2307660a6ffdc32c9ce1); /* statement */ 
Mail memory mail = Mail({
            from: Person({
                name: from_name,
                wallet: from_wallet
            }),
            to: Person({
                name: to_name,
                wallet: to_wallet
            }),
            contents: contents
        });

coverage_0x8c0db600(0x4debec7133d62f0955754fda1cb0f888bca89e227fd35f400de7651b01507c68); /* line */ 
        coverage_0x8c0db600(0x80d29f984d34769e23ee44664d0fd499b35549d52a914db6dfe8cf28a21537f2); /* statement */ 
bytes32 digest = keccak256(abi.encodePacked(
            "\x19\x01",
            DOMAIN_SEPARATOR,
            hash(mail)
        ));

coverage_0x8c0db600(0xbe595492901833fd453dcd35656ef8124d079dc8c98b2f589139c2bb7f97b70c); /* line */ 
        coverage_0x8c0db600(0xc098307a1399667629eac42eeab89dc0f35eeab61c7c1c683ad2d96ff317e4f6); /* statement */ 
return ecrecover(digest, v, r, s) == signer;
    }

    function test() public view returns (bool) {coverage_0x8c0db600(0x4657c88689d49bc56565fb50c961a48974a239db809748938d41760f27e514d1); /* function */ 

        // Example signed message
coverage_0x8c0db600(0xcd6a2bcbc706e3c01723c42d06fdfc427e1f0a82c6161c074ff3476786c9c7cf); /* line */ 
        coverage_0x8c0db600(0x5718822d7e460131668573df1de58d3ce471d011cc8c82a1c25a6292dae323b1); /* statement */ 
Mail memory mail = Mail({
            from: Person({
                name: "Cow",
                wallet: 0xCD2a3d9F938E13CD947Ec05AbC7FE734Df8DD826
            }),
            to: Person({
                name: "Bob",
                wallet: 0xbBbBBBBbbBBBbbbBbbBbbbbBBbBbbbbBbBbbBBbB
            }),
            contents: "Hello, Bob!"
        });
coverage_0x8c0db600(0x25f7448bfb6c0f7ba4599e1ce7c606a2c4f282499b0d743114210fedcd684740); /* line */ 
        coverage_0x8c0db600(0x9d3a0a7900d73f0718f5d239f66e3bbfefd22dda5ab7fb2c87946fae00e8b289); /* statement */ 
uint8 v = 28;
coverage_0x8c0db600(0xcd5af17d77df717ca2a8565e36d6aeb479dd872fa4505e898dfd34c2be3116ff); /* line */ 
        coverage_0x8c0db600(0xe2bb7f78156b0d817f0ae850eaf9e6418d2b86d50e8deceece53f13ad3e4de67); /* statement */ 
bytes32 r = 0x4355c47d63924e8a72e509b65029052eb6c299d53a04e167c5775fd466751c9d;
coverage_0x8c0db600(0x4863adc7dc72f29d0067f1375b5b2abf6f8b731c7503d046a1c6c10bf09d178b); /* line */ 
        coverage_0x8c0db600(0x3e0e4b959e52c8f8e3946f9336e47b870e14046813e7a56af95aacd7251ab634); /* statement */ 
bytes32 s = 0x07299936d304c153f6443dfa05f40ff007d72911b6f72307f996231605b91562;

coverage_0x8c0db600(0x0ca20096b6188b860d299d1c5a7468e891e9b0e2a99ab3b9e32210f1d972cfb4); /* line */ 
        coverage_0x8c0db600(0x6f974a9bf65e050b9136741e7c9d0ba0f0ddbecfff12e4306b5a1e441eff0892); /* assertPre */ 
coverage_0x8c0db600(0x467dad95075f78c66b40e41fa9fc2b2122b43ad93b0de334d75c102a3eb13be3); /* statement */ 
assert(DOMAIN_SEPARATOR == 0xf2cee375fa42b42143804025fc449deafd50cc031ca257e0b194a650a912090f);coverage_0x8c0db600(0x2a36f834c7a40f2f35e8ed632a3238910582b1dfa5e0a6f0f264f4a27d1e12fb); /* assertPost */ 

coverage_0x8c0db600(0x4d633f621dd84ea6c1e131353e0be0adc679db19f736489893d9518f58bfee29); /* line */ 
        coverage_0x8c0db600(0xbcfb77a3b576d34ade6ba09e6ff71f2df03abab949fb9bfada6dd4b40031c42c); /* assertPre */ 
coverage_0x8c0db600(0xa31042be8391ffdf2023e605cd85ae83885557d1869c262d9adfc244b69c9806); /* statement */ 
assert(hash(mail) == 0xc52c0ee5d84264471806290a3f2c4cecfc5490626bf912d01f240d7a274b371e);coverage_0x8c0db600(0x0d8b2717079bbb27dfcb8a4601d4025cc266c9a63f6615ac42e5069a2debeb7e); /* assertPost */ 

coverage_0x8c0db600(0xdca4bcfcd4289e95026705b2df9bf0e830bf64540bc19f988eded265fb3e98ad); /* line */ 
        coverage_0x8c0db600(0x796a2fd139749cbc5e07412e42593066463366f8e156335e6a53a939dec15e67); /* assertPre */ 
coverage_0x8c0db600(0x0b5b5eb02855584a99414b533a69bdf77e4b3e40a9393e2bedeed33871eaf2f4); /* statement */ 
assert(verify(mail, v, r, s));coverage_0x8c0db600(0x15850e45f50893cc4fe01e5455d4a95091d14ee8eee1f8315159e4c0b224a134); /* assertPost */ 

coverage_0x8c0db600(0x7661350ebf75fd2e4cb2132278bf4b8408751684f550b781b95b86c81afbb16f); /* line */ 
        coverage_0x8c0db600(0xa8e6b2065e535c8512ab4b05011e46470c3730af0f10a78c49f2973219ae59b6); /* statement */ 
return true;
    }
}
