// File: @openzeppelin/contracts/utils/EnumerableSet.sol

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

/**
 * @dev Library for managing
 * https://en.wikipedia.org/wiki/Set_(abstract_data_type)[sets] of primitive
 * types.
 *
 * Sets have the following properties:
 *
 * - Elements are added, removed, and checked for existence in constant time
 * (O(1)).
 * - Elements are enumerated in O(n). No guarantees are made on the ordering.
 *
 * ```
 * contract Example {
 *     // Add the library methods
 *     using EnumerableSet for EnumerableSet.AddressSet;
 *
 *     // Declare a set state variable
 *     EnumerableSet.AddressSet private mySet;
 * }
 * ```
 *
 * As of v3.3.0, sets of type `bytes32` (`Bytes32Set`), `address` (`AddressSet`)
 * and `uint256` (`UintSet`) are supported.
 */
library EnumerableSet {
    // To implement this library for multiple types with as little code
    // repetition as possible, we write it in terms of a generic Set type with
    // bytes32 values.
    // The Set implementation uses private functions, and user-facing
    // implementations (such as AddressSet) are just wrappers around the
    // underlying Set.
    // This means that we can only create new EnumerableSets for types that fit
    // in bytes32.

    struct Set {
        // Storage of set values
        bytes32[] _values;

        // Position of the value in the `values` array, plus 1 because index 0
        // means a value is not in the set.
        mapping (bytes32 => uint256) _indexes;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function _add(Set storage set, bytes32 value) private returns (bool) {
        if (!_contains(set, value)) {
            set._values.push(value);
            // The value is stored at length-1, but we add 1 to all indexes
            // and use 0 as a sentinel value
            set._indexes[value] = set._values.length;
            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function _remove(Set storage set, bytes32 value) private returns (bool) {
        // We read and store the value's index to prevent multiple reads from the same storage slot
        uint256 valueIndex = set._indexes[value];

        if (valueIndex != 0) { // Equivalent to contains(set, value)
            // To delete an element from the _values array in O(1), we swap the element to delete with the last one in
            // the array, and then remove the last element (sometimes called as 'swap and pop').
            // This modifies the order of the array, as noted in {at}.

            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;

            // When the value to delete is the last one, the swap operation is unnecessary. However, since this occurs
            // so rarely, we still do the swap anyway to avoid the gas cost of adding an 'if' statement.

            bytes32 lastvalue = set._values[lastIndex];

            // Move the last value to the index where the value to delete is
            set._values[toDeleteIndex] = lastvalue;
            // Update the index for the moved value
            set._indexes[lastvalue] = toDeleteIndex + 1; // All indexes are 1-based

            // Delete the slot where the moved value was stored
            set._values.pop();

            // Delete the index for the deleted slot
            delete set._indexes[value];

            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function _contains(Set storage set, bytes32 value) private view returns (bool) {
        return set._indexes[value] != 0;
    }

    /**
     * @dev Returns the number of values on the set. O(1).
     */
    function _length(Set storage set) private view returns (uint256) {
        return set._values.length;
    }

   /**
    * @dev Returns the value stored at position `index` in the set. O(1).
    *
    * Note that there are no guarantees on the ordering of values inside the
    * array, and it may change when more values are added or removed.
    *
    * Requirements:
    *
    * - `index` must be strictly less than {length}.
    */
    function _at(Set storage set, uint256 index) private view returns (bytes32) {
        require(set._values.length > index, "EnumerableSet: index out of bounds");
        return set._values[index];
    }

    // Bytes32Set

    struct Bytes32Set {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _add(set._inner, value);
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _remove(set._inner, value);
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(Bytes32Set storage set, bytes32 value) internal view returns (bool) {
        return _contains(set._inner, value);
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(Bytes32Set storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

   /**
    * @dev Returns the value stored at position `index` in the set. O(1).
    *
    * Note that there are no guarantees on the ordering of values inside the
    * array, and it may change when more values are added or removed.
    *
    * Requirements:
    *
    * - `index` must be strictly less than {length}.
    */
    function at(Bytes32Set storage set, uint256 index) internal view returns (bytes32) {
        return _at(set._inner, index);
    }

    // AddressSet

    struct AddressSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(AddressSet storage set, address value) internal returns (bool) {
        return _add(set._inner, bytes32(uint256(value)));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(AddressSet storage set, address value) internal returns (bool) {
        return _remove(set._inner, bytes32(uint256(value)));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(AddressSet storage set, address value) internal view returns (bool) {
        return _contains(set._inner, bytes32(uint256(value)));
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(AddressSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

   /**
    * @dev Returns the value stored at position `index` in the set. O(1).
    *
    * Note that there are no guarantees on the ordering of values inside the
    * array, and it may change when more values are added or removed.
    *
    * Requirements:
    *
    * - `index` must be strictly less than {length}.
    */
    function at(AddressSet storage set, uint256 index) internal view returns (address) {
        return address(uint256(_at(set._inner, index)));
    }


    // UintSet

    struct UintSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(UintSet storage set, uint256 value) internal returns (bool) {
        return _add(set._inner, bytes32(value));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(UintSet storage set, uint256 value) internal returns (bool) {
        return _remove(set._inner, bytes32(value));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(UintSet storage set, uint256 value) internal view returns (bool) {
        return _contains(set._inner, bytes32(value));
    }

    /**
     * @dev Returns the number of values on the set. O(1).
     */
    function length(UintSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

   /**
    * @dev Returns the value stored at position `index` in the set. O(1).
    *
    * Note that there are no guarantees on the ordering of values inside the
    * array, and it may change when more values are added or removed.
    *
    * Requirements:
    *
    * - `index` must be strictly less than {length}.
    */
    function at(UintSet storage set, uint256 index) internal view returns (uint256) {
        return uint256(_at(set._inner, index));
    }
}

// File: @openzeppelin/contracts/utils/Address.sol

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.2 <0.8.0;

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        // solhint-disable-next-line no-inline-assembly
        assembly { size := extcodesize(account) }
        return size > 0;
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain`call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
      return functionCall(target, data, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{ value: value }(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns(bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                // solhint-disable-next-line no-inline-assembly
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
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

// File: @openzeppelin/contracts/access/AccessControl.sol

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;




/**
 * @dev Contract module that allows children to implement role-based access
 * control mechanisms.
 *
 * Roles are referred to by their `bytes32` identifier. These should be exposed
 * in the external API and be unique. The best way to achieve this is by
 * using `public constant` hash digests:
 *
 * ```
 * bytes32 public constant MY_ROLE = keccak256("MY_ROLE");
 * ```
 *
 * Roles can be used to represent a set of permissions. To restrict access to a
 * function call, use {hasRole}:
 *
 * ```
 * function foo() public {
 *     require(hasRole(MY_ROLE, msg.sender));
 *     ...
 * }
 * ```
 *
 * Roles can be granted and revoked dynamically via the {grantRole} and
 * {revokeRole} functions. Each role has an associated admin role, and only
 * accounts that have a role's admin role can call {grantRole} and {revokeRole}.
 *
 * By default, the admin role for all roles is `DEFAULT_ADMIN_ROLE`, which means
 * that only accounts with this role will be able to grant or revoke other
 * roles. More complex role relationships can be created by using
 * {_setRoleAdmin}.
 *
 * WARNING: The `DEFAULT_ADMIN_ROLE` is also its own admin: it has permission to
 * grant and revoke this role. Extra precautions should be taken to secure
 * accounts that have been granted it.
 */
abstract contract AccessControl is Context {
    using EnumerableSet for EnumerableSet.AddressSet;
    using Address for address;

    struct RoleData {
        EnumerableSet.AddressSet members;
        bytes32 adminRole;
    }

    mapping (bytes32 => RoleData) private _roles;

    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

    /**
     * @dev Emitted when `newAdminRole` is set as ``role``'s admin role, replacing `previousAdminRole`
     *
     * `DEFAULT_ADMIN_ROLE` is the starting admin for all roles, despite
     * {RoleAdminChanged} not being emitted signaling this.
     *
     * _Available since v3.1._
     */
    event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);

    /**
     * @dev Emitted when `account` is granted `role`.
     *
     * `sender` is the account that originated the contract call, an admin role
     * bearer except when using {_setupRole}.
     */
    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);

    /**
     * @dev Emitted when `account` is revoked `role`.
     *
     * `sender` is the account that originated the contract call:
     *   - if using `revokeRole`, it is the admin role bearer
     *   - if using `renounceRole`, it is the role bearer (i.e. `account`)
     */
    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

    /**
     * @dev Returns `true` if `account` has been granted `role`.
     */
    function hasRole(bytes32 role, address account) public view returns (bool) {
        return _roles[role].members.contains(account);
    }

    /**
     * @dev Returns the number of accounts that have `role`. Can be used
     * together with {getRoleMember} to enumerate all bearers of a role.
     */
    function getRoleMemberCount(bytes32 role) public view returns (uint256) {
        return _roles[role].members.length();
    }

    /**
     * @dev Returns one of the accounts that have `role`. `index` must be a
     * value between 0 and {getRoleMemberCount}, non-inclusive.
     *
     * Role bearers are not sorted in any particular way, and their ordering may
     * change at any point.
     *
     * WARNING: When using {getRoleMember} and {getRoleMemberCount}, make sure
     * you perform all queries on the same block. See the following
     * https://forum.openzeppelin.com/t/iterating-over-elements-on-enumerableset-in-openzeppelin-contracts/2296[forum post]
     * for more information.
     */
    function getRoleMember(bytes32 role, uint256 index) public view returns (address) {
        return _roles[role].members.at(index);
    }

    /**
     * @dev Returns the admin role that controls `role`. See {grantRole} and
     * {revokeRole}.
     *
     * To change a role's admin, use {_setRoleAdmin}.
     */
    function getRoleAdmin(bytes32 role) public view returns (bytes32) {
        return _roles[role].adminRole;
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function grantRole(bytes32 role, address account) public virtual {
        require(hasRole(_roles[role].adminRole, _msgSender()), "AccessControl: sender must be an admin to grant");

        _grantRole(role, account);
    }

    /**
     * @dev Revokes `role` from `account`.
     *
     * If `account` had been granted `role`, emits a {RoleRevoked} event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function revokeRole(bytes32 role, address account) public virtual {
        require(hasRole(_roles[role].adminRole, _msgSender()), "AccessControl: sender must be an admin to revoke");

        _revokeRole(role, account);
    }

    /**
     * @dev Revokes `role` from the calling account.
     *
     * Roles are often managed via {grantRole} and {revokeRole}: this function's
     * purpose is to provide a mechanism for accounts to lose their privileges
     * if they are compromised (such as when a trusted device is misplaced).
     *
     * If the calling account had been granted `role`, emits a {RoleRevoked}
     * event.
     *
     * Requirements:
     *
     * - the caller must be `account`.
     */
    function renounceRole(bytes32 role, address account) public virtual {
        require(account == _msgSender(), "AccessControl: can only renounce roles for self");

        _revokeRole(role, account);
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event. Note that unlike {grantRole}, this function doesn't perform any
     * checks on the calling account.
     *
     * [WARNING]
     * ====
     * This function should only be called from the constructor when setting
     * up the initial roles for the system.
     *
     * Using this function in any other way is effectively circumventing the admin
     * system imposed by {AccessControl}.
     * ====
     */
    function _setupRole(bytes32 role, address account) internal virtual {
        _grantRole(role, account);
    }

    /**
     * @dev Sets `adminRole` as ``role``'s admin role.
     *
     * Emits a {RoleAdminChanged} event.
     */
    function _setRoleAdmin(bytes32 role, bytes32 adminRole) internal virtual {
        emit RoleAdminChanged(role, _roles[role].adminRole, adminRole);
        _roles[role].adminRole = adminRole;
    }

    function _grantRole(bytes32 role, address account) private {
        if (_roles[role].members.add(account)) {
            emit RoleGranted(role, account, _msgSender());
        }
    }

    function _revokeRole(bytes32 role, address account) private {
        if (_roles[role].members.remove(account)) {
            emit RoleRevoked(role, account, _msgSender());
        }
    }
}

// File: contracts/XBRMaintained.sol

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

// import "openzeppelin-solidity/contracts/access/AccessControl.sol";


/**
 * XBR Network (and XBR Network Proxies) SCs inherit from this base contract
 * to manage network administration and maintenance via Role-based Access
 * Control (RBAC).
 * The implementation for management comes from the OpenZeppelin RBAC library.
 */
contract XBRMaintained is AccessControl {

    // Create a new role identifier for the minter role
    bytes32 public constant MAINTAINER_ROLE = keccak256("MAINTAINER_ROLE");

    /**
     * Event fired when a maintainer was added.
     *
     * @param account The account that was added as a maintainer.
     */
    event MaintainerAdded(address indexed account);

    /**
     * Event fired when a maintainer was removed.
     *
     * @param account The account that was removed as a maintainer.
     */
    event MaintainerRemoved(address indexed account);

    /// The constructor is internal (roles are managed by the OpenZeppelin base class).
    constructor () internal {
        _setupRole(MAINTAINER_ROLE, msg.sender);
    }

    /**
     * Modifier to require maintainer-role for the sender when calling a SC.
     */
    modifier onlyMaintainer () {
        require(isMaintainer(msg.sender));
        _;
    }

    /**
     * Check if the given address is currently a maintainer.
     *
     * @param account The account to check.
     * @return `true` if the account is maintainer, otherwise `false`.
     */
    function isMaintainer (address account) public view returns (bool) {
        return hasRole(MAINTAINER_ROLE, account);
    }

    /**
     * Add a new maintainer to the list of maintainers.
     *
     * @param account The account to grant maintainer rights to.
     */
    function addMaintainer (address account) public onlyMaintainer {
        _addMaintainer(account);
    }

    /**
     * Give away maintainer rights.
     */
    function renounceMaintainer () public {
        _removeMaintainer(msg.sender);
    }

    function _addMaintainer (address account) internal {
        grantRole(MAINTAINER_ROLE, account);
        emit MaintainerAdded(account);
    }

    function _removeMaintainer (address account) internal {
        revokeRole(MAINTAINER_ROLE, account);
        emit MaintainerRemoved(account);
    }
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
        // Block number when the member was (initially) registered in the XBR network.
        uint256 registered;

        // The IPFS Multihash of the XBR EULA being agreed to and stored as one
        // ZIP file archive on IPFS.
        string eula;

        // Optional public member profile. An IPFS Multihash of the member profile
        // stored in IPFS.
        string profile;

        // Current member level.
        MemberLevel level;

        // If the transaction to join the XBR network as a new member was was pre-signed
        // off-chain by the new member, this is the signature the user supplied. If the
        // user on-boarded by directly interacting with the XBR contracts on-chain, this
        // will be empty.
        bytes signature;
    }

    /// Container type for holding XBR Domain information.
    struct Domain {
        // Block number when the domain was created.
        uint256 created;

        // Domain sequence.
        uint32 seq;

        // Domain status
        DomainStatus status;

        // Domain owner.
        address owner;

        // Domain signing key (Ed25519 public key).
        bytes32 key;

        // Software stack license file on IPFS (required).
        string license;

        // Optional domain terms on IPFS.
        string terms;

        // Optional domain metadata on IPFS.
        string meta;

        bytes signature;

        // Nodes within the domain.
        bytes16[] nodes;
    }

    /// Container type for holding XBR Domain Nodes information.
    struct Node {
        // Block number when the node was paired to the respective domain.
        uint256 paired;

        bytes16 domain;

        // Type of node.
        NodeType nodeType;

        // Node key (Ed25519 public key).
        bytes32 key;

        // Optional (encrypted) node configuration on IPFS.
        string config;

        bytes signature;
    }

    /// Network level (global) stats for an XBR network member.
    struct MemberMarketStats {
        // Number of markets the member is currently owner (operator) of.
        uint32 marketsOwned;

        // Number of markets the member is currently joined to as a (buyer, seller, buyer+seller) actor.
        uint32 marketsJoined;

        // Total sum of consumer/provider securities put at stake as a buyer/seller-actor in any joined market.
        uint256 marketSecuritiesSent;

        uint256 marketSecuritiesReceived;
    }

    struct MemberChannelStats {
        uint32 paymentChannels;
        uint32 payingChannels;
        uint32 activePaymentChannels;
        uint32 activePayingChannels;
        // Total sum of deposits initially put into (currently still active / open) payment/paying channels by the buyer/seller-actor in any joined market.
        uint256 activePaymentChannelDeposits;
        uint256 activePayingChannelDeposits;
    }

    /// Container type for holding XBR market actor information.
    struct Actor {
        // Block number when the actor has joined the respective market.
        uint256 joined;

        // Security deposited by the actor when joining the market.
        uint256 security;

        // Metadata attached to an actor in a market.
        string meta;

        // This is the signature the user (actor) supplied for joining a market.
        bytes signature;

        // Current state of an actor in a market.
        ActorState state;

        // All payment (paying) channels of the respective buyer (seller) actor.
        address[] channels;

        mapping(address => mapping(bytes16 => Consent)) delegates;
    }

    /// Container type for holding XBR market information.
    struct Market {
        // Block number when the market was created.
        uint256 created;

        // Market sequence number.
        uint32 seq;

        // Market owner (aka "market operator").
        address owner;

        // The coin (ERC20 token) to be used in the market as the means of payment.
        address coin;

        // Market terms (IPFS Multihash).
        string terms;

        // Market metadata (IPFS Multihash).
        string meta;

        // Market maker address.
        address maker;

        // Security deposit required by data providers (sellers) to join the market.
        uint256 providerSecurity;

        // Security deposit required by data consumers (buyers) to join the market.
        uint256 consumerSecurity;

        // Market fee rate for the market operator.
        uint256 marketFee;

        // This is the signature the user (market owner/operator) supplied for opening the market.
        bytes signature;

        // Adresses of provider (seller) actors joined in the market.
        address[] providerActorAdrs;

        // Adresses of consumer (buyer) actors joined in the market.
        address[] consumerActorAdrs;

        // Provider (seller) actors joined in the market by actor address.
        mapping(address => Actor) providerActors;

        // Consumer (buyer) actors joined in the market by actor address.
        mapping(address => Actor) consumerActors;

        // Current payment channel by (buyer) delegate.
        mapping(address => address) currentPaymentChannelByDelegate;

        // Current paying channel by (seller) delegate.
        mapping(address => address) currentPayingChannelByDelegate;
    }

    /// Container type for holding XBR data service API information.
    struct Api {
        // Block number when the API was added to the respective catalog.
        uint256 published;

        // Multihash of API Flatbuffers schema (required).
        string schema;

        // Multihash of API meta-data (optional).
        string meta;

        // This is the signature the user (actor) supplied when publishing the API.
        bytes signature;
    }

    /// Container type for holding XBR catalog information.
    struct Catalog {
        // Block number when the catalog was created.
        uint256 created;

        // Catalog sequence number.
        uint32 seq;

        // Catalog owner (aka "catalog publisher").
        address owner;

        // Catalog terms (IPFS Multihash).
        string terms;

        // Catalog metadata (IPFS Multihash).
        string meta;

        // This is the signature the member supplied for creating the catalog.
        bytes signature;

        // The APIs part of this catalog.
        mapping(bytes16 => Api) apis;
    }

    struct Consent {
        // Block number when the catalog was created.
        uint256 updated;

        // Consent granted or revoked.
        bool consent;

        // The WAMP URI prefix to be used by the delegate in the data plane realm.
        string servicePrefix;

        // This is the signature the user (actor) supplied when setting the consent status.
        bytes signature;
    }

    /// Container type for holding channel static information.
    ///
    /// NOTE: This struct has a companion struct `ChannelState` with all
    /// varying state. The split-up is necessary as the EVM limits stack-depth
    /// to 16, and we need more channel attributes than that.
    struct Channel {
        // Block number when the channel was created.
        uint256 created;

        // Channel sequence number.
        uint32 seq;

        // Current payment channel type (either payment or paying channel).
        ChannelType ctype;

        // The XBR Market ID this channel is operating payments (or payouts) for.
        bytes16 marketId;

        // The channel ID.
        bytes16 channelId;

        // The sender of the payments in this channel. Either a XBR consumer (for
        // payment channels) or the XBR market maker (for paying channels).
        address actor;

        // The delegate of the channel, e.g. the XBR consumer delegate in case
        // of a payment channel or the XBR provider delegate in case of a paying
        // channel that is allowed to consume or provide data with off-chain
        // transactions and  payments running under this channel.
        address delegate;

        // The off-chain market maker that operates this payment or paying channel.
        address marketmaker;

        // Recipient of the payments in this channel. Either the XBR market operator
        // (for payment channels) or a XBR provider (for paying channels).
        address recipient;

        // Amount of tokens (denominated in the respective market token) held in
        // this channel (initially deposited by the actor).
        uint256 amount;

        // Signature supplied (by the actor) when opening the channel.
        bytes signature;
    }

    /// Container type for holding channel (closing) state information.
    struct ChannelClosingState {
        // Current payment channel state.
        ChannelState state;

        // Block timestamp when the channel was requested to close (before timeout).
        uint256 closingAt;

        // When this channel is closing, the sequence number of the closing transaction.
        uint32 closingSeq;

        // When this channel is closing, the off-chain closing balance of the closing transaction.
        uint256 closingBalance;

        // Block timestamp when the channel was closed (finally, after the timeout).
        uint256 closedAt;

        // When this channel has closed, the sequence number of the final accepted closing transaction.
        uint32 closedSeq;

        // When this channel is closing, the closing balance of the final accepted closing transaction.
        uint256 closedBalance;

        // Closing transaction signature by (buyer or seller) delegate supplied when requesting to close the channel.
        bytes delegateSignature;

        // Closing transaction signature by market maker supplied when requesting to close the channel.
        bytes marketmakerSignature;
    }

    /// EIP712 type for XBR as a type domain.
    struct EIP712Domain {
        // The type domain name, makes signatures from different domains incompatible.
        string  name;

        // The type domain version.
        string  version;
    }

    /// EIP712 type for use in member registration.
    struct EIP712MemberRegister {
        // Verifying chain ID, which binds the signature to that chain
        // for cross-chain replay-attack protection.
        uint256 chainId;

        // Verifying contract address, which binds the signature to that address
        // for cross-contract replay-attack protection.
        address verifyingContract;

        // Registered member address.
        address member;

        // Block number when the member registered in the XBR network.
        uint256 registered;

        // Multihash of EULA signed by the member when registering.
        string eula;

        // Optional profile meta-data multihash.
        string profile;
    }

    /// EIP712 type for use in member unregistration.
    struct EIP712MemberUnregister {
        // Verifying chain ID, which binds the signature to that chain
        // for cross-chain replay-attack protection.
        uint256 chainId;

        // Verifying contract address, which binds the signature to that address
        // for cross-contract replay-attack protection.
        address verifyingContract;

        // Address of the member that was unregistered.
        address member;

        // Block number when the member retired from the XBR network.
        uint256 retired;
    }

    /// EIP712 type for use in domain creation.
    struct EIP712DomainCreate {
        // Verifying chain ID, which binds the signature to that chain
        // for cross-chain replay-attack protection.
        uint256 chainId;

        // Verifying contract address, which binds the signature to that address
        // for cross-contract replay-attack protection.
        address verifyingContract;

        // The member that created the domain.
        address member;

        // Block number when the member registered in the XBR network.
        uint256 created;

        // The ID of the domain created (a 16 bytes UUID which is globally unique to that market).
        bytes16 domainId;

        // Domain signing key (Ed25519 public key).
        bytes32 domainKey;

        // Multihash for the license for the software stack running the domain.
        string license;

        // Multihash for the terms applying to this domain.
        string terms;

        // Multihash for optional meta-data supplied for the domain.
        string meta;
    }

    /// EIP712 type for use in publishing APIs to catalogs.
    struct EIP712NodePair {
        // Verifying chain ID, which binds the signature to that chain
        // for cross-chain replay-attack protection.
        uint256 chainId;

        // Verifying contract address, which binds the signature to that address
        // for cross-contract replay-attack protection.
        address verifyingContract;

        // The XBR network member pairing the node.
        address member;

        // Block number when the node was paired to the domain.
        uint256 paired;

        // The ID of the node to pair. Must be globally unique (not yet existing).
        bytes16 nodeId;

        // The ID of the domain to pair the node with.
        bytes16 domainId;

        // The type of node to pair the node under.
        NodeType nodeType;

        // The Ed25519 public node key.
        bytes32 nodeKey;

        // Optional IPFS Multihash pointing to node configuration stored on IPFS.
        string config;
    }

    /// EIP712 type for use in catalog creation.
    struct EIP712CatalogCreate {
        // Verifying chain ID, which binds the signature to that chain
        // for cross-chain replay-attack protection.
        uint256 chainId;

        // Verifying contract address, which binds the signature to that address
        // for cross-contract replay-attack protection.
        address verifyingContract;

        // The member that created the catalog.
        address member;

        // Block number when the member registered in the XBR network.
        uint256 created;

        // The ID of the catalog created (a 16 bytes UUID which is globally unique to that market).
        bytes16 catalogId;

        // Multihash for the terms applying to this catalog.
        string terms;

        // Multihash for optional meta-data supplied for the catalog.
        string meta;
    }

    /// EIP712 type for use in publishing APIs to catalogs.
    struct EIP712ApiPublish {
        // Verifying chain ID, which binds the signature to that chain
        // for cross-chain replay-attack protection.
        uint256 chainId;

        // Verifying contract address, which binds the signature to that address
        // for cross-contract replay-attack protection.
        address verifyingContract;

        // The XBR network member publishing the API.
        address member;

        // Block number when the API was published to the catalog.
        uint256 published;

        // The ID of the catalog the API is published to.
        bytes16 catalogId;

        // The ID of the API published.
        bytes16 apiId;

        // Multihash of API Flatbuffers schema (required).
        string schema;

        // Multihash of API meta-data (optional).
        string meta;
    }

    /// EIP712 type for use in market creation.
    struct EIP712MarketCreate {
        // Verifying chain ID, which binds the signature to that chain
        // for cross-chain replay-attack protection.
        uint256 chainId;

        // Verifying contract address, which binds the signature to that address
        // for cross-contract replay-attack protection.
        address verifyingContract;

        // The member that created the catalog.
        address member;

        // Block number when the market was created.
        uint256 created;

        // The ID of the market created (a 16 bytes UUID which is globally unique to that market).
        bytes16 marketId;

        // Coin used as means of payment in market. Must be an ERC20 compatible token.
        address coin;

        // Multihash for the market terms applying to this market.
        string terms;

        // Multihash for optional market meta-data supplied for the market.
        string meta;

        // The address of the market maker responsible for this market. The market
        // maker of a market is the link between off-chain channels and on-chain channels,
        // and operates the channels by processing transactions.
        address maker;

        // FIXME: enabling the following  runs into stack-depth limit of 12!
        //        => move to attributes (under "meta" multihash)

        // Any mandatory security that actors that join this market as data providers (selling data
        // as seller actors) must supply when joining this market. May be 0.
        // uint256 providerSecurity;

        // Any mandatory security that actors that join this market as data consumer (buying data
        // as buyer actors) must supply when joining this market. May be 0.
        // uint256 consumerSecurity;

        // The market fee that applies in this market. May be 0.
        uint256 marketFee;
    }

    /// EIP712 type for use in joining markets.
    struct EIP712MarketJoin {
        // Verifying chain ID, which binds the signature to that chain
        // for cross-chain replay-attack protection.
        uint256 chainId;

        // Verifying contract address, which binds the signature to that address
        // for cross-contract replay-attack protection.
        address verifyingContract;

        // The XBR network member joining the specified market as a market actor.
        address member;

        // Block number when the member as joined the market,
        uint256 joined;

        // The ID of the market joined.
        bytes16 marketId;

        // The actor type as which to join, which can be "buyer" or "seller" or "buyer+seller".
        uint8 actorType;

        // Optional multihash for additional meta-data supplied
        // for the actor joining the market.
        string meta;
    }

    /// EIP712 type for use in leaving markets.
    struct EIP712MarketLeave {
        // Verifying chain ID, which binds the signature to that chain
        // for cross-chain replay-attack protection.
        uint256 chainId;

        // Verifying contract address, which binds the signature to that address
        // for cross-contract replay-attack protection.
        address verifyingContract;

        // The XBR network member leaving the specified market as the given market actor type.
        address member;

        // Block number when the member left the market.
        uint256 left;

        // The ID of the market left.
        bytes16 marketId;

        // The actor type as which to leave, which can be "buyer" or "seller" or "buyer+seller".
        uint8 actorType;
    }

    /// EIP712 type for use in data consent tracking.
    struct EIP712Consent {
        // Verifying chain ID, which binds the signature to that chain
        // for cross-chain replay-attack protection.
        uint256 chainId;

        // Verifying contract address, which binds the signature to that address
        // for cross-contract replay-attack protection.
        address verifyingContract;

        // The XBR network member giving consent.
        address member;

        // Block number when the consent was status set.
        uint256 updated;

        // The ID of the market in which consent was given.
        bytes16 marketId;

        // Address of delegate consent (status) applies to.
        address delegate;

        // The actor type for which the consent was set for the delegate.
        uint8 delegateType;

        // The ID of the XBR data catalog consent was given for.
        bytes16 apiCatalog;

        // Consent granted or revoked.
        bool consent;

        // The WAMP URI prefix to be used by the delegate in the data plane realm.
        string servicePrefix;
    }

    /// EIP712 type for use in opening channels. The initial opening of a channel
    /// is one on-chain transaction (as is the final close), but all actual
    /// in-channel transactions happen off-chain.
    struct EIP712ChannelOpen {
        // Verifying chain ID, which binds the signature to that chain
        // for cross-chain replay-attack protection.
        uint256 chainId;

        // Verifying contract address, which binds the signature to that address
        // for cross-contract replay-attack protection.
        address verifyingContract;

        // The type of channel, can be payment channel (for use by buyer delegates) or
        // paying channel (for use by seller delegates).
        uint8 ctype;

        // Block number when the channel was opened.
        uint256 openedAt;

        // The ID of the market in which the channel was opened.
        bytes16 marketId;

        // The ID of the channel created (a 16 bytes UUID which is globally unique to that
        // channel, in particular the channel ID is unique even across different markets).
        bytes16 channelId;

        // The actor that created this channel.
        address actor;

        // The delegate authorized to use this channel for off-chain transactions.
        address delegate;

        // The address of the market maker that will operate the channel and
        // perform the off-chain transactions.
        address marketmaker;

        // The final recipient of the payout from the channel when the channel is closed.
        address recipient;

        // The amount of tokens initially put into this channel by the actor. The value is
        // denominated in the payment token used in the market.
        uint256 amount;
    }

    /// EIP712 type for use in closing channels.The final closing of a channel
    /// is one on-chain transaction (as is the final close), but all actual
    /// in-channel transactions happened before off-chain.
    struct EIP712ChannelClose {
        // Verifying chain ID, which binds the signature to that chain
        // for cross-chain replay-attack protection.
        uint256 chainId;

        // Verifying contract address, which binds the signature to that address
        // for cross-contract replay-attack protection.
        address verifyingContract;

        // Block number when the channel close was signed.
        uint256 closeAt;

        // The ID of the market in which the channel to be closed was initially opened.
        bytes16 marketId;

        // The ID of the channel to close.
        bytes16 channelId;

        // The sequence number of the channel closed.
        uint32 channelSeq;

        // The remaining closing balance at which the channel is closed.
        uint256 balance;

        // Indication whether the data signed is considered final, which amounts
        // to a promise that no further, newer signed data will be supplied later.
        bool isFinal;
    }

    // EIP712 type data.
    // solhint-disable-next-line
    bytes32 constant EIP712_DOMAIN_TYPEHASH = keccak256("EIP712Domain(string name,string version)");

    // EIP712 type data.
    // solhint-disable-next-line
    bytes32 constant EIP712_MEMBER_REGISTER_TYPEHASH = keccak256("EIP712MemberRegister(uint256 chainId,address verifyingContract,address member,uint256 registered,string eula,string profile)");

    // EIP712 type data.
    // solhint-disable-next-line
    bytes32 constant EIP712_MEMBER_UNREGISTER_TYPEHASH = keccak256("EIP712MemberUnregister(uint256 chainId,address verifyingContract,address member,uint256 retired)");

    // EIP712 type data.
    // solhint-disable-next-line
    bytes32 constant EIP712_DOMAIN_CREATE_TYPEHASH = keccak256("EIP712DomainCreate(uint256 chainId,address verifyingContract,address member,uint256 created,bytes16 domainId,bytes32 domainKey,string license,string terms,string meta)");

    // EIP712 type data.
    // solhint-disable-next-line
    bytes32 constant EIP712_NODE_PAIR_TYPEHASH = keccak256("EIP712NodePair(uint256 chainId,address verifyingContract,address member,uint256 paired,bytes16 nodeId,bytes16 domainId,uint8 nodeType,bytes32 nodeKey,string config)");

    // EIP712 type data.
    // solhint-disable-next-line
    bytes32 constant EIP712_CATALOG_CREATE_TYPEHASH = keccak256("EIP712CatalogCreate(uint256 chainId,address verifyingContract,address member,uint256 created,bytes16 catalogId,string terms,string meta)");

    // EIP712 type data.
    // solhint-disable-next-line
    bytes32 constant EIP712_API_PUBLISH_TYPEHASH = keccak256("EIP712ApiPublish(uint256 chainId,address verifyingContract,address member,uint256 published,bytes16 catalogId,bytes16 apiId,string terms,string meta)");

    // EIP712 type data.
    // solhint-disable-next-line
    bytes32 constant EIP712_MARKET_CREATE_TYPEHASH = keccak256("EIP712MarketCreate(uint256 chainId,address verifyingContract,address member,uint256 created,bytes16 marketId,address coin,string terms,string meta,address maker,uint256 marketFee)");

    // EIP712 type data.
    // solhint-disable-next-line
    bytes32 constant EIP712_MARKET_JOIN_TYPEHASH = keccak256("EIP712MarketJoin(uint256 chainId,address verifyingContract,address member,uint256 joined,bytes16 marketId,uint8 actorType,string meta)");

    // EIP712 type data.
    // solhint-disable-next-line
    bytes32 constant EIP712_MARKET_LEAVE_TYPEHASH = keccak256("EIP712MarketLeave(uint256 chainId,address verifyingContract,address member,uint256 left,bytes16 marketId,uint8 actorType)");

    // EIP712 type data.
    // solhint-disable-next-line
    bytes32 constant EIP712_CONSENT_TYPEHASH = keccak256("EIP712Consent(uint256 chainId,address verifyingContract,address member,uint256 updated,bytes16 marketId,address delegate,uint8 delegateType,bytes16 apiCatalog,bool consent)");

    // EIP712 type data.
    // solhint-disable-next-line
    bytes32 constant EIP712_CHANNEL_OPEN_TYPEHASH = keccak256("EIP712ChannelOpen(uint256 chainId,address verifyingContract,uint8 ctype,uint256 openedAt,bytes16 marketId,bytes16 channelId,address actor,address delegate,address marketmaker,address recipient,uint256 amount)");

    // EIP712 type data.
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

// File: contracts/XBRNetwork.sol

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

// https://openzeppelin.org/api/docs/math_SafeMath.html
// import "openzeppelin-solidity/contracts/math/SafeMath.sol";
// import "@openzeppelin/contracts/math/SafeMath.sol";





/**
 * The `XBR Network <https://github.com/crossbario/xbr-protocol/blob/master/contracts/XBRNetwork.sol>`__
 * contract is the on-chain anchor of and the entry point to the XBR protocol.
 */
contract XBRNetwork is XBRMaintained {

    // Add safe math functions to uint256 using SafeMath lib from OpenZeppelin
    using SafeMath for uint256;

    /// Event emitted when a new member registered in the XBR Network.
    event MemberRegistered (address indexed member, uint registered, string eula, string profile, XBRTypes.MemberLevel level);

    /// Event emitted when an existing member is changed (without leaving the XBR Network).
    event MemberChanged (address indexed member, uint changed, string eula, string profile, XBRTypes.MemberLevel level);

    /// Event emitted when a member leaves the XBR Network.
    event MemberRetired (address member, uint retired);

    /// Event emitted when the payable status of a coin is changed.
    event CoinChanged (address indexed coin, address operator, bool isPayable);

    /// Special addresses used as "any address" marker in mappings (eg coins).
    address public constant ANYADR = 0xFFfFfFffFFfffFFfFFfFFFFFffFFFffffFfFFFfF;

    /// Limit to how old a pre-signed transaction is accetable (eg in "registerMemberFor" and similar).
    uint256 public PRESIGNED_TXN_MAX_AGE = 1440;

    /// Chain ID of the blockchain this contract is running on, used in EIP712 typed data signature verification.
    uint256 public verifyingChain;

    /// Verifying contract address, used in EIP712 typed data signature verification.
    address public verifyingContract;

    /// IPFS multihash of the `XBR Network EULA <https://github.com/crossbario/xbr-protocol/blob/master/EULA>`__.
    string public eula = "QmUEM5UuSUMeET2Zo8YQtDMK74Fr2SJGEyTokSYzT3uD94";

    /// XBR network contributions from markets for the XBR project, expressed as a fraction of the total amount of XBR tokens.
    uint256 public contribution;

    /// Address of the XBR Networks' own ERC20 token for network-wide purposes.
    XBRToken public token;

    /// Address of the `XBR Network Organization <https://xbr.network/>`__.
    address public organization;

    /// Current XBR Network members ("member directory").
    mapping(address => XBRTypes.Member) public members;

    /// ERC20 coins which can specified as a means of payment when creating a new data market.
    mapping(address => mapping(address => bool)) public coins;

    /// Create the XBR network.
    ///
    /// @param networkToken The token to run this network itself on. Note that XBR data markets can use
    ///                     any ERC20 token (enabled in the ``coins`` mapping of this contract) as
    ///                     a means of payment in the respective market.
    /// @param networkOrganization The XBR network organization address.
    constructor (address networkToken, address networkOrganization) public {

        // read chain ID into temp local var (to avoid "TypeError: Only local variables are supported").
        uint256 chainId;
        assembly {
            chainId := chainid()
        }
        verifyingChain = chainId;
        verifyingContract = address(this);

        token = XBRToken(networkToken);
        coins[networkToken][ANYADR] = true;
        emit CoinChanged(networkToken, ANYADR, true);

        contribution = token.totalSupply() * 30 / 100;

        organization = networkOrganization;

        uint256 registered = block.timestamp;

        // technically, the creator of the XBR network contract instance is a XBR member (by definition).
        members[msg.sender] = XBRTypes.Member(registered, "", "", XBRTypes.MemberLevel.VERIFIED, "");
        emit MemberRegistered(msg.sender, registered, "", "", XBRTypes.MemberLevel.VERIFIED);
    }

    /// Register the sender of this transaction in the XBR network. All XBR stakeholders, namely data
    /// providers ("sellers"), data consumers ("buyers") and data market operators, must be registered
    /// in the XBR network.
    ///
    /// @param networkEula Multihash of the XBR EULA being agreed to and stored as one ZIP file archive on IPFS.
    /// @param memberProfile Optional public member profile: the IPFS Multihash of the member profile stored in IPFS.
    function registerMember (string memory networkEula, string memory memberProfile) public {
        _registerMember(msg.sender, block.number, networkEula, memberProfile, "");
    }

    /// Register the specified new member in the XBR Network. All XBR stakeholders, namely data
    /// providers ("sellers"), data consumers ("buyers") and data market operators, must be registered
    /// in the XBR network.
    ///
    /// Note: This version uses pre-signed data where the actual blockchain transaction is
    /// submitted by a gateway paying the respective gas (in ETH) for the blockchain transaction.
    ///
    /// @param member Address of the registering (new) member.
    /// @param registered Block number at which the registering member has created the signature.
    /// @param networkEula Multihash of the XBR EULA being agreed to and stored as one ZIP file archive on IPFS.
    /// @param memberProfile Optional public member profile: the IPFS Multihash of the member profile stored in IPFS.
    /// @param signature EIP712 signature, signed by the registering member.
    function registerMemberFor (address member, uint256 registered, string memory networkEula,
        string memory memberProfile, bytes memory signature) public {

        // verify signature
        require(XBRTypes.verify(member, XBRTypes.EIP712MemberRegister(verifyingChain, verifyingContract,
            member, registered, networkEula, memberProfile), signature), "INVALID_MEMBER_REGISTER_SIGNATURE");

        // signature must have been created in a window of PRESIGNED_TXN_MAX_AGE blocks from the current one
        require(registered <= block.number && (block.number <= PRESIGNED_TXN_MAX_AGE ||
            registered >= (block.number - PRESIGNED_TXN_MAX_AGE)), "INVALID_REGISTERED_BLOCK_NUMBER");

        _registerMember(member, registered, networkEula, memberProfile, signature);
    }

    function _registerMember (address member, uint256 registered, string memory networkEula, string memory profile, bytes memory signature) private {
        // check that sender is not already a member
        require(uint8(members[member].level) == 0, "MEMBER_ALREADY_REGISTERED");

        // check that the EULA the member accepted is the one we expect
        require(keccak256(abi.encode(networkEula)) ==
                keccak256(abi.encode(eula)), "INVALID_EULA");

        // remember the member
        members[member] = XBRTypes.Member(registered, networkEula, profile, XBRTypes.MemberLevel.ACTIVE, signature);

        // notify observers of new member
        emit MemberRegistered(member, registered, networkEula, profile, XBRTypes.MemberLevel.ACTIVE);
    }

    /// Unregister the sender of this transaction from the XBR network.
    function unregisterMember () public {
        _unregisterMember(msg.sender, block.number, "");
    }

    /// Unregister the specified member from the XBR Network.
    ///
    /// Note: This version uses pre-signed data where the actual blockchain transaction is
    /// submitted by a gateway paying the respective gas (in ETH) for the blockchain transaction.
    ///
    /// @param member Address of the unregistering (existing) member.
    /// @param retired Block number at which the unregistering member has created the signature.
    /// @param signature EIP712 signature, signed by the unregistering member.
    function unregisterMemberFor (address member, uint256 retired, bytes memory signature) public {

        // verify signature
        require(XBRTypes.verify(member, XBRTypes.EIP712MemberUnregister(verifyingChain, verifyingContract,
            member, retired), signature), "INVALID_SIGNATURE");

        // signature must have been created in a window of PRESIGNED_TXN_MAX_AGE blocks from the current one
        require(retired <= block.number && (block.number <= PRESIGNED_TXN_MAX_AGE ||
            retired >= (block.number - PRESIGNED_TXN_MAX_AGE)), "INVALID_BLOCK_NUMBER");

        _unregisterMember(member, retired, signature);
    }

    function _unregisterMember (address member, uint256 retired, bytes memory signature) private {
        // check that sender is currently a member
        require(members[member].level == XBRTypes.MemberLevel.ACTIVE ||
                members[member].level == XBRTypes.MemberLevel.VERIFIED, "MEMBER_NOT_REGISTERED");

        // remember the member left the network
        members[member].level = XBRTypes.MemberLevel.RETIRED;

        // notify observers of retired member
        emit MemberRetired(member, retired);
    }

    /// Set the XBR network organization address.
    ///
    /// @param networkToken The token to run this network itself on. Note that XBR data markets can use
    ///                     any ERC20 token (enabled in the ``coins`` mapping of this contract) as
    ///                     a means of payment in the respective market.
    function setNetworkToken (address networkToken) public onlyMaintainer returns (bool) {
        if (networkToken != address(token)) {
            coins[address(token)][ANYADR] = false;
            token = XBRToken(networkToken);
            coins[networkToken][ANYADR] = true;
            return true;
        } else {
            return false;
        }
    }

    /// Set the XBR network organization address.
    ///
    /// @param networkOrganization The XBR network organization address.
    function setNetworkOrganization (address networkOrganization) public onlyMaintainer returns (bool) {
        if (networkOrganization != address(organization)) {
            organization = networkOrganization;
            return true;
        } else {
            return false;
        }
    }

    /// Set (override manually) the member level of a XBR Network member. Being able to do so
    /// currently serves two purposes:
    ///
    /// - having a last resort to handle situation where members violated the EULA
    /// - being able to manually patch things in error/bug cases
    ///
    /// @param member The address of the XBR network member to override member level.
    /// @param level The member level to set the member to.
    function setMemberLevel (address member, XBRTypes.MemberLevel level) public onlyMaintainer returns (bool) {
        require(uint(members[msg.sender].level) != 0, "NO_SUCH_MEMBER");
        if (members[member].level != level) {
            members[member].level = level;
            emit MemberChanged(member, block.timestamp, members[member].eula, members[member].profile, level);
            return true;
        } else {
            return false;
        }
    }

    /// Set ERC20 coins as usable as a means of payment when opening data markets.
    ///
    /// @param coin The address of the ERC20 coin to change.
    /// @param isPayable When true, the coin can be specified when opening a new data market.
    function setCoinPayable (address coin, address operator, bool isPayable) public onlyMaintainer returns (bool) {
        if (coins[coin][operator] != isPayable) {
            coins[coin][operator] = isPayable;
            emit CoinChanged(coin, operator, isPayable);
            return true;
        } else {
            return false;
        }
    }

    /// Set the network contribution which is deducted from the market fees defined by a market operator.
    ///
    /// @param networkContribution Network contribution, defined as the ratio of given number of
    ///                            tokens and the total token supply.
    /// @return Flag indicating whether the contribution value was actually changed.
    function setContribution (uint256 networkContribution) public onlyMaintainer returns (bool) {
        require(networkContribution >= 0 && networkContribution <= token.totalSupply(), "INVALID_CONTRIBUTION");
        if (contribution != networkContribution) {
            contribution = networkContribution;
            return true;
        } else {
            return false;
        }
    }
}
