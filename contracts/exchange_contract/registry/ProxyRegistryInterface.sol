// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

import "./OwnableDelegateProxy.sol";

interface ProxyRegistrayInterface {
    
    function delegateProxyImplementation() external returns (address);

    function proxies(address owner) external returns (OwnableDelegateProxy);
    
}