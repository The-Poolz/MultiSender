// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@poolzfinance/poolz-helper-v2/contracts/Array.sol";
import "./MultiManageable.sol";

/// @title main multi transfer settings
/// @author The-Poolz contract team
contract MultiSenderV2 is MultiManageable {

    function MultiSendETH(
        MultiSendData[] calldata _multiSendData
    )
        external
        payable
        whenNotPaused
        notZeroLength(_multiSendData.length)
    {
        uint value = _getValueAfterFee();
        uint sum;
        for (uint256 i; i < _multiSendData.length; i++) {
            sum += _multiSendData[i].amount;
            _sendETH(_multiSendData[i].user, _multiSendData[i].amount);
        }
        if (value != sum) revert TotalMismatch(value, sum);
        emit MultiTransferredETH(_multiSendData.length, sum);
    }

    function MultiSendETHSameValue(
        address[] calldata _users,
        uint _amount
    )
        external
        payable
        whenNotPaused
        notZeroLength(_users.length)
    {
        uint value = _getValueAfterFee();
        uint sum = _amount * _users.length;
        if (value != sum) revert TotalMismatch(value, sum);
        for (uint256 i; i < _users.length; i++) {
            _sendETH(_users[i], _amount);
        }
        emit MultiTransferredETH(_users.length, sum);
    }

    function MultiSendETHGrouped(
        address[][] calldata _userGroups,
        uint[] calldata _amounts
    )
        external
        payable
        whenNotPaused
        notZeroLength(_userGroups.length)
        notZeroLength(_amounts.length)
    {
        uint value = _getValueAfterFee();
        uint sum;
        for (uint256 i; i < _userGroups.length; i++) {
            sum += _amounts[i] * _userGroups[i].length;
            for (uint256 j; j < _userGroups[i].length; j++) {
                _sendETH(_userGroups[i][j], _amounts[i]);
            }
        }
        if (value != sum) revert TotalMismatch(value, sum);
        emit MultiTransferredETH(_userGroups.length, sum);
    }

    function MultiSendERC20Indirect(
        address _token,
        uint256 _totalAmount,
        MultiSendData[] calldata _multiSendData
    )
        external
        payable
        whenNotPaused
        validateToken(_token)
        notZeroLength(_multiSendData.length)
    {
        TakeFee();
        uint256 sum;
        IERC20(_token).transferFrom(msg.sender, address(this), _totalAmount);
        for (uint256 i; i < _multiSendData.length; i++) {
            sum += _multiSendData[i].amount;
            IERC20(_token).transfer(_multiSendData[i].user, _multiSendData[i].amount);
        }
        if (sum != _totalAmount) revert TotalMismatch(_totalAmount,  sum);
        emit MultiTransferredERC20(
            _token,
            _multiSendData.length,
            sum
        );
    }

    function MultiSendERC20IndirectSameValue(
        address _token,
        address[] calldata _users,
        uint _amount
    )
        external
        payable
        whenNotPaused
        validateToken(_token)
        notZeroLength(_users.length)
    {
        TakeFee();
        uint sum = _amount * _users.length;
        IERC20(_token).transferFrom(msg.sender, address(this), sum);
        for (uint256 i; i < _users.length; i++) {
            IERC20(_token).transfer(_users[i], _amount);
        }
        emit MultiTransferredERC20(
            _token,
            _users.length,
            sum
        );
    }

    function MultiSendERC20IndirectGrouped(
        address _token,
        uint256 _totalAmount,
        address[][] calldata _userGroups,
        uint[] calldata _amounts
    )
        external
        payable
        whenNotPaused
        validateToken(_token)
        notZeroLength(_userGroups.length)
        notZeroLength(_amounts.length)
    {
        TakeFee();
        uint sum;
        IERC20(_token).transferFrom(msg.sender, address(this), _totalAmount);
        for (uint256 i; i < _userGroups.length; i++) {
            sum += _amounts[i] * _userGroups[i].length;
            for (uint256 j; j < _userGroups[i].length; j++) {
                IERC20(_token).transfer(_userGroups[i][j], _amounts[i]);
            }
        }
        if (sum != _totalAmount) revert TotalMismatch(_totalAmount, sum);
        emit MultiTransferredERC20(
            _token,
            _userGroups.length,
            sum
        );
    }
    
    function MultiSendERC20Direct(
        address _token,
        MultiSendData[] calldata _multiSendData
    )
        external
        payable
        whenNotPaused
        validateToken(_token)
        notZeroLength(_multiSendData.length)
    {
        TakeFee();
        uint256 sum;
        for (uint256 i; i < _multiSendData.length; i++) {
            sum += _multiSendData[i].amount;
            IERC20(_token).transferFrom(msg.sender, _multiSendData[i].user, _multiSendData[i].amount);
        }
        emit MultiTransferredERC20(
            _token,
            _multiSendData.length,
            sum
        );
    }

    function MultiSendERC20DirectSameValue(
        address _token,
        address[] calldata _users,
        uint _amount
    )
        external
        payable
        whenNotPaused
        validateToken(_token)
        notZeroLength(_users.length)
    {
        TakeFee();
        for (uint256 i; i < _users.length; i++) {
            IERC20(_token).transferFrom(msg.sender, _users[i], _amount);
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
        whenNotPaused
        validateToken(_token)
        notZeroLength(_userGroups.length)
        notZeroLength(_amounts.length)
    {
        TakeFee();
        uint sum;
        for (uint256 i; i < _userGroups.length; i++) {
            sum += _amounts[i] * _userGroups[i].length;
            for (uint256 j; j < _userGroups[i].length; j++) {
                IERC20(_token).transferFrom(msg.sender, _userGroups[i][j], _amounts[i]);
            }
        }
        emit MultiTransferredERC20(
            _token,
            _userGroups.length,
            sum
        );
    }
}