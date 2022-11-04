// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

import "./INewtroDrops.sol";

//   ___   __    ______   __ __ __   _________  ______    ______       ______   ______    ______   ______   ______
//  /__/\ /__/\ /_____/\ /_//_//_/\ /________/\/_____/\  /_____/\     /_____/\ /_____/\  /_____/\ /_____/\ /_____/\  
//  \::\_\\  \ \\::::_\/_\:\\:\\:\ \\__.::.__\/\:::_ \ \ \:::_ \ \    \:::_ \ \\:::_ \ \ \:::_ \ \\:::_ \ \\::::_\/_
//   \:. `-\  \ \\:\/___/\\:\\:\\:\ \  \::\ \   \:(_) ) )_\:\ \ \ \    \:\ \ \ \\:(_) ) )_\:\ \ \ \\:(_) \ \\:\/___/\
//    \:. _    \ \\::___\/_\:\\:\\:\ \  \::\ \   \: __ `\ \\:\ \ \ \    \:\ \ \ \\: __ `\ \\:\ \ \ \\: ___\/ \_::._\:\
//     \. \`-\  \ \\:\____/\\:\\:\\:\ \  \::\ \   \ \ `\ \ \\:\_\ \ \    \:\/.:| |\ \ `\ \ \\:\_\ \ \\ \ \     /____\:\
//      \__\/ \__\/ \_____\/ \_______\/   \__\/    \_\/ \_\/ \_____\/     \____/_/ \_\/ \_\/ \_____\/ \_\/     \_____\/
//

/// @title Newtro Drops
/// @author Nicolás Acosta | nicoacosta.eth | @0xnico_ | linktr.ee/nicoacosta.eth
/// @notice Airdrops Newtro Arts NFTs
/// @dev Given a list of addresses and a metadata URI, creates ERC1155 token and airdrops to addresses
contract NewtroDrops is INewtroDrops, ERC1155, Ownable, AccessControl {
    using Counters for Counters.Counter;

    /// @notice Collection name
    /// @return Collection name
    string public name;

    /// @notice Collection symbol
    /// @return Collection symbol
    string public symbol;

    /// @dev ERC1155 token id counter
    Counters.Counter private _tokenIds;

    /// @dev Metadata URI for each token id
    mapping(uint256 => string) private _uris;

    /// @dev Contract metadata URI
    string private _contractURI;

    /// @notice Dropper access control role
    /// @dev @openzeppelin's AccessControl role
    /// @return Dropper access control role
    // solhint-disable var-name-mixedcase
    bytes32 public DROPPER_ROLE = keccak256("DROPPER_ROLE");

    constructor(string memory contractURI_) ERC1155("") {
        // set (immutable) collection name and symbol
        name = "Newtro Drops";
        symbol = "NEWTRO";

        // set contract metadata URI
        _contractURI = contractURI_;

        // grant default admin and dropper roles for contract deployer (and owner)
        _grantRole(DROPPER_ROLE, msg.sender);
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    /// @notice Airdrops a new NFT
    /// @dev Given a list of addresses and a metadata URI, creates ERC1155 token and airdrops to recipients
    /// @param recipients airdrop recipients
    /// @param tokenURI NFT metadata URI
    function airdrop(address[] memory recipients, string memory tokenURI)
        external
        onlyRole(DROPPER_ROLE)
    {
        uint256 recipientsAmount = recipients.length;

        // recipients amount must be greater than 0
        require(recipientsAmount > 0, "No recipients to airdrop");

        // get new token id
        _tokenIds.increment();
        uint256 tokenId = _tokenIds.current();

        // for every recipient...
        for (uint256 i = 0; i < recipientsAmount; ++i) {
            address recipient = recipients[i];

            // cannot have already received token
            require(
                balanceOf(recipient, tokenId) == 0,
                "Cannot be airdropped twice"
            );

            // airdrop NFT
            _mint(recipient, tokenId, 1, "");
        }

        // set metadata URI for airdropped NFT
        _uris[tokenId] = tokenURI;
    }

    /// @notice Returns metadata URI for a given token id
    /// @param tokenId NFT token id
    /// @return NFT metadata URI
    function uri(uint256 tokenId) public view override returns (string memory) {
        return _uris[tokenId];
    }

    /// @notice Returns collection URI
    /// @return Collection URI
    function contractURI() external view returns (string memory) {
        return _contractURI;
    }

    /// @notice Transfers contract ownership and droppers' role administration
    /// @dev Overrides contract owner, calls super and transfers OZ AC DEFAULT_ADMIN_ROLE to new owner
    /// @param newOwner New owner
    function transferOwnership(address newOwner) public override onlyOwner {
        // Calls default @openzeppelin's Ownable transferOwnership
        Ownable.transferOwnership(newOwner);

        // Transfers default admin role to newOwner
        _revokeRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(DEFAULT_ADMIN_ROLE, newOwner);
    }

    /// @notice Cannot renounce ownership. Transfer ownership instead.
    /// @dev Reverts
    function renounceOwnership() public view override onlyOwner {
        revert("Transfer ownership instead");
    }

    /// @notice Withdraw contract ETH balance. Just in case contract receives some.
    /// @param recipient ETH balance recipient
    function withdrawETH(address recipient) external onlyOwner {
        uint256 balance = address(this).balance;

        // Balance must be greater than 0
        require(balance > 0, "No balance to withdraw");

        // Transfer ETH
        payable(recipient).transfer(balance);
    }

    /// @notice Withdraw ERC20 token balance. Just in case contract receives some.
    /// @param recipient Token recipient
    function withdrawERC20(address tokenAddress, address recipient)
        external
        onlyOwner
    {
        IERC20 token = IERC20(tokenAddress);

        // Balance must be greater than 0
        uint256 balance = token.balanceOf(address(this));
        require(balance > 0, "No balance to withdraw");

        // Transfer token
        token.transfer(recipient, balance);
    }

    /// @inheritdoc	ERC1155
    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(AccessControl, ERC1155, IERC165)
        returns (bool)
    {
        return
            AccessControl.supportsInterface(interfaceId) ||
            ERC1155.supportsInterface(interfaceId);
    }
}
