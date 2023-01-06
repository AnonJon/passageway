//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import {ICrossDomainMessenger} from "@eth-optimism/contracts/libraries/bridge/ICrossDomainMessenger.sol";

contract L2Controller {
    // Should be the same on all Optimism networks
    address immutable crossDomainMessengerAddr = 0x4200000000000000000000000000000000000007;

    address public L1Addrress;

    constructor(address l1Addr) {
        L1Addrress = l1Addr;
    }

    function setGreeting(string calldata _greeting) public {
        bytes memory message;

        message = abi.encodeWithSignature("setGreeting(string)", _greeting);

        ICrossDomainMessenger(crossDomainMessengerAddr).sendMessage(
            L1Addrress,
            message,
            1000000 // irrelevant here
        );
    }

    function setL1Address(address l1Addr) external {
        L1Addrress = l1Addr;
    }
}
