// File: @openzeppelin/contracts/token/ERC20/IERC20.sol

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// File: @openzeppelin/contracts/GSN/Context.sol

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

// File: @openzeppelin/contracts/math/SafeMath.sol

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts with custom message when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

// File: @openzeppelin/contracts/token/ERC20/ERC20.sol

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;




/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20PresetMinterPauser}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.zeppelin.solutions/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * We have followed general OpenZeppelin guidelines: functions revert instead
 * of returning `false` on failure. This behavior is nonetheless conventional
 * and does not conflict with the expectations of ERC20 applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See {IERC20-approve}.
 */
contract ERC20 is Context, IERC20 {
    using SafeMath for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    /**
     * @dev Sets the values for {name} and {symbol}, initializes {decimals} with
     * a default value of 18.
     *
     * To select a different value for {decimals}, use {_setupDecimals}.
     *
     * All three of these values are immutable: they can only be set once during
     * construction.
     */
    constructor (string memory name_, string memory symbol_) public {
        _name = name_;
        _symbol = symbol_;
        _decimals = 18;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5,05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the value {ERC20} uses, unless {_setupDecimals} is
     * called.
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view returns (uint8) {
        return _decimals;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `recipient` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * Requirements:
     *
     * - `sender` and `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     * - the caller must have allowance for ``sender``'s tokens of at least
     * `amount`.
     */
    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    /**
     * @dev Moves tokens `amount` from `sender` to `recipient`.
     *
     * This is internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `sender` cannot be the zero address.
     * - `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     */
    function _transfer(address sender, address recipient, uint256 amount) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Sets {decimals} to a value other than the default one of 18.
     *
     * WARNING: This function should only be called from the constructor. Most
     * applications that interact with token contracts will not expect
     * {decimals} to ever change, and may work incorrectly if it does.
     */
    function _setupDecimals(uint8 decimals_) internal {
        _decimals = decimals_;
    }

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be to transferred to `to`.
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }
}

// File: contracts/XBRTypes.sol

// SPDX-License-Identifier: Apache-2.0

///////////////////////////////////////////////////////////////////////////////
//
//  Copyright (C) 2018-2021 Crossbar.io Technologies GmbH and contributors.
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

pragma solidity >=0.6.0 <0.8.0;
pragma experimental ABIEncoderV2;


/**
 * The `XBR Types <https://github.com/crossbario/xbr-protocol/blob/master/contracts/XBRTypes.sol>`__
 * library collect XBR type definitions used throughout the other XBR contracts.
 */
library XBRTypes {

    // FIXME: this does not work .. hence we put this constant into XBRNetwork.ANYADR
    // address public constant ANYADR = 0xFFfFfFffFFfffFFfFFfFFFFFffFFFffffFfFFFfF;

    /// All XBR network member levels defined.
    enum MemberLevel { NULL, ACTIVE, VERIFIED, RETIRED, PENALTY, BLOCKED, RETIRING }

    /// XBR Domain status values
    enum DomainStatus { NULL, ACTIVE, CLOSED }

    /// XBR Carrier Node types
    enum NodeType { NULL, MASTER, CORE, EDGE }

    /// Market state for a given data market. The market can only be joined and new channels
    /// can only be opened when the market is in state OPEN. When the market operator is closing
    /// the market, state is moved to CLOSING. Once all channels have been closed, state is
    /// moved to CLOSED. Once all actors have left (and any securities have been redeemed),
    /// the market is moved to LIQUIDATED.
    enum MarketState { NULL, OPEN, CLOSING, CLOSED, LIQUIDATED }

    /// Current state of an actor in a market.
    enum ActorState { NULL, JOINED, LEAVING, LEFT }

    /// All XBR market actor types defined.
    enum ActorType { NULL, PROVIDER, CONSUMER, PROVIDER_CONSUMER }

    /// All XBR state channel types defined.
    enum ChannelType { NULL, PAYMENT, PAYING }

    /// All XBR state channel states defined.
    enum ChannelState { NULL, OPEN, CLOSING, CLOSED, FAILED }

    /// Container type for holding XBR network membership information.
    struct Member {
        /// Block number when the member was (initially) registered in the XBR network.
        uint256 registered;

        /// The IPFS Multihash of the XBR EULA being agreed to and stored as one
        /// ZIP file archive on IPFS.
        string eula;

        /// Optional public member profile. An IPFS Multihash of the member profile
        /// stored in IPFS.
        string profile;

        /// Current member level.
        MemberLevel level;

        /// If the transaction to join the XBR network as a new member was was pre-signed
        /// off-chain by the new member, this is the signature the user supplied. If the
        /// user on-boarded by directly interacting with the XBR contracts on-chain, this
        /// will be empty.
        bytes signature;
    }

    /// Container type for holding XBR Domain information.
    struct Domain {
        /// Block number when the domain was created.
        uint256 created;

        /// Domain sequence.
        uint32 seq;

        /// Domain status
        DomainStatus status;

        /// Domain owner.
        address owner;

        /// Domain signing key (Ed25519 public key).
        bytes32 key;

        /// Software stack license file on IPFS (required).
        string license;

        /// Optional domain terms on IPFS.
        string terms;

        /// Optional domain metadata on IPFS.
        string meta;

        bytes signature;

        /// Nodes within the domain.
        bytes16[] nodes;
    }

    /// Container type for holding XBR Domain Nodes information.
    struct Node {
        /// Block number when the node was paired to the respective domain.
        uint256 paired;

        bytes16 domain;

        /// Type of node.
        NodeType nodeType;

        /// Node key (Ed25519 public key).
        bytes32 key;

        /// Optional (encrypted) node configuration on IPFS.
        string config;

        bytes signature;
    }

    /// Network level (global) stats for an XBR network member.
    struct MemberMarketStats {
        /// Number of markets the member is currently owner (operator) of.
        uint32 marketsOwned;

        /// Number of markets the member is currently joined to as a (buyer, seller, buyer+seller) actor.
        uint32 marketsJoined;

        /// Total sum of consumer/provider securities put at stake as a buyer/seller-actor in any joined market.
        uint256 marketSecuritiesSent;

        uint256 marketSecuritiesReceived;
    }

    struct MemberChannelStats {
        uint32 paymentChannels;
        uint32 payingChannels;
        uint32 activePaymentChannels;
        uint32 activePayingChannels;
        /// Total sum of deposits initially put into (currently still active / open) payment/paying channels by the buyer/seller-actor in any joined market.
        uint256 activePaymentChannelDeposits;
        uint256 activePayingChannelDeposits;
    }

    /// Container type for holding XBR market actor information.
    struct Actor {
        /// Block number when the actor has joined the respective market.
        uint256 joined;

        /// Security deposited by the actor when joining the market.
        uint256 security;

        /// Metadata attached to an actor in a market.
        string meta;

        /// This is the signature the user (actor) supplied for joining a market.
        bytes signature;

        /// Current state of an actor in a market.
        ActorState state;

        /// All payment (paying) channels of the respective buyer (seller) actor.
        address[] channels;

        mapping(address => mapping(bytes16 => Consent)) delegates;
    }

    /// Container type for holding XBR market information.
    struct Market {
        /// Block number when the market was created.
        uint256 created;

        /// Market sequence number.
        uint32 seq;

        /// Market owner (aka "market operator").
        address owner;

        /// The coin (ERC20 token) to be used in the market as the means of payment.
        address coin;

        /// Market terms (IPFS Multihash).
        string terms;

        /// Market metadata (IPFS Multihash).
        string meta;

        /// Market maker address.
        address maker;

        /// Security deposit required by data providers (sellers) to join the market.
        uint256 providerSecurity;

        /// Security deposit required by data consumers (buyers) to join the market.
        uint256 consumerSecurity;

        /// Market fee rate for the market operator.
        uint256 marketFee;

        /// This is the signature the user (market owner/operator) supplied for opening the market.
        bytes signature;

        /// Adresses of provider (seller) actors joined in the market.
        address[] providerActorAdrs;

        /// Adresses of consumer (buyer) actors joined in the market.
        address[] consumerActorAdrs;

        /// Provider (seller) actors joined in the market by actor address.
        mapping(address => Actor) providerActors;

        /// Consumer (buyer) actors joined in the market by actor address.
        mapping(address => Actor) consumerActors;

        /// Current payment channel by (buyer) delegate.
        mapping(address => address) currentPaymentChannelByDelegate;

        /// Current paying channel by (seller) delegate.
        mapping(address => address) currentPayingChannelByDelegate;
    }

    /// Container type for holding XBR data service API information.
    struct Api {
        /// Block number when the API was added to the respective catalog.
        uint256 published;

        /// Multihash of API Flatbuffers schema (required).
        string schema;

        /// Multihash of API meta-data (optional).
        string meta;

        /// This is the signature the user (actor) supplied when publishing the API.
        bytes signature;
    }

    /// Container type for holding XBR catalog information.
    struct Catalog {
        /// Block number when the catalog was created.
        uint256 created;

        /// Catalog sequence number.
        uint32 seq;

        /// Catalog owner (aka "catalog publisher").
        address owner;

        /// Catalog terms (IPFS Multihash).
        string terms;

        /// Catalog metadata (IPFS Multihash).
        string meta;

        /// This is the signature the member supplied for creating the catalog.
        bytes signature;

        /// The APIs part of this catalog.
        mapping(bytes16 => Api) apis;
    }

    struct Consent {
        /// Block number when the catalog was created.
        uint256 updated;

        /// Consent granted or revoked.
        bool consent;

        /// The WAMP URI prefix to be used by the delegate in the data plane realm.
        string servicePrefix;

        /// This is the signature the user (actor) supplied when setting the consent status.
        bytes signature;
    }

    /// Container type for holding channel static information.
    ///
    /// NOTE: This struct has a companion struct `ChannelState` with all
    /// varying state. The split-up is necessary as the EVM limits stack-depth
    /// to 16, and we need more channel attributes than that.
    struct Channel {
        /// Block number when the channel was created.
        uint256 created;

        /// Channel sequence number.
        uint32 seq;

        /// Current payment channel type (either payment or paying channel).
        ChannelType ctype;

        /// The XBR Market ID this channel is operating payments (or payouts) for.
        bytes16 marketId;

        /// The channel ID.
        bytes16 channelId;

        /// The sender of the payments in this channel. Either a XBR consumer (for
        /// payment channels) or the XBR market maker (for paying channels).
        address actor;

        /// The delegate of the channel, e.g. the XBR consumer delegate in case
        /// of a payment channel or the XBR provider delegate in case of a paying
        /// channel that is allowed to consume or provide data with off-chain
        /// transactions and  payments running under this channel.
        address delegate;

        /// The off-chain market maker that operates this payment or paying channel.
        address marketmaker;

        /// Recipient of the payments in this channel. Either the XBR market operator
        /// (for payment channels) or a XBR provider (for paying channels).
        address recipient;

        /// Amount of tokens (denominated in the respective market token) held in
        /// this channel (initially deposited by the actor).
        uint256 amount;

        /// Signature supplied (by the actor) when opening the channel.
        bytes signature;
    }

    /// Container type for holding channel (closing) state information.
    struct ChannelClosingState {
        /// Current payment channel state.
        ChannelState state;

        /// Block timestamp when the channel was requested to close (before timeout).
        uint256 closingAt;

        /// When this channel is closing, the sequence number of the closing transaction.
        uint32 closingSeq;

        /// When this channel is closing, the off-chain closing balance of the closing transaction.
        uint256 closingBalance;

        /// Block timestamp when the channel was closed (finally, after the timeout).
        uint256 closedAt;

        /// When this channel has closed, the sequence number of the final accepted closing transaction.
        uint32 closedSeq;

        /// When this channel is closing, the closing balance of the final accepted closing transaction.
        uint256 closedBalance;

        /// Closing transaction signature by (buyer or seller) delegate supplied when requesting to close the channel.
        bytes delegateSignature;

        /// Closing transaction signature by market maker supplied when requesting to close the channel.
        bytes marketmakerSignature;
    }

    /// EIP712 type for XBR as a type domain.
    struct EIP712Domain {
        /// The type domain name, makes signatures from different domains incompatible.
        string  name;

        /// The type domain version.
        string  version;
    }

    /// EIP712 type for use in member registration.
    struct EIP712MemberRegister {
        /// Verifying chain ID, which binds the signature to that chain
        /// for cross-chain replay-attack protection.
        uint256 chainId;

        /// Verifying contract address, which binds the signature to that address
        /// for cross-contract replay-attack protection.
        address verifyingContract;

        /// Registered member address.
        address member;

        /// Block number when the member registered in the XBR network.
        uint256 registered;

        /// Multihash of EULA signed by the member when registering.
        string eula;

        /// Optional profile meta-data multihash.
        string profile;
    }

    /// EIP712 type for use in member unregistration.
    struct EIP712MemberUnregister {
        /// Verifying chain ID, which binds the signature to that chain
        /// for cross-chain replay-attack protection.
        uint256 chainId;

        /// Verifying contract address, which binds the signature to that address
        /// for cross-contract replay-attack protection.
        address verifyingContract;

        /// Address of the member that was unregistered.
        address member;

        /// Block number when the member retired from the XBR network.
        uint256 retired;
    }

    /// EIP712 type for use in domain creation.
    struct EIP712DomainCreate {
        /// Verifying chain ID, which binds the signature to that chain
        /// for cross-chain replay-attack protection.
        uint256 chainId;

        /// Verifying contract address, which binds the signature to that address
        /// for cross-contract replay-attack protection.
        address verifyingContract;

        /// The member that created the domain.
        address member;

        /// Block number when the member registered in the XBR network.
        uint256 created;

        /// The ID of the domain created (a 16 bytes UUID which is globally unique to that market).
        bytes16 domainId;

        /// Domain signing key (Ed25519 public key).
        bytes32 domainKey;

        /// Multihash for the license for the software stack running the domain.
        string license;

        /// Multihash for the terms applying to this domain.
        string terms;

        /// Multihash for optional meta-data supplied for the domain.
        string meta;
    }

    /// EIP712 type for use in publishing APIs to catalogs.
    struct EIP712NodePair {
        /// Verifying chain ID, which binds the signature to that chain
        /// for cross-chain replay-attack protection.
        uint256 chainId;

        /// Verifying contract address, which binds the signature to that address
        /// for cross-contract replay-attack protection.
        address verifyingContract;

        /// The XBR network member pairing the node.
        address member;

        /// Block number when the node was paired to the domain.
        uint256 paired;

        /// The ID of the node to pair. Must be globally unique (not yet existing).
        bytes16 nodeId;

        /// The ID of the domain to pair the node with.
        bytes16 domainId;

        /// The type of node to pair the node under.
        NodeType nodeType;

        /// The Ed25519 public node key.
        bytes32 nodeKey;

        /// Optional IPFS Multihash pointing to node configuration stored on IPFS.
        string config;
    }

    /// EIP712 type for use in catalog creation.
    struct EIP712CatalogCreate {
        /// Verifying chain ID, which binds the signature to that chain
        /// for cross-chain replay-attack protection.
        uint256 chainId;

        /// Verifying contract address, which binds the signature to that address
        /// for cross-contract replay-attack protection.
        address verifyingContract;

        /// The member that created the catalog.
        address member;

        /// Block number when the member registered in the XBR network.
        uint256 created;

        /// The ID of the catalog created (a 16 bytes UUID which is globally unique to that market).
        bytes16 catalogId;

        /// Multihash for the terms applying to this catalog.
        string terms;

        /// Multihash for optional meta-data supplied for the catalog.
        string meta;
    }

    /// EIP712 type for use in publishing APIs to catalogs.
    struct EIP712ApiPublish {
        /// Verifying chain ID, which binds the signature to that chain
        /// for cross-chain replay-attack protection.
        uint256 chainId;

        /// Verifying contract address, which binds the signature to that address
        /// for cross-contract replay-attack protection.
        address verifyingContract;

        /// The XBR network member publishing the API.
        address member;

        /// Block number when the API was published to the catalog.
        uint256 published;

        /// The ID of the catalog the API is published to.
        bytes16 catalogId;

        /// The ID of the API published.
        bytes16 apiId;

        /// Multihash of API Flatbuffers schema (required).
        string schema;

        /// Multihash of API meta-data (optional).
        string meta;
    }

    /// EIP712 type for use in market creation.
    struct EIP712MarketCreate {
        /// Verifying chain ID, which binds the signature to that chain
        /// for cross-chain replay-attack protection.
        uint256 chainId;

        /// Verifying contract address, which binds the signature to that address
        /// for cross-contract replay-attack protection.
        address verifyingContract;

        /// The member that created the catalog.
        address member;

        /// Block number when the market was created.
        uint256 created;

        /// The ID of the market created (a 16 bytes UUID which is globally unique to that market).
        bytes16 marketId;

        /// Coin used as means of payment in market. Must be an ERC20 compatible token.
        address coin;

        /// Multihash for the market terms applying to this market.
        string terms;

        /// Multihash for optional market meta-data supplied for the market.
        string meta;

        /// The address of the market maker responsible for this market. The market
        /// maker of a market is the link between off-chain channels and on-chain channels,
        /// and operates the channels by processing transactions.
        address maker;

        // FIXME: enabling the following  runs into stack-depth limit of 12!
        //        => move to attributes (under "meta" multihash)

        /// Any mandatory security that actors that join this market as data providers (selling data
        /// as seller actors) must supply when joining this market. May be 0.
        // uint256 providerSecurity;

        /// Any mandatory security that actors that join this market as data consumer (buying data
        /// as buyer actors) must supply when joining this market. May be 0.
        // uint256 consumerSecurity;

        /// The market fee that applies in this market. May be 0.
        uint256 marketFee;
    }

    /// EIP712 type for use in joining markets.
    struct EIP712MarketJoin {
        /// Verifying chain ID, which binds the signature to that chain
        /// for cross-chain replay-attack protection.
        uint256 chainId;

        /// Verifying contract address, which binds the signature to that address
        /// for cross-contract replay-attack protection.
        address verifyingContract;

        /// The XBR network member joining the specified market as a market actor.
        address member;

        /// Block number when the member as joined the market,
        uint256 joined;

        /// The ID of the market joined.
        bytes16 marketId;

        /// The actor type as which to join, which can be "buyer" or "seller" or "buyer+seller".
        uint8 actorType;

        /// Optional multihash for additional meta-data supplied
        /// for the actor joining the market.
        string meta;
    }

    /// EIP712 type for use in leaving markets.
    struct EIP712MarketLeave {
        /// Verifying chain ID, which binds the signature to that chain
        /// for cross-chain replay-attack protection.
        uint256 chainId;

        /// Verifying contract address, which binds the signature to that address
        /// for cross-contract replay-attack protection.
        address verifyingContract;

        /// The XBR network member leaving the specified market as the given market actor type.
        address member;

        /// Block number when the member left the market.
        uint256 left;

        /// The ID of the market left.
        bytes16 marketId;

        /// The actor type as which to leave, which can be "buyer" or "seller" or "buyer+seller".
        uint8 actorType;
    }

    /// EIP712 type for use in data consent tracking.
    struct EIP712Consent {
        /// Verifying chain ID, which binds the signature to that chain
        /// for cross-chain replay-attack protection.
        uint256 chainId;

        /// Verifying contract address, which binds the signature to that address
        /// for cross-contract replay-attack protection.
        address verifyingContract;

        /// The XBR network member giving consent.
        address member;

        /// Block number when the consent was status set.
        uint256 updated;

        /// The ID of the market in which consent was given.
        bytes16 marketId;

        /// Address of delegate consent (status) applies to.
        address delegate;

        /// The actor type for which the consent was set for the delegate.
        uint8 delegateType;

        /// The ID of the XBR data catalog consent was given for.
        bytes16 apiCatalog;

        /// Consent granted or revoked.
        bool consent;

        /// The WAMP URI prefix to be used by the delegate in the data plane realm.
        string servicePrefix;
    }

    /// EIP712 type for use in opening channels. The initial opening of a channel
    /// is one on-chain transaction (as is the final close), but all actual
    /// in-channel transactions happen off-chain.
    struct EIP712ChannelOpen {
        /// Verifying chain ID, which binds the signature to that chain
        /// for cross-chain replay-attack protection.
        uint256 chainId;

        /// Verifying contract address, which binds the signature to that address
        /// for cross-contract replay-attack protection.
        address verifyingContract;

        /// The type of channel, can be payment channel (for use by buyer delegates) or
        /// paying channel (for use by seller delegates).
        uint8 ctype;

        /// Block number when the channel was opened.
        uint256 openedAt;

        /// The ID of the market in which the channel was opened.
        bytes16 marketId;

        /// The ID of the channel created (a 16 bytes UUID which is globally unique to that
        /// channel, in particular the channel ID is unique even across different markets).
        bytes16 channelId;

        /// The actor that created this channel.
        address actor;

        /// The delegate authorized to use this channel for off-chain transactions.
        address delegate;

        /// The address of the market maker that will operate the channel and
        /// perform the off-chain transactions.
        address marketmaker;

        /// The final recipient of the payout from the channel when the channel is closed.
        address recipient;

        /// The amount of tokens initially put into this channel by the actor. The value is
        /// denominated in the payment token used in the market.
        uint256 amount;
    }

    /// EIP712 type for use in closing channels.The final closing of a channel
    /// is one on-chain transaction (as is the final close), but all actual
    /// in-channel transactions happened before off-chain.
    struct EIP712ChannelClose {
        /// Verifying chain ID, which binds the signature to that chain
        /// for cross-chain replay-attack protection.
        uint256 chainId;

        /// Verifying contract address, which binds the signature to that address
        /// for cross-contract replay-attack protection.
        address verifyingContract;

        /// Block number when the channel close was signed.
        uint256 closeAt;

        /// The ID of the market in which the channel to be closed was initially opened.
        bytes16 marketId;

        /// The ID of the channel to close.
        bytes16 channelId;

        /// The sequence number of the channel closed.
        uint32 channelSeq;

        /// The remaining closing balance at which the channel is closed.
        uint256 balance;

        /// Indication whether the data signed is considered final, which amounts
        /// to a promise that no further, newer signed data will be supplied later.
        bool isFinal;
    }

    /// EIP712 type data.
    // solhint-disable-next-line
    bytes32 constant EIP712_DOMAIN_TYPEHASH = keccak256("EIP712Domain(string name,string version)");

    /// EIP712 type data.
    // solhint-disable-next-line
    bytes32 constant EIP712_MEMBER_REGISTER_TYPEHASH = keccak256("EIP712MemberRegister(uint256 chainId,address verifyingContract,address member,uint256 registered,string eula,string profile)");

    /// EIP712 type data.
    // solhint-disable-next-line
    bytes32 constant EIP712_MEMBER_UNREGISTER_TYPEHASH = keccak256("EIP712MemberUnregister(uint256 chainId,address verifyingContract,address member,uint256 retired)");

    /// EIP712 type data.
    // solhint-disable-next-line
    bytes32 constant EIP712_DOMAIN_CREATE_TYPEHASH = keccak256("EIP712DomainCreate(uint256 chainId,address verifyingContract,address member,uint256 created,bytes16 domainId,bytes32 domainKey,string license,string terms,string meta)");

    /// EIP712 type data.
    // solhint-disable-next-line
    bytes32 constant EIP712_NODE_PAIR_TYPEHASH = keccak256("EIP712NodePair(uint256 chainId,address verifyingContract,address member,uint256 paired,bytes16 nodeId,bytes16 domainId,uint8 nodeType,bytes32 nodeKey,string config)");

    /// EIP712 type data.
    // solhint-disable-next-line
    bytes32 constant EIP712_CATALOG_CREATE_TYPEHASH = keccak256("EIP712CatalogCreate(uint256 chainId,address verifyingContract,address member,uint256 created,bytes16 catalogId,string terms,string meta)");

    /// EIP712 type data.
    // solhint-disable-next-line
    bytes32 constant EIP712_API_PUBLISH_TYPEHASH = keccak256("EIP712ApiPublish(uint256 chainId,address verifyingContract,address member,uint256 published,bytes16 catalogId,bytes16 apiId,string terms,string meta)");

    /// EIP712 type data.
    // solhint-disable-next-line
    bytes32 constant EIP712_MARKET_CREATE_TYPEHASH = keccak256("EIP712MarketCreate(uint256 chainId,address verifyingContract,address member,uint256 created,bytes16 marketId,address coin,string terms,string meta,address maker,uint256 marketFee)");

    /// EIP712 type data.
    // solhint-disable-next-line
    bytes32 constant EIP712_MARKET_JOIN_TYPEHASH = keccak256("EIP712MarketJoin(uint256 chainId,address verifyingContract,address member,uint256 joined,bytes16 marketId,uint8 actorType,string meta)");

    /// EIP712 type data.
    // solhint-disable-next-line
    bytes32 constant EIP712_MARKET_LEAVE_TYPEHASH = keccak256("EIP712MarketLeave(uint256 chainId,address verifyingContract,address member,uint256 left,bytes16 marketId,uint8 actorType)");

    /// EIP712 type data.
    // solhint-disable-next-line
    bytes32 constant EIP712_CONSENT_TYPEHASH = keccak256("EIP712Consent(uint256 chainId,address verifyingContract,address member,uint256 updated,bytes16 marketId,address delegate,uint8 delegateType,bytes16 apiCatalog,bool consent)");

    /// EIP712 type data.
    // solhint-disable-next-line
    bytes32 constant EIP712_CHANNEL_OPEN_TYPEHASH = keccak256("EIP712ChannelOpen(uint256 chainId,address verifyingContract,uint8 ctype,uint256 openedAt,bytes16 marketId,bytes16 channelId,address actor,address delegate,address marketmaker,address recipient,uint256 amount)");

    /// EIP712 type data.
    // solhint-disable-next-line
    bytes32 constant EIP712_CHANNEL_CLOSE_TYPEHASH = keccak256("EIP712ChannelClose(uint256 chainId,address verifyingContract,uint256 closeAt,bytes16 marketId,bytes16 channelId,uint32 channelSeq,uint256 balance,bool isFinal)");

    /// Check if the given address is a contract.
    function isContract(address adr) public view returns (bool) {
        uint256 codeLength;

        assembly {
            // Retrieve the size of the code on target address, this needs assembly .
            codeLength := extcodesize(adr)
        }

        return codeLength > 0;
    }

    /// Splits a signature (65 octets) into components (a "vrs"-tuple).
    function splitSignature (bytes memory signature_rsv) public pure returns (uint8 v, bytes32 r, bytes32 s) {
        require(signature_rsv.length == 65, "INVALID_SIGNATURE_LENGTH");

        // Split a signature given as a bytes string into components.
        assembly
        {
            r := mload(add(signature_rsv, 32))
            s := mload(add(signature_rsv, 64))
            v := and(mload(add(signature_rsv, 65)), 255)
        }
        if (v < 27) {
            v += 27;
        }

        return (v, r, s);
    }

    function hash(EIP712Domain memory domain_) private pure returns (bytes32) {
        return keccak256(abi.encode(
            EIP712_DOMAIN_TYPEHASH,
            keccak256(bytes(domain_.name)),
            keccak256(bytes(domain_.version))
        ));
    }

    function domainSeparator () private pure returns (bytes32) {
        // makes signatures from different domains incompatible.
        // see https://github.com/ethereum/EIPs/blob/master/EIPS/eip-712.md#arbitrary-messages
        return hash(EIP712Domain({
            name: "XBR",
            version: "1"
        }));
    }

    function hash (EIP712MemberRegister memory obj) private pure returns (bytes32) {
        return keccak256(abi.encode(
            EIP712_MEMBER_REGISTER_TYPEHASH,
            obj.chainId,
            obj.verifyingContract,
            obj.member,
            obj.registered,
            keccak256(bytes(obj.eula)),
            keccak256(bytes(obj.profile))
        ));
    }

    function hash (EIP712MemberUnregister memory obj) private pure returns (bytes32) {
        return keccak256(abi.encode(
            EIP712_MEMBER_UNREGISTER_TYPEHASH,
            obj.chainId,
            obj.verifyingContract,
            obj.member,
            obj.retired
        ));
    }

    function hash (EIP712DomainCreate memory obj) private pure returns (bytes32) {
        return keccak256(abi.encode(
            EIP712_DOMAIN_CREATE_TYPEHASH,
            obj.chainId,
            obj.verifyingContract,
            obj.member,
            obj.created,
            obj.domainId,
            obj.domainKey,
            keccak256(bytes(obj.license)),
            keccak256(bytes(obj.terms)),
            keccak256(bytes(obj.meta))
        ));
    }

    function hash (EIP712NodePair memory obj) private pure returns (bytes32) {
        return keccak256(abi.encode(
            EIP712_NODE_PAIR_TYPEHASH,
            obj.chainId,
            obj.verifyingContract,
            obj.member,
            obj.paired,
            obj.nodeId,
            obj.domainId,
            obj.nodeType,
            obj.nodeKey,
            keccak256(bytes(obj.config))
        ));
    }

    function hash (EIP712CatalogCreate memory obj) private pure returns (bytes32) {
        return keccak256(abi.encode(
            EIP712_CATALOG_CREATE_TYPEHASH,
            obj.chainId,
            obj.verifyingContract,
            obj.member,
            obj.created,
            obj.catalogId,
            keccak256(bytes(obj.terms)),
            keccak256(bytes(obj.meta))
        ));
    }

    function hash (EIP712ApiPublish memory obj) private pure returns (bytes32) {
        return keccak256(abi.encode(
            EIP712_API_PUBLISH_TYPEHASH,
            obj.chainId,
            obj.verifyingContract,
            obj.member,
            obj.published,
            obj.catalogId,
            obj.apiId,
            keccak256(bytes(obj.schema)),
            keccak256(bytes(obj.meta))
        ));
    }

    function hash (EIP712MarketCreate memory obj) private pure returns (bytes32) {
        return keccak256(abi.encode(
            EIP712_MARKET_CREATE_TYPEHASH,
            obj.chainId,
            obj.verifyingContract,
            obj.member,
            obj.created,
            obj.marketId,
            obj.coin,
            keccak256(bytes(obj.terms)),
            keccak256(bytes(obj.meta)),
            obj.maker,
            // obj.providerSecurity,
            // obj.consumerSecurity,
            obj.marketFee
        ));
    }

    function hash (EIP712MarketJoin memory obj) private pure returns (bytes32) {
        return keccak256(abi.encode(
            EIP712_MARKET_JOIN_TYPEHASH,
            obj.chainId,
            obj.verifyingContract,
            obj.member,
            obj.joined,
            obj.marketId,
            obj.actorType,
            keccak256(bytes(obj.meta))
        ));
    }

    function hash (EIP712MarketLeave memory obj) private pure returns (bytes32) {
        return keccak256(abi.encode(
            EIP712_MARKET_JOIN_TYPEHASH,
            obj.chainId,
            obj.verifyingContract,
            obj.member,
            obj.left,
            obj.marketId,
            obj.actorType
        ));
    }

    function hash (EIP712Consent memory obj) private pure returns (bytes32) {
        return keccak256(abi.encode(
            EIP712_CONSENT_TYPEHASH,
            obj.chainId,
            obj.verifyingContract,
            obj.member,
            obj.updated,
            obj.marketId,
            obj.delegate,
            obj.delegateType,
            obj.apiCatalog,
            obj.consent,
            keccak256(bytes(obj.servicePrefix))
        ));
    }

    function hash (EIP712ChannelOpen memory obj) private pure returns (bytes32) {
        return keccak256(abi.encode(
            EIP712_CHANNEL_OPEN_TYPEHASH,
            obj.chainId,
            obj.verifyingContract,
            obj.ctype,
            obj.openedAt,
            obj.marketId,
            obj.channelId,
            obj.actor,
            obj.delegate,
            obj.marketmaker,
            obj.recipient,
            obj.amount
        ));
    }

    function hash (EIP712ChannelClose memory obj) private pure returns (bytes32) {
        return keccak256(abi.encode(
            EIP712_CHANNEL_CLOSE_TYPEHASH,
            obj.chainId,
            obj.verifyingContract,
            obj.closeAt,
            obj.marketId,
            obj.channelId,
            obj.channelSeq,
            obj.balance,
            obj.isFinal
        ));
    }

    /// Verify signature on typed data for registering a member.
    function verify (address signer, EIP712MemberRegister memory obj,
        bytes memory signature) public pure returns (bool) {

        (uint8 v, bytes32 r, bytes32 s) = splitSignature(signature);

        bytes32 digest = keccak256(abi.encodePacked(
            "\x19\x01",
            domainSeparator(),
            hash(obj)
        ));

        return ecrecover(digest, v, r, s) == signer;
    }

    /// Verify signature on typed data for unregistering a member.
    function verify (address signer, EIP712MemberUnregister memory obj,
        bytes memory signature) public pure returns (bool) {

        (uint8 v, bytes32 r, bytes32 s) = splitSignature(signature);

        bytes32 digest = keccak256(abi.encodePacked(
            "\x19\x01",
            domainSeparator(),
            hash(obj)
        ));

        return ecrecover(digest, v, r, s) == signer;
    }

    /// Verify signature on typed data for creating a domain.
    function verify (address signer, EIP712DomainCreate memory obj,
        bytes memory signature) public pure returns (bool) {

        (uint8 v, bytes32 r, bytes32 s) = splitSignature(signature);

        bytes32 digest = keccak256(abi.encodePacked(
            "\x19\x01",
            domainSeparator(),
            hash(obj)
        ));

        return ecrecover(digest, v, r, s) == signer;
    }

    /// Verify signature on typed data for pairing a node.
    function verify (address signer, EIP712NodePair memory obj,
        bytes memory signature) public pure returns (bool) {

        (uint8 v, bytes32 r, bytes32 s) = splitSignature(signature);

        bytes32 digest = keccak256(abi.encodePacked(
            "\x19\x01",
            domainSeparator(),
            hash(obj)
        ));

        return ecrecover(digest, v, r, s) == signer;
    }

    /// Verify signature on typed data for creating a catalog.
    function verify (address signer, EIP712CatalogCreate memory obj,
        bytes memory signature) public pure returns (bool) {

        (uint8 v, bytes32 r, bytes32 s) = splitSignature(signature);

        bytes32 digest = keccak256(abi.encodePacked(
            "\x19\x01",
            domainSeparator(),
            hash(obj)
        ));

        return ecrecover(digest, v, r, s) == signer;
    }

    /// Verify signature on typed data for publishing an API to a catalog.
    function verify (address signer, EIP712ApiPublish memory obj,
        bytes memory signature) public pure returns (bool) {

        (uint8 v, bytes32 r, bytes32 s) = splitSignature(signature);

        bytes32 digest = keccak256(abi.encodePacked(
            "\x19\x01",
            domainSeparator(),
            hash(obj)
        ));

        return ecrecover(digest, v, r, s) == signer;
    }

    /// Verify signature on typed data for creating a market.
    function verify (address signer, EIP712MarketCreate memory obj,
        bytes memory signature) public pure returns (bool) {

        (uint8 v, bytes32 r, bytes32 s) = splitSignature(signature);

        bytes32 digest = keccak256(abi.encodePacked(
            "\x19\x01",
            domainSeparator(),
            hash(obj)
        ));

        return ecrecover(digest, v, r, s) == signer;
    }

    /// Verify signature on typed data for joining a market.
    function verify (address signer, EIP712MarketJoin memory obj,
        bytes memory signature) public pure returns (bool) {

        (uint8 v, bytes32 r, bytes32 s) = splitSignature(signature);

        bytes32 digest = keccak256(abi.encodePacked(
            "\x19\x01",
            domainSeparator(),
            hash(obj)
        ));

        return ecrecover(digest, v, r, s) == signer;
    }

    /// Verify signature on typed data for leaving a market.
    function verify (address signer, EIP712MarketLeave memory obj,
        bytes memory signature) public pure returns (bool) {

        (uint8 v, bytes32 r, bytes32 s) = splitSignature(signature);

        bytes32 digest = keccak256(abi.encodePacked(
            "\x19\x01",
            domainSeparator(),
            hash(obj)
        ));

        return ecrecover(digest, v, r, s) == signer;
    }

    /// Verify signature on typed data for setting consent.
    function verify (address signer, EIP712Consent memory obj,
        bytes memory signature) public pure returns (bool) {

        (uint8 v, bytes32 r, bytes32 s) = splitSignature(signature);

        bytes32 digest = keccak256(abi.encodePacked(
            "\x19\x01",
            domainSeparator(),
            hash(obj)
        ));

        return ecrecover(digest, v, r, s) == signer;
    }

    /// Verify signature on typed data for opening a channel.
    function verify (address signer, EIP712ChannelOpen memory obj,
        bytes memory signature) public pure returns (bool) {

        (uint8 v, bytes32 r, bytes32 s) = splitSignature(signature);

        bytes32 digest = keccak256(abi.encodePacked(
            "\x19\x01",
            domainSeparator(),
            hash(obj)
        ));

        return ecrecover(digest, v, r, s) == signer;
    }

    /// Verify signature on typed data for closing a channel.
    function verify (address signer, EIP712ChannelClose memory obj,
        bytes memory signature) public pure returns (bool) {

        (uint8 v, bytes32 r, bytes32 s) = splitSignature(signature);

        bytes32 digest = keccak256(abi.encodePacked(
            "\x19\x01",
            domainSeparator(),
            hash(obj)
        ));

        return ecrecover(digest, v, r, s) == signer;
    }
}

// File: contracts/XBRToken.sol

// SPDX-License-Identifier: Apache-2.0

///////////////////////////////////////////////////////////////////////////////
//
//  Copyright (C) 2018-2021 Crossbar.io Technologies GmbH and contributors.
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

pragma solidity >=0.6.0 <0.8.0;
pragma experimental ABIEncoderV2;

// import "openzeppelin-solidity/contracts/token/ERC20/IERC20.sol";
// import "openzeppelin-solidity/contracts/token/ERC20/ERC20.sol";


// import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v3.3.0/contracts/token/ERC20/IERC20.sol";
// import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v3.3.0/contracts/token/ERC20/ERC20.sol";



interface IXBRTokenRelayInterface {
    function getRelayAuthority() external view returns (address);
}


/**
 * The `XBR Token <https://github.com/crossbario/xbr-protocol/blob/master/contracts/XBRToken.sol>`__
 * is a `ERC20 standard token <https://eips.ethereum.org/EIPS/eip-20>`__ defined by:
 *
 * * "XBR" as symbol
 * * fixed total supply of 10**9 ("one billion") XBR
 * * 18 decimals
 * * address (mainnet): tbd
 *
 * The XBR Token is using the (unmodified) `OpenZeppelin <https://openzeppelin.org/>`__
 * `reference implementation <https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/IERC20.sol>`__
 * of the ERC20 token standard.
 *
 * For API documentation, please see `here <https://docs.openzeppelin.com/contracts/2.x/api/token/erc20>`__.
 */
contract XBRToken is ERC20 {

    /// EIP712 type data.
    // solhint-disable-next-line
    bytes32 constant EIP712_DOMAIN_TYPEHASH = keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)");

    /// EIP712 type data.
    // solhint-disable-next-line
    bytes32 constant EIP712_APPROVE_TYPEHASH = keccak256("EIP712Approve(address sender,address relayer,address spender,uint256 amount,uint256 expires,uint256 nonce)");

    /// EIP712 Domain type data.
    struct EIP712Domain {
        string name;
        string version;
        uint256 chainId;
        address verifyingContract;
    }

    /// EIP712 Approve type data.
    struct EIP712Approve {
        address sender;
        address relayer;
        address spender;
        uint256 amount;
        uint256 expires;
        uint256 nonce;
    }

    /**
     * The XBR Token has a fixed supply of 1 billion and uses 18 decimal digits.
     */
    uint256 private constant INITIAL_SUPPLY = 10**9 * 10**18;

    /// For pre-signed transactions ("approveFor"), track signatures already used.
    mapping(bytes32 => uint256) private burnedSignatures;

    /**
     * Constructor that gives ``msg.sender`` all of existing tokens.
     * The XBR Token uses the symbol "XBR" and 18 decimal digits.
     */
    constructor() public ERC20("XBRToken", "XBR") {
        _mint(msg.sender, INITIAL_SUPPLY);
    }

    function hash (EIP712Approve memory obj) private view returns (bytes32) {

        bytes32 digestDomain = keccak256(abi.encode(
            EIP712_DOMAIN_TYPEHASH,
            keccak256(bytes("XBRToken")),
            keccak256(bytes("1")),
            1,  // FIXME: read chain_id at run-time
            address(this)
        ));

        bytes32 digestApprove = keccak256(abi.encode(
            EIP712_APPROVE_TYPEHASH,
            obj.sender,
            obj.relayer,
            obj.spender,
            obj.amount,
            obj.expires,
            obj.nonce
        ));

        bytes32 digest = keccak256(abi.encodePacked(
            "\x19\x01",
            digestDomain,
            digestApprove
        ));

        return digest;
    }

    function verify (address signer, EIP712Approve memory obj, bytes memory signature) private view returns (bool) {

        bytes32 digest = hash(obj);
        (uint8 v, bytes32 r, bytes32 s) = XBRTypes.splitSignature(signature);

        return ecrecover(digest, v, r, s) == signer;
    }

    /**
     * This method provides an extension to the standard ERC20 interface that allows to approve tokens
     * to be spent by another party or contract, similar to the standard `IERC20.approve` method.
     *
     * The difference is, that by using this method, the sender can pre-sign the approval off-chain, and
     * then let another party (the relayer) submit the transaction to the blockchain. Only the relayer
     * needs to have ETH to pay for gas, the off-chain sender does _not_ need any ETH.
     *
     * @param sender    The (off-chain) sender of tokens.
     * @param relayer   If given, the metatransaction can only be relayed from this address.
     * @param spender   The spender that will spend the tokens approved.
     * @param amount    Token amount to approve for the spender to spend.
     * @param expires   If given, the signature will expire at this block number.
     * @param nonce     Random nonce for metatransaction.
     * @param signature Signature over EIP712 data, signed by sender.
     */
    function approveFor (address sender, address relayer, address spender, uint256 amount, uint256 expires,
        uint256 nonce, bytes memory signature) public returns (bool) {

        EIP712Approve memory approve = EIP712Approve(sender, relayer, spender, amount, expires, nonce);

        // signature must be valid (signed by address in parameter "sender" - not the necessarily
        // the "msg.sender", the submitted of the transaction!)
        require(verify(sender, approve, signature), "INVALID_SIGNATURE");

        // relayer rules:
        //  1. always allow relaying if the specified "relayer" is 0
        //  2. if the authority address is not a contract, allow it to relay
        //  3. if the authority address is a contract, allow its defined 'getAuthority()' delegate to relay
        require(
            (relayer == address(0x0)) ||
            (!XBRTypes.isContract(relayer) && msg.sender == relayer) ||
            (XBRTypes.isContract(relayer) && msg.sender == IXBRTokenRelayInterface(relayer).getRelayAuthority()),
            "INVALID_RELAYER"
        );

        // signature must not have been expired
        require(block.number < expires || expires == 0, "SIGNATURE_EXPIRED");

        // signature must not have been used
        bytes32 digest = hash(approve);
        require(burnedSignatures[digest] == 0x0, "SIGNATURE_REUSED");

        // mark signature as "consumed"
        burnedSignatures[digest] = 0x1;

        // now to the actual approval. also see "contracts/token/ERC20/ERC20.sol#L136"
        // here https://github.com/OpenZeppelin/openzeppelin-contracts
        _approve(sender, spender, amount);

        return true;
    }

    /**
     * This method allows a sender that approved tokens via `approveFor` to burn the metatransaction
     * that was sent to the relayer - but only if the transaction has not yet been submitted by the relay.
     */
    function burnSignature (address sender, address relayer, address spender, uint256 amount, uint256 expires,
        uint256 nonce, bytes memory signature) public returns (bool success) {

        EIP712Approve memory approve = EIP712Approve(sender, relayer, spender, amount, expires, nonce);

        // signature must be valid (signed by address in parameter "sender" - not the necessarily
        // the "msg.sender", the submitted of the transaction!)
        require(verify(sender, approve, signature), "INVALID_SIGNATURE");

        // only the original signature creator can burn signature, not a relay
        require(sender == msg.sender);

        // signature must not have been used
        bytes32 digest = hash(approve);
        require(burnedSignatures[digest] == 0x0, "SIGNATURE_REUSED");

        // mark signature as "burned"
        burnedSignatures[digest] = 0x2;

        return true;
    }
}
