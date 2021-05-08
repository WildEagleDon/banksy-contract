// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;
import "@openzeppelin/upgrades-core/contracts/Initializable.sol";
/**
 * @title ERC721 Non-Fungible Token Standard basic implementation
 * @dev see https://eips.ethereum.org/EIPS/eip-721
 */
contract MyContract1 is Initializable{
    uint256 value;
    bool    flag;
    function initialize(uint256 _value, bool _flag) public initializer {
        value = _value;
        flag = _flag;
    }

    function getValue() public view returns(uint256) {
        return value;
    }

    function getFlag() public view returns(bool) {
        return flag;
    }
}
