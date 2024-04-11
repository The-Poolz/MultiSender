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
        for (uint256 i; i < length; i++) {
            MultiSendData calldata data = _multiSendData[i];
            sum += _sendETH(data);
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
        for (uint256 i; i < length; i++) {
            address user = _users[i];
            _sendETH(user, _amount);
        }
        emit MultiTransferredETH(length, _amount * length);
    }

    /// @notice Sends variable amounts of ETH to groups of addresses.
    /// @dev For each group in `_userGroups`, sends the corresponding amount from `_amounts` to each address in the group.
    /// Requires the contract not to be paused and the `_amounts` array to not be zero in length.
    /// @param _userGroups An array of address arrays, each representing a group of users.
    /// @param _amounts An array of amounts of ETH to send, corresponding to each group in `_userGroups`.
    /// @return sum The total amount of ETH sent to all groups.
    function MultiSendETHGrouped(
        address[][] calldata _userGroups,
        uint[] calldata _amounts
    )
        external
        payable
        whenNotPaused
        notZero(_amounts.length)
        returns (uint256 sum)
    {
        uint length = _notZero(_userGroups.length);
        for (uint256 i; i < length; i++) {
            uint length2 = _notZero(_userGroups[i].length);
            sum += _amounts[i] * length2;
            for (uint256 j; j < length2; j++) {
                address user = _userGroups[i][j];
                uint amount = _amounts[i];
                _sendETH(user, amount);
            }
        }
        _validateValueAfterFee(sum);
        emit MultiTransferredETH(length, sum);
    }
}
