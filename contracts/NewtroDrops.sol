// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

///  ___   __    ______   __ __ __   _________  ______    ______       ______   ______    ______   ______   ______      
/// /__/\ /__/\ /_____/\ /_//_//_/\ /________/\/_____/\  /_____/\     /_____/\ /_____/\  /_____/\ /_____/\ /_____/\     
/// \::\_\\  \ \\::::_\/_\:\\:\\:\ \\__.::.__\/\:::_ \ \ \:::_ \ \    \:::_ \ \\:::_ \ \ \:::_ \ \\:::_ \ \\::::_\/_    
///  \:. `-\  \ \\:\/___/\\:\\:\\:\ \  \::\ \   \:(_) ) )_\:\ \ \ \    \:\ \ \ \\:(_) ) )_\:\ \ \ \\:(_) \ \\:\/___/\   
///   \:. _    \ \\::___\/_\:\\:\\:\ \  \::\ \   \: __ `\ \\:\ \ \ \    \:\ \ \ \\: __ `\ \\:\ \ \ \\: ___\/ \_::._\:\  
///    \. \`-\  \ \\:\____/\\:\\:\\:\ \  \::\ \   \ \ `\ \ \\:\_\ \ \    \:\/.:| |\ \ `\ \ \\:\_\ \ \\ \ \     /____\:\ 
///     \__\/ \__\/ \_____\/ \_______\/   \__\/    \_\/ \_\/ \_____\/     \____/_/ \_\/ \_\/ \_____\/ \_\/     \_____\/ 
///                                                                                                                     

contract NewtroDrops is ERC1155, Ownable, AccessControl {
    using Counters for Counters.Counter;

    string public name;
    string public symbol;

    Counters.Counter private _tokenIds;

    mapping(uint256 => string) private _uris;

    string private _contractURI;

    bytes32 public MINTER_ROLE = keccak256("MINTER_ROLE");

    constructor(string memory contractURI_) ERC1155("") {
        name = "Newtro Drops";
        symbol = "NEWTRO";

        _contractURI = contractURI_;

        _grantRole(MINTER_ROLE, msg.sender);
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    function airdrop(address[] memory recipients, string memory tokenURI)
        public
        onlyRole(MINTER_ROLE)
    {
        uint256 recipientsAmount = recipients.length;
        require(recipientsAmount > 0, "No recipients to airdrop");

        _tokenIds.increment();
        uint256 tokenId = _tokenIds.current();

        for (uint256 i = 0; i < recipientsAmount; ++i) {
            address recipient = recipients[i];

            require(
                balanceOf(recipient, tokenId) == 0,
                "Cannot be airdropped twice"
            );

            _mint(recipient, tokenId, 1, "");
        }

        _uris[tokenId] = tokenURI;
    }

    function uri(uint256 tokenId) public view override returns (string memory) {
        return _uris[tokenId];
    }

    function contractURI() external view returns (string memory) {
        return _contractURI;
    }

    function transferOwnership(address newOwner) public override onlyOwner {
        Ownable.transferOwnership(newOwner);

        _revokeRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(DEFAULT_ADMIN_ROLE, newOwner);
    }

    function renounceOwnership() public view override onlyOwner {
        revert("Transfer ownership instead");
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
