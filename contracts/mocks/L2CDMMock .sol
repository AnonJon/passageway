// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

contract L2CDMMock {
    address public l1TokenBridge;

    event MessageSent(address indexed _target, bytes _message, uint32 _gasLimit);

    constructor(address _l1TokenBridge) {
        l1TokenBridge = _l1TokenBridge;
    }

    function sendMessage(address _target, bytes memory _message, uint32 _gasLimit) external {
        emit MessageSent(_target, _message, _gasLimit);
    }

    function xDomainMessageSender() external view returns (address) {
        return l1TokenBridge;
    }
}
