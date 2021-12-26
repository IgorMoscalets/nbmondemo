//SPDX-License-Identifier: MIT

pragma solidity ^0.8.6;

import "./Pausable.sol";

abstract contract Upgradeable is Pausable {
    address public newContractAddress;

    event ContractUpgraded(address newAddress);

    function setNewAddress(address newAddress) external onlyAdmin whenPaused {
        newContractAddress = newAddress;
        emit ContractUpgraded(newAddress);
    }
}