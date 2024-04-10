// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./MultiManageable.sol";

/// @title main multi transfer settings
/// @author The-Poolz contract team
contract MultiSenderETH is MultiManageable {
    function MultiSendETH(
        MultiSendData[] calldata _multiSendData
    ) external payable whenNotPaused notZero(_multiSendData.length) {
        uint sum;
        for (uint256 i; i < _multiSendData.length; i++) {
            MultiSendData calldata data = _multiSendData[i];
            sum += _sendETH(data);
        }
        _validateValueAfterFee(sum);
        emit MultiTransferredETH(_multiSendData.length, sum);
    }

    function MultiSendETHSameValue(
        address[] calldata _users,
        uint _amount
    ) external payable whenNotPaused notZero(_users.length) {
        _validateValueAfterFee(_amount * _users.length);
        for (uint256 i; i < _users.length; i++) {
            address user = _users[i];
            _sendETH(user, _amount);
        }
        emit MultiTransferredETH(_users.length, _amount * _users.length);
    }

    function MultiSendETHGrouped(
        address[][] calldata _userGroups,
        uint[] calldata _amounts
    )
        external
        payable
        whenNotPaused
        notZero(_userGroups.length)
        notZero(_amounts.length)
    {
        uint sum;
        for (uint256 i; i < _userGroups.length; i++) {
            sum += _amounts[i] * _userGroups[i].length;
            for (uint256 j; j < _userGroups[i].length; j++) {
                address user = _userGroups[i][j];
                uint amount = _amounts[i];
                _sendETH(user, amount);
            }
        }
        _validateValueAfterFee(sum);
        emit MultiTransferredETH(_userGroups.length, sum);
    }
}
