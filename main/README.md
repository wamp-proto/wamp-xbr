# XBR Network contracts reference

This is the API reference documentation of the XBR Network contracts for the Ethereum blockchain.

> The documentation is generated from the annotate Solidity source code using [solmd](http://danepilcher.com/solmd/). To regenerate this file, type `make docs`. This will take the [README.tmpl.md](README.tmpl.md) header template, append the generated API docs in Markdown formatting, and write a new [README.md](README.md) - this file.

---

## Reference

* [Greeter](#greeter)
  * [setGreeting](#function-setgreeting)
  * [greet](#function-greet)
  * [greeting](#function-greeting)
* [XBRMarket](#xbrmarket)
  * [register_service](#function-register_service)
  * [register_api](#function-register_api)
* [XBRNetwork](#xbrnetwork)
  * [register_domain](#function-register_domain)
  * [verify_domain](#function-verify_domain)
  * [get_domain](#function-get_domain)
  * [register_market](#function-register_market)
  * [network_token](#function-network_token)
  * [get_market](#function-get_market)
  * [dns_oracle](#function-dns_oracle)
  * [is_signed_by](#function-is_signed_by)
  * [get_agent](#function-get_agent)
  * [register_agent](#function-register_agent)
  * [network_sponsor](#function-network_sponsor)
* [XBRToken](#xbrtoken)
  * [name](#function-name)
  * [approve](#function-approve)
  * [totalSupply](#function-totalsupply)
  * [transferFrom](#function-transferfrom)
  * [INITIAL_SUPPLY](#function-initial_supply)
  * [decimals](#function-decimals)
  * [decreaseApproval](#function-decreaseapproval)
  * [balanceOf](#function-balanceof)
  * [symbol](#function-symbol)
  * [transfer](#function-transfer)
  * [increaseApproval](#function-increaseapproval)
  * [allowance](#function-allowance)
  * [Approval](#event-approval)
  * [Transfer](#event-transfer)
* [BasicToken](#basictoken)
  * [totalSupply](#function-totalsupply)
  * [balanceOf](#function-balanceof)
  * [transfer](#function-transfer)
  * [Transfer](#event-transfer)
* [ERC20](#erc20)
  * [approve](#function-approve)
  * [totalSupply](#function-totalsupply)
  * [transferFrom](#function-transferfrom)
  * [balanceOf](#function-balanceof)
  * [transfer](#function-transfer)
  * [allowance](#function-allowance)
  * [Approval](#event-approval)
  * [Transfer](#event-transfer)
* [ERC20Basic](#erc20basic)
  * [totalSupply](#function-totalsupply)
  * [balanceOf](#function-balanceof)
  * [transfer](#function-transfer)
  * [Transfer](#event-transfer)
* [SafeMath](#safemath)
* [StandardToken](#standardtoken)
  * [approve](#function-approve)
  * [totalSupply](#function-totalsupply)
  * [transferFrom](#function-transferfrom)
  * [decreaseApproval](#function-decreaseapproval)
  * [balanceOf](#function-balanceof)
  * [transfer](#function-transfer)
  * [increaseApproval](#function-increaseapproval)
  * [allowance](#function-allowance)
  * [Approval](#event-approval)
  * [Transfer](#event-transfer)

# Greeter


## *function* setGreeting

Greeter.setGreeting(_greeting) `nonpayable` `a4136862`


Inputs

| | | |
|-|-|-|
| *string* | _greeting | undefined |


## *function* greet

Greeter.greet() `view` `cfae3217`





## *function* greeting

Greeter.greeting() `view` `ef690cc0`






---
# XBRMarket


## *function* register_service

XBRMarket.register_service(public_key, prefix, implements, provides) `nonpayable` `67b0c55b`


Inputs

| | | |
|-|-|-|
| *bytes32* | public_key | undefined |
| *string* | prefix | undefined |
| *uint256[]* | implements | undefined |
| *uint256[]* | provides | undefined |


## *function* register_api

XBRMarket.register_api(domain, name, descriptor) `nonpayable` `74221846`


Inputs

| | | |
|-|-|-|
| *string* | domain | undefined |
| *string* | name | undefined |
| *string* | descriptor | undefined |



---
# XBRNetwork


## *function* register_domain

XBRNetwork.register_domain(domain, descriptor) `nonpayable` `278deab9`


Inputs

| | | |
|-|-|-|
| *string* | domain | undefined |
| *string* | descriptor | undefined |


## *function* verify_domain

XBRNetwork.verify_domain(domain_cookie, v, r, s) `nonpayable` `2d457826`


Inputs

| | | |
|-|-|-|
| *uint256* | domain_cookie | undefined |
| *uint8* | v | undefined |
| *bytes32* | r | undefined |
| *bytes32* | s | undefined |


## *function* get_domain

XBRNetwork.get_domain(domain) `nonpayable` `93dec698`


Inputs

| | | |
|-|-|-|
| *string* | domain | undefined |


## *function* register_market

XBRNetwork.register_market(domain, market, descriptor) `nonpayable` `963b891d`


Inputs

| | | |
|-|-|-|
| *string* | domain | undefined |
| *string* | market | undefined |
| *string* | descriptor | undefined |


## *function* network_token

XBRNetwork.network_token() `view` `9b3a0f96`





## *function* get_market

XBRNetwork.get_market(domain, market) `nonpayable` `adb4be3e`


Inputs

| | | |
|-|-|-|
| *string* | domain | undefined |
| *string* | market | undefined |


## *function* dns_oracle

XBRNetwork.dns_oracle() `view` `e17ded8e`





## *function* is_signed_by

XBRNetwork.is_signed_by(signer, hash, v, r, s) `view` `e37b019a`


Inputs

| | | |
|-|-|-|
| *address* | signer | undefined |
| *bytes32* | hash | undefined |
| *uint8* | v | undefined |
| *bytes32* | r | undefined |
| *bytes32* | s | undefined |


## *function* get_agent

XBRNetwork.get_agent(public_key) `nonpayable` `e4f7d38a`


Inputs

| | | |
|-|-|-|
| *bytes32* | public_key | undefined |


## *function* register_agent

XBRNetwork.register_agent(public_key, block_number, descriptor) `nonpayable` `e65a5907`


Inputs

| | | |
|-|-|-|
| *bytes32* | public_key | undefined |
| *uint256* | block_number | undefined |
| *string* | descriptor | undefined |


## *function* network_sponsor

XBRNetwork.network_sponsor() `view` `f4bc2fb4`






---
# XBRToken


## *function* name

XBRToken.name() `view` `06fdde03`





## *function* approve

XBRToken.approve(_spender, _value) `nonpayable` `095ea7b3`

> Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.   * Beware that changing an allowance with this method brings the risk that someone may use both the old and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards: https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729

Inputs

| | | |
|-|-|-|
| *address* | _spender | The address which will spend the funds. |
| *uint256* | _value | The amount of tokens to be spent. |


## *function* totalSupply

XBRToken.totalSupply() `view` `18160ddd`

> total number of tokens in existence




## *function* transferFrom

XBRToken.transferFrom(_from, _to, _value) `nonpayable` `23b872dd`

> Transfer tokens from one address to another

Inputs

| | | |
|-|-|-|
| *address* | _from | address The address which you want to send tokens from |
| *address* | _to | address The address which you want to transfer to |
| *uint256* | _value | uint256 the amount of tokens to be transferred |


## *function* INITIAL_SUPPLY

XBRToken.INITIAL_SUPPLY() `view` `2ff2e9dc`





## *function* decimals

XBRToken.decimals() `view` `313ce567`





## *function* decreaseApproval

XBRToken.decreaseApproval(_spender, _subtractedValue) `nonpayable` `66188463`

> Decrease the amount of tokens that an owner allowed to a spender.   * approve should be called when allowed[_spender] == 0. To decrement allowed value is better to use this function to avoid 2 calls (and wait until the first transaction is mined) From MonolithDAO Token.sol

Inputs

| | | |
|-|-|-|
| *address* | _spender | The address which will spend the funds. |
| *uint256* | _subtractedValue | The amount of tokens to decrease the allowance by. |


## *function* balanceOf

XBRToken.balanceOf(_owner) `view` `70a08231`

> Gets the balance of the specified address.

Inputs

| | | |
|-|-|-|
| *address* | _owner | The address to query the the balance of. |

Outputs

| | | |
|-|-|-|
| *uint256* | balance | undefined |

## *function* symbol

XBRToken.symbol() `view` `95d89b41`





## *function* transfer

XBRToken.transfer(_to, _value) `nonpayable` `a9059cbb`

> transfer token for a specified address

Inputs

| | | |
|-|-|-|
| *address* | _to | The address to transfer to. |
| *uint256* | _value | The amount to be transferred. |


## *function* increaseApproval

XBRToken.increaseApproval(_spender, _addedValue) `nonpayable` `d73dd623`

> Increase the amount of tokens that an owner allowed to a spender.   * approve should be called when allowed[_spender] == 0. To increment allowed value is better to use this function to avoid 2 calls (and wait until the first transaction is mined) From MonolithDAO Token.sol

Inputs

| | | |
|-|-|-|
| *address* | _spender | The address which will spend the funds. |
| *uint256* | _addedValue | The amount of tokens to increase the allowance by. |


## *function* allowance

XBRToken.allowance(_owner, _spender) `view` `dd62ed3e`

> Function to check the amount of tokens that an owner allowed to a spender.

Inputs

| | | |
|-|-|-|
| *address* | _owner | address The address which owns the funds. |
| *address* | _spender | address The address which will spend the funds. |

Outputs

| | | |
|-|-|-|
| *uint256* |  | undefined |

## *event* Approval

XBRToken.Approval(owner, spender, value) `8c5be1e5`

Arguments

| | | |
|-|-|-|
| *address* | owner | indexed |
| *address* | spender | indexed |
| *uint256* | value | not indexed |

## *event* Transfer

XBRToken.Transfer(from, to, value) `ddf252ad`

Arguments

| | | |
|-|-|-|
| *address* | from | indexed |
| *address* | to | indexed |
| *uint256* | value | not indexed |


---
# BasicToken


## *function* totalSupply

BasicToken.totalSupply() `view` `18160ddd`

> total number of tokens in existence




## *function* balanceOf

BasicToken.balanceOf(_owner) `view` `70a08231`

> Gets the balance of the specified address.

Inputs

| | | |
|-|-|-|
| *address* | _owner | The address to query the the balance of. |

Outputs

| | | |
|-|-|-|
| *uint256* | balance | undefined |

## *function* transfer

BasicToken.transfer(_to, _value) `nonpayable` `a9059cbb`

> transfer token for a specified address

Inputs

| | | |
|-|-|-|
| *address* | _to | The address to transfer to. |
| *uint256* | _value | The amount to be transferred. |

## *event* Transfer

BasicToken.Transfer(from, to, value) `ddf252ad`

Arguments

| | | |
|-|-|-|
| *address* | from | indexed |
| *address* | to | indexed |
| *uint256* | value | not indexed |


---
# ERC20


## *function* approve

ERC20.approve(spender, value) `nonpayable` `095ea7b3`


Inputs

| | | |
|-|-|-|
| *address* | spender | undefined |
| *uint256* | value | undefined |


## *function* totalSupply

ERC20.totalSupply() `view` `18160ddd`





## *function* transferFrom

ERC20.transferFrom(from, to, value) `nonpayable` `23b872dd`


Inputs

| | | |
|-|-|-|
| *address* | from | undefined |
| *address* | to | undefined |
| *uint256* | value | undefined |


## *function* balanceOf

ERC20.balanceOf(who) `view` `70a08231`


Inputs

| | | |
|-|-|-|
| *address* | who | undefined |


## *function* transfer

ERC20.transfer(to, value) `nonpayable` `a9059cbb`


Inputs

| | | |
|-|-|-|
| *address* | to | undefined |
| *uint256* | value | undefined |


## *function* allowance

ERC20.allowance(owner, spender) `view` `dd62ed3e`


Inputs

| | | |
|-|-|-|
| *address* | owner | undefined |
| *address* | spender | undefined |

## *event* Approval

ERC20.Approval(owner, spender, value) `8c5be1e5`

Arguments

| | | |
|-|-|-|
| *address* | owner | indexed |
| *address* | spender | indexed |
| *uint256* | value | not indexed |

## *event* Transfer

ERC20.Transfer(from, to, value) `ddf252ad`

Arguments

| | | |
|-|-|-|
| *address* | from | indexed |
| *address* | to | indexed |
| *uint256* | value | not indexed |


---
# ERC20Basic


## *function* totalSupply

ERC20Basic.totalSupply() `view` `18160ddd`





## *function* balanceOf

ERC20Basic.balanceOf(who) `view` `70a08231`


Inputs

| | | |
|-|-|-|
| *address* | who | undefined |


## *function* transfer

ERC20Basic.transfer(to, value) `nonpayable` `a9059cbb`


Inputs

| | | |
|-|-|-|
| *address* | to | undefined |
| *uint256* | value | undefined |

## *event* Transfer

ERC20Basic.Transfer(from, to, value) `ddf252ad`

Arguments

| | | |
|-|-|-|
| *address* | from | indexed |
| *address* | to | indexed |
| *uint256* | value | not indexed |


---
# SafeMath


---
# StandardToken


## *function* approve

StandardToken.approve(_spender, _value) `nonpayable` `095ea7b3`

> Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.   * Beware that changing an allowance with this method brings the risk that someone may use both the old and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards: https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729

Inputs

| | | |
|-|-|-|
| *address* | _spender | The address which will spend the funds. |
| *uint256* | _value | The amount of tokens to be spent. |


## *function* totalSupply

StandardToken.totalSupply() `view` `18160ddd`

> total number of tokens in existence




## *function* transferFrom

StandardToken.transferFrom(_from, _to, _value) `nonpayable` `23b872dd`

> Transfer tokens from one address to another

Inputs

| | | |
|-|-|-|
| *address* | _from | address The address which you want to send tokens from |
| *address* | _to | address The address which you want to transfer to |
| *uint256* | _value | uint256 the amount of tokens to be transferred |


## *function* decreaseApproval

StandardToken.decreaseApproval(_spender, _subtractedValue) `nonpayable` `66188463`

> Decrease the amount of tokens that an owner allowed to a spender.   * approve should be called when allowed[_spender] == 0. To decrement allowed value is better to use this function to avoid 2 calls (and wait until the first transaction is mined) From MonolithDAO Token.sol

Inputs

| | | |
|-|-|-|
| *address* | _spender | The address which will spend the funds. |
| *uint256* | _subtractedValue | The amount of tokens to decrease the allowance by. |


## *function* balanceOf

StandardToken.balanceOf(_owner) `view` `70a08231`

> Gets the balance of the specified address.

Inputs

| | | |
|-|-|-|
| *address* | _owner | The address to query the the balance of. |

Outputs

| | | |
|-|-|-|
| *uint256* | balance | undefined |

## *function* transfer

StandardToken.transfer(_to, _value) `nonpayable` `a9059cbb`

> transfer token for a specified address

Inputs

| | | |
|-|-|-|
| *address* | _to | The address to transfer to. |
| *uint256* | _value | The amount to be transferred. |


## *function* increaseApproval

StandardToken.increaseApproval(_spender, _addedValue) `nonpayable` `d73dd623`

> Increase the amount of tokens that an owner allowed to a spender.   * approve should be called when allowed[_spender] == 0. To increment allowed value is better to use this function to avoid 2 calls (and wait until the first transaction is mined) From MonolithDAO Token.sol

Inputs

| | | |
|-|-|-|
| *address* | _spender | The address which will spend the funds. |
| *uint256* | _addedValue | The amount of tokens to increase the allowance by. |


## *function* allowance

StandardToken.allowance(_owner, _spender) `view` `dd62ed3e`

> Function to check the amount of tokens that an owner allowed to a spender.

Inputs

| | | |
|-|-|-|
| *address* | _owner | address The address which owns the funds. |
| *address* | _spender | address The address which will spend the funds. |

Outputs

| | | |
|-|-|-|
| *uint256* |  | undefined |
## *event* Approval

StandardToken.Approval(owner, spender, value) `8c5be1e5`

Arguments

| | | |
|-|-|-|
| *address* | owner | indexed |
| *address* | spender | indexed |
| *uint256* | value | not indexed |

## *event* Transfer

StandardToken.Transfer(from, to, value) `ddf252ad`

Arguments

| | | |
|-|-|-|
| *address* | from | indexed |
| *address* | to | indexed |
| *uint256* | value | not indexed |


---