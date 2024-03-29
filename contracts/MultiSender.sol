// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@poolzfinance/poolz-helper-v2/contracts/Array.sol";
import "./MultiManageable.sol";

/// @title main multi transfer settings
/// @author The-Poolz contract team
contract MultiSenderV2 is MultiManageable {
    event MultiTransferredERC20(
        address token,
        uint256 userCount,
        uint256 totalAmount
    );

    event MultiTransferredETH(uint256 userCount, uint256 totalAmount);

    error InvalidEthAmount(uint requiredAmount);
    error FeeNotProvided(uint requiredFee);
    error EthTransferFail();
    error ArrayZeroLength();
    error InvalidTokenAddress();
    error TotalMismatch(bool isParamHigher);

    struct MultiSendData {
        address user;
        uint amount;
    }

    modifier notZeroLength(uint256 _length) {
        if (_length == 0) revert ArrayZeroLength();
        _;
    }

    modifier validateToken(address _token) {
        if (_token == address(0)) revert InvalidTokenAddress();
        _;
    }

    function MultiSendEth(
        MultiSendData[] calldata _multiSendData
    )
        external
        payable
        whenNotPaused
        notZeroLength(_multiSendData.length)
    {
        uint feeTaken = TakeFee();
        uint256 value = msg.value;
        if (feeTaken > 0 && FeeToken == address(0)) value -= feeTaken;
        for (uint256 i; i < _multiSendData.length; i++) {
            value -= _multiSendData[i].amount;
            (bool success, ) = _multiSendData[i].user.call{value: _multiSendData[i].amount}("");
            if (!success) revert EthTransferFail();
        }
        emit MultiTransferredETH(_multiSendData.length, msg.value - feeTaken);
    }

    function MultiSendERC20Indirect(
        address _token,
        uint256 _totalAmount,
        MultiSendData[] calldata _multiSendData
    )
        external
        whenNotPaused
        validateToken(_token)
        notZeroLength(_multiSendData.length)
    {
        TakeFee();
        IERC20(_token).transferFrom(msg.sender, address(this), _totalAmount);
        uint256 sum;
        for (uint256 i; i < _multiSendData.length; i++) {
            sum += _multiSendData[i].amount;
            IERC20(_token).transfer(_multiSendData[i].user, _multiSendData[i].amount);
        }
        if (sum != _totalAmount) revert TotalMismatch( _totalAmount > sum );
        emit MultiTransferredERC20(
            _token,
            _multiSendData.length,
            sum
        );
    }
    
    function MultiSendERC20Direct(
        address _token,
        MultiSendData[] calldata _multiSendData
    )
        external
        whenNotPaused
        validateToken(_token)
        notZeroLength(_multiSendData.length)
    {
        TakeFee();
        uint256 totalAmount;
        for (uint256 i; i < _multiSendData.length; i++) {
            totalAmount += _multiSendData[i].amount;
            IERC20(_token).transferFrom(msg.sender, _multiSendData[i].user, _multiSendData[i].amount);
        }
        emit MultiTransferredERC20(
            _token,
            _multiSendData.length,
            totalAmount
        );
    }

}