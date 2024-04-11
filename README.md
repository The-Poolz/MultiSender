
# MultiSenderV2

This project allows for the efficient batch sending of MainCoin(ETH, BNB etc) and ERC20 tokens to multiple recipients. It's designed to facilitate operations such as airdrops, payroll distributions, and any scenario requiring mass payments. The project is built on Solidity ^0.8.0 and utilizes OpenZeppelin's contracts for security features, along with Poolz Finance's helper contracts for fee management.


## Conceptual Overview

The MultiSender contract offers a versatile solution for distributing MainCoin and ERC20 tokens to multiple addresses in a cost-efficient manner. It provides several methods for batch sending, allowing the sender to select the most gas-efficient approach based on the specific distribution needs. The sender's responsibility is to evaluate each method's gas consumption and choose the optimal one, whether for sending varying amounts to individual addresses, the same amount to all recipients, or managing distributions to grouped addresses. This design ensures flexibility while optimizing for gas efficiency and transaction cost savings.


## Contracts Overview

### MultiSenderETH

Extends `MultiManageable` to enable multi-sending of MainCoin.

#### Key Functions:

- `MultiSendETH(MultiSendData[] calldata _multiSendData)`: Sends ETH to multiple addresses with different amounts.

- `MultiSendETHSameValue(address[] calldata _users, uint _amount)`: Sends the same amount of ETH to multiple addresses.

- `MultiSendETHGrouped(address[][] calldata _userGroups, uint[] calldata _amounts)`: Sends variable amounts of ETH to groups of addresses.

### MultiSenderERC20Direct

Extends `MultiSenderETH` for direct multi-sending of ERC20 tokens. This sends the tokens directly from the sender to the recipients.

#### Key Functions:

- `MultiSendERC20Direct(address _token, MultiSendData[] calldata _multiSendData)`: Sends specified amounts of an ERC20 token to multiple addresses.

- `MultiSendERC20DirectSameValue(address _token, address[] calldata _users, uint _amount)`: Sends the same amount of an ERC20 token to multiple addresses.

- `MultiSendERC20DirectGrouped(address _token, address[][] calldata _userGroups, uint[] calldata _amounts)`: Sends varying amounts of an ERC20 token to multiple groups of addresses.

### MultiSenderV2

Extends `MultiSenderERC20Direct` to support indirect multi-sending of ERC20 tokens. This first collects the tokens from the sender before distributing them to the recipients.

#### Key Functions:

- `MultiSendERC20Indirect(address _token, uint256 _totalAmount, MultiSendData[] calldata _multiSendData)`: Collects a specified total amount of ERC20 tokens and sends varying amounts to multiple addresses.

- `MultiSendERC20IndirectSameValue(address _token, address[] calldata _users, uint _amount)`: Collects a total amount of ERC20 tokens based on a fixed amount per recipient and sends this amount to each address.

- `MultiSendERC20IndirectGrouped(address _token, uint256 _totalAmount, address[][] calldata _userGroups, uint[] calldata _amounts)`: Collects a specified total amount of ERC20 tokens and distributes varying amounts to groups of addresses.

## How to Interact with the Contracts

1. **Deploy the Contracts**: Begin by deploying the `MultiSenderV2` contract, which includes all functionalities.
2. **Choose the Right Function**: Depending on your needs, select the appropriate multi-send function and provide the necessary parameters, such as recipient addresses, amounts, and, for ERC20 transfers, the token address.
3. **Consider Fee Management**: Be aware of the fee structure implemented by the contract and account for it in your transactions.

This README provides a comprehensive guide to understanding and interacting with the `MultiSender` project's smart contracts. Always conduct thorough testing in a development environment before deploying to the main network.
