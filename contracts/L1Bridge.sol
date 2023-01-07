// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import {IL1ERC721Bridge} from "./interfaces/IL1ERC721Bridge.sol";
import {IL2ERC721Bridge} from "./interfaces/IL2ERC721Bridge.sol";
import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import {CrossDomainEnabled} from "@eth-optimism/contracts/libraries/bridge/CrossDomainEnabled.sol";
import {Lib_PredeployAddresses} from "@eth-optimism/contracts/libraries/constants/Lib_PredeployAddresses.sol";
import {Address} from "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";

/**
 * @title L1Bridge
 */
contract L1Bridge is IL1ERC721Bridge, CrossDomainEnabled, IERC721Receiver {
    address public l2TokenBridge;

    // This contract lives behind a proxy, so the constructor parameters will go unused.
    constructor() CrossDomainEnabled(address(0)) {}

    /**
     * @param _l1messenger L1 Messenger address being used for cross-chain communications.
     * @param _l2TokenBridge L2 standard bridge address.
     */
    // slither-disable-next-line external-function
    function initialize(address _l1messenger, address _l2TokenBridge) public {
        require(messenger == address(0), "Contract has already been initialized.");
        messenger = _l1messenger;
        l2TokenBridge = _l2TokenBridge;
    }

    /**
     * @dev Modifier requiring sender to be EOA.  This check could be bypassed by a malicious
     *  contract via initcode, but it takes care of the user error we want to avoid.
     */
    modifier onlyEOA() {
        // Used to stop deposits from contracts (avoid accidentally lost tokens)
        require(!Address.isContract(msg.sender), "Account not EOA");
        _;
    }

    function depositERC721(address _l1Token, address _l2Token, uint256 _tokenId, uint32 _l2Gas, bytes calldata _data)
        external
        virtual
        onlyEOA
    {
        _initiateERC721Deposit(_l1Token, _l2Token, msg.sender, msg.sender, _tokenId, _l2Gas, _data);
    }

    function depositERC721To(
        address _l1Token,
        address _l2Token,
        address _to,
        uint256 _tokenId,
        uint32 _l2Gas,
        bytes calldata _data
    ) external virtual {
        _initiateERC721Deposit(_l1Token, _l2Token, msg.sender, _to, _tokenId, _l2Gas, _data);
    }

    /**
     * @dev Performs the logic for deposits by informing the L2 Deposited Token
     * contract of the deposit and calling a handler to lock the L1 funds. (e.g. transferFrom)
     *
     * @param _l1Token Address of the L1 ERC20 we are depositing
     * @param _l2Token Address of the L1 respective L2 ERC20
     * @param _from Account to pull the deposit from on L1
     * @param _to Account to give the deposit to on L2
     * @param _tokenId Amount of the ERC20 to deposit.
     * @param _l2Gas Gas limit required to complete the deposit on L2.
     * @param _data Optional data to forward to L2. This data is provided
     *        solely as a convenience for external contracts. Aside from enforcing a maximum
     *        length, these contracts provide no guarantees about its content.
     */
    function _initiateERC721Deposit(
        address _l1Token,
        address _l2Token,
        address _from,
        address _to,
        uint256 _tokenId,
        uint32 _l2Gas,
        bytes calldata _data
    ) internal {
        // When a deposit is initiated on L1, the L1 Bridge transfers the funds to itself for future
        // withdrawals. The use of safeTransferFrom enables support of "broken tokens" which do not
        // return a boolean value.
        // slither-disable-next-line reentrancy-events, reentrancy-benign
        IERC721(_l1Token).safeTransferFrom(_from, address(this), _tokenId);

        // Construct calldata for _l2Token.finalizeDeposit(_to, _amount)
        bytes memory message = abi.encodeWithSelector(
            IL2ERC721Bridge.finalizeDeposit.selector, _l1Token, _l2Token, _from, _to, _tokenId, _data
        );

        // slither-disable-next-line reentrancy-events, reentrancy-benign
        sendCrossDomainMessage(l2TokenBridge, _l2Gas, message);

        // slither-disable-next-line reentrancy-events
        emit ERC721DepositInitiated(_l1Token, _l2Token, _from, _to, _tokenId, _data);
    }

    function finalizeERC721Withdrawal(
        address _l1Token,
        address _l2Token,
        address _from,
        address _to,
        uint256 _tokenId,
        bytes calldata _data
    ) external onlyFromCrossDomainAccount(l2TokenBridge) {
        // When a withdrawal is finalized on L1, the L1 Bridge transfers the funds to the withdrawer
        // slither-disable-next-line reentrancy-events
        IERC721(_l1Token).safeTransferFrom(_from, _to, _tokenId);

        // slither-disable-next-line reentrancy-events
        emit ERC721WithdrawalFinalized(_l1Token, _l2Token, _from, _to, _tokenId, _data);
    }

    function onERC721Received(
        address, /* operator */
        address, /* from */
        uint256, /* tokenId */
        bytes calldata /* data */
    ) external pure override returns (bytes4) {
        return this.onERC721Received.selector;
    }
}
