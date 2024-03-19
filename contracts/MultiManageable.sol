// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/security/Pausable.sol";
import "@poolzfinance/poolz-helper-v2/contracts/FeeBaseHelper.sol";
import "@poolzfinance/poolz-helper-v2/contracts/interfaces/IWhiteList.sol";

/// @title all admin settings
contract MultiManageable is FeeBaseHelper, Pausable {
    address public WhiteListAddress;
    uint256 public WhiteListId;

    function setWhiteListAddress(address _whiteListAddr) public onlyOwnerOrGov {
        WhiteListAddress = _whiteListAddr;
    }

    function setWhiteListId(uint256 _id) public onlyOwnerOrGov {
        WhiteListId = _id;
    }

    function Pause() public onlyOwnerOrGov {
        _pause();
    }

    function Unpause() public onlyOwnerOrGov {
        _unpause();
    }
}
