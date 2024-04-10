// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./MultiSenderETH.sol";

/// @title main multi transfer settings
/// @author The-Poolz contract team
contract MultiSenderERC20Direct is MultiSenderETH {
    function MultiSendERC20Direct(
        address _token,
        MultiSendData[] calldata _multiSendData
    ) external payable erc20FullCheck1(_token, _multiSendData.length) {
        uint256 sum;
        for (uint256 i; i < _multiSendData.length; i++) {
            MultiSendData calldata data = _multiSendData[i];
            sum += _sendERC20From(_token, data);
        }
        emit MultiTransferredERC20(_token, _multiSendData.length, sum);
    }

    function MultiSendERC20DirectSameValue(
        address _token,
        address[] calldata _users,
        uint _amount
    ) external payable erc20FullCheck1(_token, _users.length) {
        for (uint256 i; i < _users.length; i++) {
            address user = _users[i];
            _sendERC20From(_token, user, _amount);
        }
        emit MultiTransferredERC20(
            _token,
            _users.length,
            _amount * _users.length
        );
    }

    function MultiSendERC20DirectGrouped(
        address _token,
        address[][] calldata _userGroups,
        uint[] calldata _amounts
    )
        external
        payable
        erc20FullCheck2(_token, _userGroups.length, _amounts.length)
    {
        uint sum;
        for (uint256 i; i < _userGroups.length; i++) {
            sum += _amounts[i] * _userGroups[i].length;
            for (uint256 j; j < _userGroups[i].length; j++) {
                address user = _userGroups[i][j];
                uint amount = _amounts[i];
                _sendERC20From(_token, user, amount);
            }
        }
        emit MultiTransferredERC20(_token, _userGroups.length, sum);
    }
}
