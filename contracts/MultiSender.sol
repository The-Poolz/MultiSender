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
    error ArrayZeroLength();
    error InvalidTokenAddress();

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

    modifier returnExtraTokens(address _tokenAddress) {
        uint beforeBalance = IERC20(_tokenAddress).balanceOf(address(this));
        _;
        uint afterBalance = IERC20(_tokenAddress).balanceOf(address(this));
        if(afterBalance > beforeBalance) {
            IERC20(_tokenAddress).transfer(msg.sender, afterBalance - beforeBalance);
        }
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
        returnExtraTokens(_token)
    {
        TakeFee();
        IERC20(_token).transferFrom(msg.sender, address(this), _totalAmount);
        for (uint256 i; i < _multiSendData.length; i++) {
            IERC20(_token).transfer(_multiSendData[i].user, _multiSendData[i].amount);
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
        external
        whenNotPaused
        validateToken(_token)
        notZeroLength(_multiSendData.length)
        returnExtraTokens(_token)
    {
        TakeFee();
        for (uint256 i; i < _multiSendData.length; i++) {
            IERC20(_token).transferFrom(msg.sender, _multiSendData[i].user, _multiSendData[i].amount);
        }
        emit MultiTransferredERC20(
            _token,
            _multiSendData.length,
            _totalAmount
        );
    }

}