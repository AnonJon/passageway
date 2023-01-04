//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import {ICrossDomainMessenger} from "@eth-optimism/contracts/libraries/bridge/ICrossDomainMessenger.sol";

contract L1Controller {
    // Taken from https://github.com/ethereum-optimism/optimism/tree/develop/packages/contracts/deployments/goerli#layer-1-contracts
    address immutable crossDomainMessengerAddr = 0x5086d1eEF304eb5284A0f6720f79403b4e9bE294;

    address public L2Addrress;

    constructor(address l2Addr) {
        L2Addrress = l2Addr;
    }

    function setGreeting(string calldata _greeting) public {
        bytes memory message;

        message = abi.encodeWithSignature("setGreeting(string)", _greeting);

        ICrossDomainMessenger(crossDomainMessengerAddr).sendMessage(
            L2Addrress,
            message,
            1000000 // within the free gas limit amount
        );
    }

    function setL2Address(address l2Addr) external {
        L2Addrress = l2Addr;
    }
}
