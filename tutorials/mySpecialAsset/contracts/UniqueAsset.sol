// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract UniqueAsset is ERC721{
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;
    mapping(string => uint8) hashes;
    string constant NOT_VALID_NFT = "003002";
    mapping (uint256 => address) internal idToOwner;
    mapping (uint256 => string) internal idToUri;
    //constructor(
    //    string memory _name,
    //    string memory _symbol
    //)
    //{
    //    nftName = _name;
    //    nftSymbol = _symbol;
    //} 
    constructor() public ERC721("UniqueAsset", "UNA") {}
    modifier validNFToken(
    uint256 _tokenId
    )
    {
        require(idToOwner[_tokenId] != address(0), NOT_VALID_NFT);
        _;
    }

    function _setTokenURI(uint256 _tokenId,string memory _uri)
    internal
    validNFToken(_tokenId)
  {
    idToUri[_tokenId] = _uri;
  }
    function awardItem(address recipient, string memory hash, string memory metadata)
    public
    returns (uint256){
        require(hashes[hash] != 1);
        hashes[hash] = 1;
        _tokenIds.increment();
        uint256 newItemId = _tokenIds.current();
        _mint(recipient, newItemId);
        _setTokenURI(newItemId, metadata);
        return newItemId;
    }
}