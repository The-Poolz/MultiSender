// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./MultiManageable.sol";

/// @title main multi transfer settings
/// @author The-Poolz contract team
contract MultiSenderETH is MultiManageable {
    function MultiSendETH(
        MultiSendData[] calldata _multiSendData
    ) external payable whenNotPaused {
        uint sum;
        uint length = _notZero(_multiSendData.length);
        for (uint256 i; i < length; i++) {
            MultiSendData calldata data = _multiSendData[i];
            sum += _sendETH(data);
        }
        _validateValueAfterFee(sum);
        emit MultiTransferredETH(length, sum);
    }

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

    function MultiSendETHGrouped(
        address[][] calldata _userGroups,
        uint[] calldata _amounts
    ) external payable whenNotPaused notZero(_amounts.length) {
        uint sum;
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
