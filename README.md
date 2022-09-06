# MultiSender
[![Build Status](https://api.travis-ci.com/The-Poolz/MultiSender.svg?token=qArPwDxVjiye5pPqiscU)](https://app.travis-ci.com/github/The-Poolz/MultiSender)

Implementation to efficiently send thousands of tokens to multiple addresses through batching and process automation.


### Navigation

- [Installation](#installation)
- [Multisending](#multisending)

#### Installation

```console
npm install
```

#### Testing

```console
truffle run coverage
```

#### Deploy

```console
truffle dashboard
```

```console
truffle migrate --f 1 --to 1 --network dashboard
```

### Multisending

There are currently two types of sending tokens. Sending default coins and **ERC20** tokens.

**1.** Send ETH (BNB, MATIC, etc.).
```solidity
/// @param _users - addresses that receive tokens
/// @param _balances - how many tokens we sent to each address
/// @notice this is a payable function, which means that we need to send ether which will be received by the recipients
function MultiSendEth(address payable[] calldata _users, uint256[] calldata _balances) payable
```
Testnet tx: [link](https://testnet.bscscan.com/tx/0xfe5488d9511b4a8eebbddc9d80dbdc59925698ab3ab49b0c0efb950692a924c4)

**2.** Send ERC20
```solidity
/// @param _token - the address of the ERC20 token we want to send
/// @param _users - addresses that receive tokens
/// @param _balances - how many tokens we sent to each address
function MultiSendERC20(
        address _token,
        address[] memory _users,
        uint256[] calldata _balances
    )
```

Testnet tx: [link](https://testnet.bscscan.com/tx/0xcd08db502d5dd5e6db122c178b2fbbae75bd30519712e1051dcc76c84cc20e54)