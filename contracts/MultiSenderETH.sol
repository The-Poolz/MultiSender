// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./MultiManageable.sol";

/// @title Main multi transfer settings contract
/// @dev Extends `MultiManageable` to enable multi-sending of ETH with various utilities.
/// @author The-Poolz contract team
contract MultiSenderETH is MultiManageable {

    /// @notice Sends ETH to multiple addresses with different amounts.
    /// @dev Iterates over the `_multiSendData` array, sending ETH to each specified address.
    /// Requires the contract not to be paused.
    /// @param _multiSendData An array of `MultiSendData` structs, each containing an address and the amount of ETH to send.
    /// @return sum The total amount of ETH sent.
    function MultiSendETH(
        MultiSendData[] calldata _multiSendData
    ) external payable whenNotPaused returns (uint256 sum) {
        uint length = _notZero(_multiSendData.length);
        for (uint256 i; i < length; ) {
            MultiSendData calldata data = _multiSendData[i];
            sum += _sendETH(data);
            unchecked {
                ++i;
            }
        }
        _validateValueAfterFee(sum);
        emit MultiTransferredETH(length, sum);
    }

    /// @notice Sends the same amount of ETH to multiple addresses.
    /// @dev Iterates over the `_users` array, sending the specified `_amount` of ETH to each.
    /// Requires the contract not to be paused.
    /// @param _users An array of addresses to receive ETH.
    /// @param _amount The amount of ETH to send to each address.
    function MultiSendETHSameValue(
        address[] calldata _users,
        uint _amount
    ) external payable whenNotPaused {
        uint length = _notZero(_users.length);
        _validateValueAfterFee(_amount * length);
        for (uint256 i; i < length; ) {
            address user = _users[i];
            _sendETH(user, _amount);
            unchecked {
                ++i;
            }
        }
        emit MultiTransferredETH(length, _amount * length);
    }
}
