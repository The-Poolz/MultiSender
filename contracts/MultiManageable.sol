// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/security/Pausable.sol";
import "@poolzfinance/poolz-helper-v2/contracts/Fee/FeeBaseHelper.sol";

/// @title all admin settings
contract MultiManageable is FeeBaseHelper, Pausable {
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

    modifier notZeroLength(uint256 _length) {
        if (_length == 0) revert ArrayZeroLength();
        _;
    }

    modifier notZeroAddress(address _address) {
        if (_address == address(0)) revert NoZeroAddress();
        _;
    }

    function _getValueAfterFee() internal returns (uint newValue) {
        uint feeTaken = TakeFee();
        newValue = msg.value;
        if (feeTaken > 0 && FeeToken == address(0)) newValue -= feeTaken;
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
