// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/security/Pausable.sol";
import "@poolzfinance/poolz-helper-v2/contracts/FeeBaseHelper.sol";

/// @title all admin settings
contract MultiManageable is FeeBaseHelper, Pausable {

    function Pause() public onlyOwnerOrGov {
        _pause();
    }

    function Unpause() public onlyOwnerOrGov {
        _unpause();
    }
}
