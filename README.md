# Reentracy Attack
## 🗺️ Overview 
The Reentrancy attack is one of the most destructive attacks in the Solidity smart contract. A reentrancy attack occurs when a function makes an external call to another untrusted contract. Then the untrusted contract makes a recursive call back to the original function in an attempt to drain funds.



When the contract fails to update its state before sending funds, the attacker can continuously call the withdraw function to drain the contract’s funds. A famous real-world Reentrancy attack is the DAO attack which caused a loss of 60 million US dollars.

## How Does Reentracy Attack Work?
[<img src='https://github.com/wasny0ps/wasny0ps/blob/main/images/python.png' alt='python' height='60'>](https://www.python.org/)
