// SPDX-License-Identifier: MIT
pragma solidity ^0.7;
import "./Clone.sol";

contract Factory {
    address template;

    event Created(address newOne);

    constructor (address template_) {
        template = template_;
    }

    function create() external returns(address) {
        address newOne = Clone.createClone(template);
        emit Created(newOne);
        return newOne;
    }

    function check(address query) view external returns(bool) {
        return Clone.isClone(template, query);
    }
}