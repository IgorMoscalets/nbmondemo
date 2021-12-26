//SPDX-License-Identifier: MIT

pragma solidity ^0.8.6;

import "../marketplace/Marketplace.sol";
import "../BEP721/BEP721Receiver.sol";

contract NBMarketplace is Marketplace, BEP721Receiver {
    constructor() Marketplace(address(0xb5E567d854Fb0Cc4172143A3d2b983E94c6ccFe2), 500) {
    }
}