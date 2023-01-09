// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

/**
 * @title IL1ERC721Bridge
 */
interface IL1ERC721Bridge {
    event ERC721DepositInitiated(
        address indexed _l1Token, address indexed _from, address _to, uint256 _tokenId, bytes _data
    );

    event ERC721WithdrawalFinalized(
        address indexed _l1Token,
        address indexed _l2Token,
        address indexed _from,
        address _to,
        uint256 _tokenId,
        bytes _data
    );

    /**
     * @dev get the address of the corresponding L2 bridge contract.
     * @return Address of the corresponding L2 bridge contract.
     */
    function l2TokenBridge() external returns (address);

    /**
     * @dev deposit an amount of the ERC721 to the caller's balance on L2.
     * @param _l1Token Address of the L1 ERC721 we are depositing
     * @param _tokenId Amount of the ERC721 to deposit
     * @param _l2Gas Gas limit required to complete the deposit on L2.
     * @param _data Optional data to forward to L2. This data is provided
     *        solely as a convenience for external contracts. Aside from enforcing a maximum
     *        length, these contracts provide no guarantees about its content.
     */
    function depositERC721(address _l1Token, uint256 _tokenId, uint32 _l2Gas, bytes calldata _data) external;

    /**
     * @dev deposit an amount of ERC721 to a recipient's balance on L2.
     * @param _l1Token Address of the L1 ERC721 we are depositing
     * @param _to L2 address to credit the withdrawal to.
     * @param _tokenId Amount of the ERC721 to deposit.
     * @param _l2Gas Gas limit required to complete the deposit on L2.
     * @param _data Optional data to forward to L2.
     */
    function depositERC721To(address _l1Token, address _to, uint256 _tokenId, uint32 _l2Gas, bytes calldata _data)
        external;

    /**
     * @dev Complete a withdrawal from L2 to L1, and credit funds to the recipient's balance of the
     * L1 ERC721 token.
     *
     * @param _l1Token Address of L1 token to finalizeWithdrawal for.
     * @param _l2Token Address of L2 token where withdrawal was initiated.
     * @param _from L2 address initiating the transfer.
     * @param _to L1 address to credit the withdrawal to.
     * @param _tokenId Amount of the ERC721 to deposit.
     * @param _data Data provided by the sender on L2.
     */
    function finalizeERC721Withdrawal(
        address _l1Token,
        address _l2Token,
        address _from,
        address _to,
        uint256 _tokenId,
        bytes calldata _data
    ) external;
}
