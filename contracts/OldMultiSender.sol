// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "poolz-helper-v2/contracts/Array.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "poolz-helper-v2/contracts/FeeBaseHelper.sol";
import "poolz-helper-v2/contracts/interfaces/IWhiteList.sol";

/// @title main multi transfer settings
/// @author The-Poolz contract team


/// @title all admin settings
contract MultiManageable is FeeBaseHelper, Pausable {
    uint256 public UserLimit;
    address public WhiteListAddress;
    uint256 public WhiteListId;

    function setUserLimit(uint256 _userLimit) public onlyOwnerOrGov {
        UserLimit = _userLimit;
    }

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

contract OldMultiSender is MultiManageable {
    event MultiTransferredERC20(
        address token,
        uint256 userCount,
        uint256 totalAmount
    );

    event MultiTransferredETH(uint256 userCount, uint256 totalAmount);

    error InvalidEthAmount(uint requiredAmount);
    error FeeNotProvided(uint requiredFee);

    constructor() {
        UserLimit = 500;
    }

    modifier checkArrLength(uint256 _userLength, uint256 _balancesLength) {
        require(_userLength == _balancesLength, "invalid input data!");
        _;
    }

    modifier notZeroLength(uint256 _length) {
        require(_length != 0, "array can't be zero length");
        _;
    }

    modifier checkUserLimit(uint256 _userLength) {
        require(UserLimit >= _userLength, "Invalid user limit");
        _;
    }

    function MultiSendEth(
        address payable[] calldata _users,
        uint256[] calldata _balances
    )
        public
        payable
        whenNotPaused
        checkArrLength(_users.length, _balances.length)
        notZeroLength(_users.length)
        checkUserLimit(_users.length)
    {
        uint256 fee = _calcFee();
        uint256 value = msg.value;
        PayFee(fee);
        if (fee > 0 && FeeToken == address(0)) value -= fee;
        uint256 amount = Array.getArraySum(_balances);
        if(value != amount) revert InvalidEthAmount(amount + fee);
        for (uint256 i; i < _users.length; i++) {
            _users[i].transfer(_balances[i]);
        }
        emit MultiTransferredETH(_users.length, amount);
    }

    function MultiSendERC20(
        address _token,
        address[] memory _users,
        uint256[] calldata _balances
    )
        public
        payable
        whenNotPaused
        checkArrLength(_users.length, _balances.length)
        notZeroLength(_users.length)
        checkUserLimit(_users.length)
    {
        require(_token != address(0), "Invalid token address");
        uint256 fee = _calcFee();
        PayFee(fee);
        if (FeeToken == address(0) && msg.value != fee) revert FeeNotProvided(fee);
        for (uint256 i; i < _users.length; i++) {
            IERC20(_token).transferFrom(msg.sender, _users[i], _balances[i]);
        }
        emit MultiTransferredERC20(
            _token,
            _users.length,
            Array.getArraySum(_balances)
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
