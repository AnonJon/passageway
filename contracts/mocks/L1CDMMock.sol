// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

contract L1CDMMock {
    event MessageSent(address indexed _target, bytes _message, uint32 _gasLimit);

    function sendMessage(address _target, bytes memory _message, uint32 _gasLimit) external {
        emit MessageSent(_target, _message, _gasLimit);
    }
}
