// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/security/Pausable.sol";
import "@poolzfinance/poolz-helper-v2/contracts/Fee/FeeBaseHelper.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/// @title MultiManageable: An abstract contract for managing MultiSenderV2 with administrative controls
abstract contract MultiManageable is FeeBaseHelper, Pausable {
    event MultiTransferredERC20(
        address indexed token,
        uint256 indexed userCount,
        uint256 indexed totalAmount
    );

    event MultiTransferredETH(uint256 indexed userCount, uint256 indexed totalAmount);

    error ETHTransferFail(address user, uint amount);
    error ArrayZeroLength();
    error NoZeroAddress();
    error TotalMismatch(uint amountProvided, uint amountRequired);

    struct MultiSendData {
        address user;
        uint amount;
    }

    /// @notice Ensures token is not paused and the address is not zero before proceeding
    /// @dev Modifier that calls `_baseStartUp` with token address checks
    modifier erc20FullCheck(address _token) {
        _baseStartUp(_token);
        _;
    }


    /// @notice Starts base operations, checks for paused state and zero address, and takes fee
    /// @dev Private function called by the `erc20FullCheck` modifier
    function _baseStartUp(address _token) private whenNotPaused {
        if (_token == address(0)) revert NoZeroAddress();
        TakeFee();
    }

    /// @notice Checks if a number is not zero, returns the same number if true
    /// @dev Internal pure function for validating non-zero values
    function _notZero(
        uint256 _number
    ) internal pure returns (uint256 _sameNumber) {
        if (_number == 0) revert ArrayZeroLength();
        return _number;
    }

    /// @notice Validates that the value after fee deduction matches the expected value
    /// @dev Takes a fee and compares the provided value with transaction value minus the fee
    function _validateValueAfterFee(uint _value) internal {
        uint feeTaken = TakeFee();
        _validateEqual(_value, msg.value - feeTaken);
    }

    /// @notice Validates that two values are equal, reverts if not
    /// @dev Internal pure function for value comparison
    function _validateEqual(uint _value, uint _value2) internal pure {
        if (_value != _value2) revert TotalMismatch(_value2, _value);
    }

    /// @notice Transfers ETH based on `MultiSendData`
    /// @dev Wraps `_sendETH` call to provide value return
    function _sendETH(
        MultiSendData calldata _multiSendData
    ) internal returns (uint value) {
        _sendETH(_multiSendData.user, _multiSendData.amount);
        return _multiSendData.amount;
    }

    /// @notice Calls ERC20 `transferFrom` to collect tokens before distribution
    /// @dev Allows contract to collect the specified amount of ERC20 tokens from the sender
    function _getERC20(address _token, uint _amount) internal {
        IERC20(_token).transferFrom(msg.sender, address(this), _amount);
    }

    /// @notice Transfers ERC20 tokens based on `MultiSendData`
    /// @dev Wraps `_sendERC20` call to provide value return
    function _sendERC20(
        address _token,
        MultiSendData calldata _multiSendData
    ) internal returns (uint value) {
        _sendERC20(_token, _multiSendData.user, _multiSendData.amount);
        return _multiSendData.amount;
    }

    /// @notice Directly transfers ERC20 tokens to a user
    /// @dev Uses ERC20 `transfer` to send specified amount to user
    function _sendERC20(address _token, address _user, uint _amount) internal {
        IERC20(_token).transfer(_user, _amount);
    }

    /// @notice Transfers ERC20 tokens from sender to recipient based on `MultiSendData`
    /// @dev Wraps `_sendERC20From` call for direct use in other functions
    function _sendERC20From(
        address _token,
        MultiSendData calldata _multiSendData
    ) internal returns (uint value) {
        _sendERC20From(_token, _multiSendData.user, _multiSendData.amount);
        return _multiSendData.amount;
    }

    /// @notice Allows contract to transfer ERC20 tokens from sender to a specified recipient
    /// @dev Uses ERC20 `transferFrom` for token distribution
    function _sendERC20From(
        address _token,
        address _to,
        uint _amount
    ) internal {
        IERC20(_token).transferFrom(msg.sender, _to, _amount);
    }

    /// @notice Sends ETH to a specified address, reverts on failure
    /// @dev Performs a low-level call to transfer ETH and handle failure
    function _sendETH(address _user, uint _amount) internal {
        (bool success, ) = _user.call{value: _amount}("");
        if (!success) revert ETHTransferFail(_user, _amount);
    }

    /// @notice Pauses the contract, disabling certain functions
    /// @dev Only callable by the owner or governance, wraps OpenZeppelin's `_pause`
    function Pause() public onlyOwnerOrGov {
        _pause();
    }

    /// @notice Unpauses the contract, re-enabling certain functions
    /// @dev Only callable by the owner or governance, wraps OpenZeppelin's `_unpause`
    function Unpause() public onlyOwnerOrGov {
        _unpause();
    }
}
