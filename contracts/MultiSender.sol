// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@poolzfinance/poolz-helper-v2/contracts/Array.sol";
import "./MultiManageable.sol";

/// @title main multi transfer settings
/// @author The-Poolz contract team
contract MultiSender is MultiManageable {
    event MultiTransferredERC20(
        address token,
        uint256 userCount,
        uint256 totalAmount
    );

    event MultiTransferredETH(uint256 userCount, uint256 totalAmount);

    error InvalidEthAmount(uint requiredAmount);
    error FeeNotProvided(uint requiredFee);
    error EthTransferFail();

    struct MultiSendData {
        address user;
        uint amount;
    }

    modifier notZeroLength(uint256 _length) {
        require(_length != 0, "array can't be zero length");
        _;
    }

    function MultiSendEth(
        MultiSendData[] calldata _multiSendData
    )
        public
        payable
        whenNotPaused
        notZeroLength(_multiSendData.length)
    {
        uint256 fee = _calcFee();
        uint256 value = msg.value;
        PayFee(fee);
        if (fee > 0 && FeeToken == address(0)) value -= fee;
        for (uint256 i; i < _multiSendData.length; i++) {
            value -= _multiSendData[i].amount;
            (bool success, ) = _multiSendData[i].user.call{value: _multiSendData[i].amount}("");
            if (!success) revert EthTransferFail();
        }
        emit MultiTransferredETH(_multiSendData.length, msg.value - fee);
    }

    function MultiSendERC20Indirect(
        address _token,
        uint256 _totalAmount,
        MultiSendData[] calldata _multiSendData
    )
        public
        payable
        whenNotPaused
        notZeroLength(_multiSendData.length)
    {
        require(_token != address(0), "Invalid token address");
        uint256 fee = _calcFee();
        PayFee(fee);
        if (FeeToken == address(0) && msg.value != fee) revert FeeNotProvided(fee);
        IERC20(_token).transferFrom(msg.sender, address(this), _totalAmount);
        for (uint256 i; i < _multiSendData.length; i++) {
            IERC20(_token).transfer(_multiSendData[i].user, _multiSendData[i].amount);
        }
        uint256 remaining = IERC20(_token).balanceOf(address(this));
        if(remaining != 0) {
            IERC20(_token).transfer(msg.sender, remaining);
        }
        emit MultiTransferredERC20(
            _token,
            _multiSendData.length,
            _totalAmount
        );
    }
    
    function MultiSendERC20Direct(
        address _token,
        uint256 _totalAmount,
        MultiSendData[] calldata _multiSendData
    )
        public
        payable
        whenNotPaused
        notZeroLength(_multiSendData.length)
    {
        require(_token != address(0), "Invalid token address");
        uint256 fee = _calcFee();
        PayFee(fee);
        if (FeeToken == address(0) && msg.value != fee) revert FeeNotProvided(fee);
        for (uint256 i; i < _multiSendData.length; i++) {
            IERC20(_token).transferFrom(msg.sender, _multiSendData[i].user, _multiSendData[i].amount);
        }
        uint256 remaining = IERC20(_token).balanceOf(address(this));
        if(remaining != 0) {
            IERC20(_token).transfer(msg.sender, remaining);
        }
        emit MultiTransferredERC20(
            _token,
            _multiSendData.length,
            _totalAmount
        );
    }

    function _calcFee() internal returns (uint256) {
        if (WhiteListAddress == address(0)) return 0;
        uint256 discount = IWhiteList(WhiteListAddress).Check(
            msg.sender,
            WhiteListId
        );
        if (discount < Fee) {
            IWhiteList(WhiteListAddress).Register(
                msg.sender,
                WhiteListId,
                discount
            );
            return Fee - discount;
        }
        IWhiteList(WhiteListAddress).Register(msg.sender, WhiteListId, Fee);
        return 0;
    }
}
