// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./MultiSenderERC20Direct.sol";

/// @title A contract for batch sending ERC20 tokens indirectly to multiple addresses
/// @notice This contract extends MultiSenderERC20Direct to support indirect ERC20 token transfers, where tokens are first collected from the sender then distributed
/// @author The-Poolz contract team
contract MultiSenderV2 is MultiSenderERC20Direct {
    
    /// @notice Collects a specified total amount of ERC20 tokens from the sender and sends varying amounts to multiple addresses
    /// @param _token The ERC20 token address to be sent
    /// @param _totalAmount The total amount of ERC20 tokens to collect from the sender
    /// @param _multiSendData An array of `MultiSendData` structs containing recipient addresses and amounts
    /// @return sum The total amount of tokens distributed
    /// @dev Ensures the total collected amount equals the sum of individual amounts sent; emits a `MultiTransferredERC20` event
    function MultiSendERC20Indirect(
        address _token,
        uint256 _totalAmount,
        MultiSendData[] calldata _multiSendData
    ) external payable erc20FullCheck(_token) returns (uint256 sum) {
        uint length = _notZero(_multiSendData.length);
        _getERC20(_token, _totalAmount);
        for (uint256 i; i < length; i++) {
            MultiSendData calldata data = _multiSendData[i];
            sum += _sendERC20(_token, data);
        }
        _validateEqual(sum, _totalAmount);
        emit MultiTransferredERC20(_token, length, sum);
    }

    /// @notice Collects a total amount of ERC20 tokens from the sender based on a fixed amount per recipient, and sends this amount to each address
    /// @param _token The ERC20 token address to be sent
    /// @param _users An array of recipient addresses
    /// @param _amount The amount of tokens to send to each address
    /// @dev Calculates the total amount by multiplying the number of users by the fixed amount; emits a `MultiTransferredERC20` event
    function MultiSendERC20IndirectSameValue(
        address _token,
        address[] calldata _users,
        uint _amount
    ) external payable erc20FullCheck(_token) {
        uint length = _notZero(_users.length);
        uint sum = _amount * length;
        _getERC20(_token, sum);
        for (uint256 i; i < length; i++) {
            address user = _users[i];
            _sendERC20(_token, user, _amount);
        }
        emit MultiTransferredERC20(_token, length, sum);
    }

    /// @notice Collects a specified total amount of ERC20 tokens from the sender and distributes varying amounts to groups of addresses
    /// @param _token The ERC20 token address to be sent
    /// @param _totalAmount The total amount of ERC20 tokens to collect from the sender
    /// @param _userGroups An array of address arrays, each representing a group of recipients
    /// @param _amounts An array of amounts, each corresponding to a group in `_userGroups`
    /// @return sum The total amount of tokens distributed
    /// @dev Ensures the total collected amount equals the sum of the specified distributions; emits a `MultiTransferredERC20` event
    function MultiSendERC20IndirectGrouped(
        address _token,
        uint256 _totalAmount,
        address[][] calldata _userGroups,
        uint[] calldata _amounts
    )
        external
        payable
        erc20FullCheck(_token)
        notZero(_amounts.length)
        returns (uint256 sum)
    {
        _getERC20(_token, _totalAmount);
        uint length = _notZero(_userGroups.length);
        for (uint256 i; i < length; i++) {
            uint length2 = _notZero(_userGroups[i].length);
            sum += _amounts[i] * length2;
            for (uint256 j; j < length2; j++) {
                address user = _userGroups[i][j];
                uint amount = _amounts[i];
                _sendERC20(_token, user, amount);
            }
        }
        _validateEqual(sum, _totalAmount);
        emit MultiTransferredERC20(_token, length, sum);
    }
}
