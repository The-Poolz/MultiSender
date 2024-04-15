// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./MultiSenderETH.sol";

/// @title A contract for batch sending ERC20 tokens directly to multiple addresses
/// @notice This contract extends MultiSenderETH to support direct ERC20 token transfers, where token are sent from the sender directly to recipients
/// @author The-Poolz contract team
contract MultiSenderERC20Direct is MultiSenderETH {
    
    /// @notice Sends specified amounts of an ERC20 token to multiple addresses
    /// @param _token The ERC20 token address to send
    /// @param _multiSendData An array of `MultiSendData` structs containing recipient addresses and amounts
    /// @return sum The total amount of tokens sent
    /// @dev Emits a `MultiTransferredERC20` event upon completion
    function MultiSendERC20Direct(
        address _token,
        MultiSendData[] calldata _multiSendData
    ) external payable erc20FullCheck(_token) returns (uint256 sum) {
        uint length = _notZero(_multiSendData.length);
        for (uint256 i; i < length; ) {
            MultiSendData calldata data = _multiSendData[i];
            sum += _sendERC20From(_token, data);
            unchecked {
                ++i;
            }
        }
        emit MultiTransferredERC20(_token, length, sum);
    }

    /// @notice Sends the same amount of an ERC20 token to multiple addresses
    /// @param _token The ERC20 token address to send
    /// @param _users An array of recipient addresses
    /// @param _amount The amount of tokens to send to each address
    /// @dev Emits a `MultiTransferredERC20` event upon completion with the total tokens sent
    function MultiSendERC20DirectSameValue(
        address _token,
        address[] calldata _users,
        uint _amount
    ) external payable erc20FullCheck(_token) {
        uint length = _notZero(_users.length);
        for (uint256 i; i < length; ) {
            address user = _users[i];
            _sendERC20From(_token, user, _amount);
            unchecked {
                ++i;
            }
        }
        emit MultiTransferredERC20(_token, length, _amount * length);
    }
}
