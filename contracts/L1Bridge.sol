// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import {IL1ERC721Bridge} from "./interfaces/IL1ERC721Bridge.sol";
import {IL2ERC721Bridge} from "./interfaces/IL2ERC721Bridge.sol";
import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import {CrossDomainEnabled} from "@eth-optimism/contracts/libraries/bridge/CrossDomainEnabled.sol";
import {Address} from "@openzeppelin/contracts/utils/Address.sol";
import {Clone} from "./lib/Clone.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

/**
 * @title L1Bridge
 */
contract L1Bridge is IL1ERC721Bridge, CrossDomainEnabled, IERC721Receiver, Clone {
    address public l2TokenBridge;
    address owner;
    // L1 token address => L2 token address
    mapping(address => address) public tokenMapping;
    bytes32 public templateCodeHash;

    // This contract lives behind a proxy, so the constructor parameters will go unused.
    constructor() CrossDomainEnabled(address(0)) {}

    /**
     * @param _l1messenger L1 Messenger address being used for cross-chain communications.
     * @param _l2TokenBridge L2 standard bridge address.
     */
    // slither-disable-next-line external-function
    function initialize(address _l1messenger, address _l2TokenBridge, address template) public {
        require(messenger == address(0), "Contract has already been initialized.");
        templateCodeHash = keccak256(minimalProxyCreationCode(template));
        messenger = _l1messenger;
        l2TokenBridge = _l2TokenBridge;
        owner = msg.sender;
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

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function.");
        _;
    }

    function depositERC721(address _l1Token, uint256 _tokenId, uint32 _l2Gas, bytes calldata _data)
        external
        virtual
        onlyEOA
    {
        _initiateERC721Deposit(_l1Token, msg.sender, msg.sender, _tokenId, _l2Gas, _data);
    }

    function depositERC721To(address _l1Token, address _to, uint256 _tokenId, uint32 _l2Gas, bytes calldata _data)
        external
        virtual
    {
        _initiateERC721Deposit(_l1Token, msg.sender, _to, _tokenId, _l2Gas, _data);
    }

    /**
     * @dev Performs the logic for deposits by informing the L2 Deposited Token
     * contract of the deposit and calling a handler to lock the L1 funds. (e.g. transferFrom)
     *
     * @param _l1Token Address of the L1 ERC721 we are depositing
     * @param _from Account to pull the deposit from on L1
     * @param _to Account to give the deposit to on L2
     * @param _tokenId Amount of the ERC721 to deposit.
     * @param _l2Gas Gas limit required to complete the deposit on L2.
     *
     */
    function _initiateERC721Deposit(
        address _l1Token,
        address _from,
        address _to,
        uint256 _tokenId,
        uint32 _l2Gas,
        bytes calldata /*_data*/
    ) internal {
        ERC721 token = ERC721(_l1Token);
        string memory name = token.name();
        string memory symbol = token.symbol();
        string memory baseURI = token.tokenURI(_tokenId);
        if (!_checkMapping(_l1Token)) {
            // compute child token address before deployment
            bytes32 salt = keccak256(abi.encodePacked(token));
            address l2Token = computedCreate2Address(salt, templateCodeHash, l2TokenBridge);
            tokenMapping[_l1Token] = l2Token;
        }
        bytes memory tokenData = abi.encode(name, symbol, baseURI);
        // When a deposit is initiated on L1, the L1 Bridge transfers the funds to itself for future
        // withdrawals. The use of safeTransferFrom enables support of "broken tokens" which do not
        // return a boolean value.
        // slither-disable-next-line reentrancy-events, reentrancy-benign
        IERC721(_l1Token).safeTransferFrom(_from, address(this), _tokenId);

        // Construct calldata for _l2Token.finalizeDeposit(_to, _amount)
        bytes memory message =
            abi.encodeWithSelector(IL2ERC721Bridge.finalizeDeposit.selector, _l1Token, _from, _to, _tokenId, tokenData);

        // slither-disable-next-line reentrancy-events, reentrancy-benign
        sendCrossDomainMessage(l2TokenBridge, _l2Gas, message);

        // slither-disable-next-line reentrancy-events
        emit ERC721DepositInitiated(_l1Token, _from, _to, _tokenId, tokenData);
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

    // probably not needed
    function setL2Bridge(address bridge) external onlyOwner {
        require(bridge == address(0x0), "L1BRIDGE: L2BRIDGE ALREADY SET");
        l2TokenBridge = bridge;
    }

    function _checkMapping(address token) internal view returns (bool) {
        if (tokenMapping[token] != address(0)) {
            return true;
        }
        return false;
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
