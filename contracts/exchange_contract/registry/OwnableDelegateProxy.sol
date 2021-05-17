// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

import "./proxy/OwnedUpgradeabilityProxy.sol";

contract OwnableDelegateProxy is OwnedUpgradeabilityProxy {

    constructor(address owner, address initialImplementation, bytes memory data)
        public
    {
        setUpgradeabilityOwner(owner);
        _upgradeTo(initialImplementation);
        (bool success,) = initialImplementation.delegatecall(data)
        require(success, "OwnableDelegateProxy failed implementation");
    }

}