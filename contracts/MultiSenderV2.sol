// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./MultiSenderERC20Direct.sol";

/// @title main multi transfer settings
/// @author The-Poolz contract team
contract MultiSenderV2 is MultiSenderERC20Direct {
    function MultiSendERC20Indirect(
        address _token,
        uint256 _totalAmount,
        MultiSendData[] calldata _multiSendData
    ) external payable erc20FullCheck1(_token, _multiSendData.length) {
        uint256 sum;
        _getERC20(_token, _totalAmount);
        for (uint256 i; i < _multiSendData.length; i++) {
            sum += _sendERC20(_token, _multiSendData[i]);
        }
        _validateEqual(sum, _totalAmount);
        emit MultiTransferredERC20(_token, _multiSendData.length, sum);
    }

    function MultiSendERC20IndirectSameValue(
        address _token,
        address[] calldata _users,
        uint _amount
    ) external payable erc20FullCheck1(_token, _users.length) {
        uint sum = _amount * _users.length;
        _getERC20(_token, sum);
        for (uint256 i; i < _users.length; i++) {
            _sendERC20(_token, _users[i], _amount);
        }
        emit MultiTransferredERC20(_token, _users.length, sum);
    }

    function MultiSendERC20IndirectGrouped(
        address _token,
        uint256 _totalAmount,
        address[][] calldata _userGroups,
        uint[] calldata _amounts
    )
        external
        payable
        erc20FullCheck2(_token, _userGroups.length, _amounts.length)
    {
        uint sum;
        _getERC20(_token, _totalAmount);
        for (uint256 i; i < _userGroups.length; i++) {
            sum += _amounts[i] * _userGroups[i].length;
            for (uint256 j; j < _userGroups[i].length; j++) {
                _sendERC20(_token, _userGroups[i][j], _amounts[i]);
            }
        }
        _validateEqual(sum, _totalAmount);
        emit MultiTransferredERC20(_token, _userGroups.length, sum);
    }
}
