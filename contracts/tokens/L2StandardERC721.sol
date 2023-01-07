// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import {ERC721_Template} from "./ERC721_Template.sol";
import "../interfaces/IL2StandardERC721.sol";

contract L2StandardERC721 is IL2StandardERC721, ERC721_Template {
    address public l1Token;
    address public l2Bridge;
    string public baseURI;

    function initialize(
        address manager,
        address connectedToken_,
        string memory name,
        string memory symbol,
        string memory tokenURI
    ) public {
        require(l2Bridge == address(0x0) && l1Token == address(0x0), "Token is already initialized");
        l2Bridge = manager;
        l1Token = connectedToken_;
        baseURI = tokenURI;

        // setup meta data
        setupMetaData(name, symbol);
    }

    modifier onlyL2Bridge() {
        require(msg.sender == l2Bridge, "Only L2 Bridge can mint and burn");
        _;
    }

    // slither-disable-next-line external-function
    function mint(address _to, uint256 _tokenId) public virtual onlyL2Bridge {
        _mint(_to, _tokenId);

        emit Mint(_to, _tokenId);
    }

    // slither-disable-next-line external-function
    function burn(address _from, uint256 _tokenId) public virtual onlyL2Bridge {
        _burn(_tokenId);

        emit Burn(_from, _tokenId);
    }

    function setupMetaData(string memory _name, string memory _symbol) public {
        require(msg.sender == l2Bridge, "Invalid sender");
        _setupMetaData(_name, _symbol);
    }

    function _baseURI() internal view override returns (string memory) {
        return baseURI;
    }
}
