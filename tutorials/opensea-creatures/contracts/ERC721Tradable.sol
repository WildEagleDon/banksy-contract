// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./Strings1.sol";

contract OwnableDelegateProxy{}

contract ProxyRegistry{
    mapping(address => OwnableDelegateProxy) public proxies;
}

/**
 * @title ERC721Tradable
 * ERC721Tradable - ERC721 contract that whitelists a trading address, and has minting functionality.
 */
contract ERC721Tradable is ERC721, Ownable {
    using Strings for string;

    address proxyRegistryAddress;
    uint256 private _currentTokenId = 0;

    constructor(
        string memory _name,
        string memory _symbol,
        address _proxyRegistryAddress
    ) public ERC721(_name, _symbol) {
        proxyRegistryAddress = _proxyRegistryAddress;
    }

    /**
     * @dev Mints a token to an address with a tokenURI
     * @param _to address of the future owner of the token
     */
    function mintTo(address _to) public onlyOwner {
        uint256 newTokenId = _getNextTokenId();
        _mint(_to, newTokenId);
        //_incrementTokenId();
    }

    /**
     * @dev calculates the next token ID based on value of _currentTokenId
     * @return uint256 for the next token ID
     */
    function _getNextTokenId() private view returns (uint256) {
        return _currentTokenId++;
    //    return _currentTokenId.add(1);
    }

    /**
     * @dev increments the value of _currentTokenId
     */
    //function _incrementTokenId() private {
    //    _currentTokenId++;
    //}

    function baseTokenURI() public pure virtual returns (string memory) {
        return "";
    }

    //function tokenURI(uint256 _tokenId) external view returns (string memory) {
    //    return Strings.strConcat(baseTokenURI(), Strings.uint2str(_tokenId));
    //}

    /**
     * Override isApproveForAll to whitelist user's OpenSea proxy accounts to enable gas-less listings.
     */
    function isApproveForAll(address owner, address operator)
        public
        view
        returns (bool)
    {
        // Whitelist Opensea proxy contract for easy trading.
        ProxyRegistry proxyRegistry = ProxyRegistry(proxyRegistryAddress);
        if (address(proxyRegistry.proxies(owner)) == operator) {
            return true;
        }

        return super.isApproveForAll(owner, operator);
    }
}