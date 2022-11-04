// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";

interface INewtroDrops is IERC1155 {
    /// @notice Airdrops a new NFT
    /// @dev Given a list of addresses and a metadata URI, creates ERC1155 token and airdrops to addresses
    /// @param recipients airdrop recipients
    /// @param tokenURI NFT metadata URI
    function airdrop(address[] memory recipients, string memory tokenURI)
        external;

    /// @notice Returns collection URI
    /// @return Collection URI
    function contractURI() external view returns (string memory);

    /// @notice Withdraw contract ETH balance. Just in case contract receives some.
    /// @param recipient ETH balance recipient
    function withdrawETH(address recipient) external;

    /// @notice Withdraw ERC20 token balance. Just in case contract receives some.
    /// @param recipient Token recipient
    function withdrawERC20(address tokenAddress, address recipient) external;
}
