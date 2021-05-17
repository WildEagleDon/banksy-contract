//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

contract Color is Ownable, ERC721Enumerable, ERC721URIStorage {
    using SafeMath for uint;

    constructor () ERC721("Color", "COLOR") {
    }

    function mint(address _to, string memory _tokenURI) public onlyOwner returns (bool) {
        _mintWithTokenURI(_to, _tokenURI);
        return true;
    }

    function _mintWithTokenURI(address _to, string memory _tokenURI) internal {
        uint _tokenId = totalSupply().add(1);
        _mint(_to, _tokenId);
        _setTokenURI(_tokenId, _tokenURI);
    }

} 