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
        for (uint256 i; i < length; ) {
            MultiSendData calldata data = _multiSendData[i];
            sum += _sendERC20(_token, data);
            unchecked {
                ++i;
            }
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
        for (uint256 i; i < length; ) {
            address user = _users[i];
            _sendERC20(_token, user, _amount);
            unchecked{
                ++i;
            }
        }
        emit MultiTransferredERC20(_token, length, sum);
    }
}
