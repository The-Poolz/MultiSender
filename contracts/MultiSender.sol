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
