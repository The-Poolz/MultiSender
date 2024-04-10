// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/security/Pausable.sol";
import "@poolzfinance/poolz-helper-v2/contracts/Fee/FeeBaseHelper.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/// @title all admin settings
abstract contract MultiManageable is FeeBaseHelper, Pausable {
    event MultiTransferredERC20(
        address token,
        uint256 userCount,
        uint256 totalAmount
    );

    event MultiTransferredETH(uint256 userCount, uint256 totalAmount);

    error ETHTransferFail(address user, uint amount);
    error ArrayZeroLength();
    error NoZeroAddress();
    error TotalMismatch(uint amountProvided, uint amountRequired);

    struct MultiSendData {
        address user;
        uint amount;
    }

    modifier erc20FullCheck(address _token) {
        _baseStartUp(_token);
        _;
    }

    modifier notZero(uint256 _number) {
        _notZero(_number);
        _;
    }

    function _baseStartUp(address _token) private whenNotPaused {
        if (_token == address(0)) revert NoZeroAddress();
        TakeFee();
    }

    function _notZero(
        uint256 _number
    ) internal pure returns (uint256 _sameNumber) {
        if (_number == 0) revert ArrayZeroLength();
        _sameNumber = _number;
    }

    function _validateValueAfterFee(uint _value) internal {
        uint feeTaken = TakeFee();
        _validateEqual(_value, msg.value - feeTaken);
    }

    function _validateEqual(uint _value, uint _value2) internal pure {
        if (_value != _value2) revert TotalMismatch(_value2, _value);
    }

    function _sendETH(
        MultiSendData calldata _multiSendData
    ) internal returns (uint value) {
        _sendETH(_multiSendData.user, _multiSendData.amount);
        value = _multiSendData.amount;
    }

    function _getERC20(address _token, uint _amount) internal {
        IERC20(_token).transferFrom(msg.sender, address(this), _amount);
    }

    function _sendERC20(
        address _token,
        MultiSendData calldata _multiSendData
    ) internal returns (uint value) {
        _sendERC20(_token, _multiSendData.user, _multiSendData.amount);
        value = _multiSendData.amount;
    }

    function _sendERC20(address _token, address _user, uint _amount) internal {
        IERC20(_token).transfer(_user, _amount);
    }

    function _sendERC20From(
        address _token,
        MultiSendData calldata _multiSendData
    ) internal returns (uint value) {
        _sendERC20From(_token, _multiSendData.user, _multiSendData.amount);
        value = _multiSendData.amount;
    }

    function _sendERC20From(
        address _token,
        address _to,
        uint _amount
    ) internal {
        IERC20(_token).transferFrom(msg.sender, _to, _amount);
    }

    function _sendETH(address _user, uint _amount) internal {
        (bool success, ) = _user.call{value: _amount}("");
        if (!success) revert ETHTransferFail(_user, _amount);
    }

    function Pause() public onlyOwnerOrGov {
        _pause();
    }

    function Unpause() public onlyOwnerOrGov {
        _unpause();
    }
}
