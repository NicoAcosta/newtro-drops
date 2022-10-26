// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Newtro is ERC1155, Ownable, AccessControl {
    string public name;
    string public symbol;

    mapping(uint256 => bool) private _alreadySetURI;
    mapping(uint256 => string) private _uris;

    bytes32 public MINTER_ROLE = keccak256("MINTER_ROLE");

    constructor() ERC1155("") {
        name = "Newtro Drops";
        symbol = "NEWTRO";

        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    function transferOwnership(address newOwner) public override onlyOwner {
        Ownable.transferOwnership(newOwner);

        _revokeRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(DEFAULT_ADMIN_ROLE, newOwner);
    }

    function mintBatch(address[] memory addresses, uint256 tokenId)
        public
        onlyRole(MINTER_ROLE)
    {
        for (uint256 i = 0; i < addresses.length; ++i) {
            _mint(addresses[i], tokenId, 1, "");
        }
    }

    function setURI(uint256 tokenId, string memory tokenURI)
        external
        onlyOwner
    {
        // cannot be set twice for same tokenId
        require(!_alreadySetURI[tokenId], "URI already set");

        _uris[tokenId] = tokenURI;
        _alreadySetURI[tokenId] = true;
    }

    function uri(uint256 tokenId) public view override returns (string memory) {
        return _uris[tokenId];
    }

    // In case the contract receives ETH
    function withdrawETH(address recipient) external onlyOwner {
        uint256 balance = address(this).balance;
        require(balance > 0, "No balance to withdraw");

        payable(recipient).transfer(balance);
    }

    // In case the contract receives some ERC20 token
    function withdrawERC20(address tokenAddress, address recipient)
        external
        onlyOwner
    {
        IERC20 token = IERC20(tokenAddress);

        uint256 balance = token.balanceOf(address(this));
        require(balance > 0, "No balance to withdraw");

        token.transfer(recipient, balance);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(AccessControl, ERC1155)
        returns (bool)
    {
        return
            AccessControl.supportsInterface(interfaceId) ||
            ERC1155.supportsInterface(interfaceId);
    }
}
