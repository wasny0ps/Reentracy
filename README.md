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
