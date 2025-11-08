// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// URL imports so Actions can compile without local deps
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v5.0.2/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v5.0.2/contracts/access/Ownable.sol";

contract ShopPass is ERC721Enumerable, Ownable {
    enum Tier { Common, Uncommon, Rare, Epic, Legendary }

    uint256 public constant MAX_SUPPLY = 10000;
    uint256 public nextId;
    bool public saleActive = true;

    mapping(uint256 => Tier) public tierOf;
    mapping(address => bool) public minted;

    constructor()
        ERC721("Sahabel Classic Fashion NFT", "SCFNFT")
        Ownable(msg.sender)
    {}

    function mintPublic() external {
        require(saleActive, "Minting is not active");
        require(!minted[msg.sender], "Already minted");
        require(nextId < MAX_SUPPLY, "Sold out");

        uint256 tokenId = nextId++;
        minted[msg.sender] = true;
        _safeMint(msg.sender, tokenId);

        uint256 r = uint256(
            keccak256(abi.encodePacked(blockhash(block.number - 1), msg.sender, tokenId))
        ) % 10000;

        if (r < 2000) tierOf[tokenId] = Tier.Common;
        else if (r < 4000) tierOf[tokenId] = Tier.Uncommon;
        else if (r < 6000) tierOf[tokenId] = Tier.Rare;
        else if (r < 8000) tierOf[tokenId] = Tier.Epic;
        else tierOf[tokenId] = Tier.Legendary;
    }

    function walletHighestTier(address user) external view returns (bool has, Tier highest) {
        uint256 n = balanceOf(user);
        if (n == 0) return (false, Tier.Common);
        Tier maxTier = Tier.Common;
        for (uint256 i = 0; i < n; i++) {
            uint256 id = tokenOfOwnerByIndex(user, i);
            Tier t = tierOf[id];
            if (uint(t) > uint(maxTier)) maxTier = t;
        }
        return (true, maxTier);
    }

    function setSaleActive(bool active) external onlyOwner { saleActive = active; }
}
