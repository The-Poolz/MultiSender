// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./MultiSenderETH.sol";

/// @title main multi transfer settings
/// @author The-Poolz contract team
contract MultiSenderERC20Direct is MultiSenderETH {
    function MultiSendERC20Direct(
        address _token,
        MultiSendData[] calldata _multiSendData
    ) external payable erc20FullCheck(_token) {
        uint256 sum;
        uint length = _notZero(_multiSendData.length);
        for (uint256 i; i < length; i++) {
            MultiSendData calldata data = _multiSendData[i];
            sum += _sendERC20From(_token, data);
        }
        emit MultiTransferredERC20(_token, length, sum);
    }

    function MultiSendERC20DirectSameValue(
        address _token,
        address[] calldata _users,
        uint _amount
    ) external payable erc20FullCheck(_token) {
        uint length = _notZero(_users.length);
        for (uint256 i; i < length; i++) {
            address user = _users[i];
            _sendERC20From(_token, user, _amount);
        }
        emit MultiTransferredERC20(
            _token,
            length,
            _amount * length
        );
    }

    function MultiSendERC20DirectGrouped(
        address _token,
        address[][] calldata _userGroups,
        uint[] calldata _amounts
    )
        external
        payable
        erc20FullCheck(_token)
    {
        _notZero(_amounts.length);
        uint sum;
        uint length = _notZero(_userGroups.length);
        for (uint256 i; i < length; i++) {
            uint length2 = _notZero(_userGroups[i].length);
            sum += _amounts[i] * length2;
            for (uint256 j; j < length2; j++) {
                address user = _userGroups[i][j];
                uint amount = _amounts[i];
                _sendERC20From(_token, user, amount);
            }
        }
        emit MultiTransferredERC20(_token, length, sum);
    }
}
