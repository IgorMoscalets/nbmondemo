//SPDX-License-Identifier: MIT

pragma solidity ^0.8.6;

import "../BEP20/BEP20.sol";
import "../security/AccessControl.sol";

/**
 * @dev Total supply starts at 280,000,000 (280 million)
 *      Supply will have a maximum cap of 400,000,000 (400 million)
 *      through staking + in-game rewards
 *
 */
contract RealmCoin is BEP20("Realm Coin", "REC") {
    uint256 private totalTokens = 280000000 * 10 ** 18;
    uint256 private cap = 400000000 * 10 ** 18;
    function mint(address _to, uint256 _amount) public onlyMinter whenNotPaused returns (bool) {
        require(totalSupply() + _amount <= cap, "BEP20: Cap reached. Cannot mint");
        _mint(_to, _amount);
        
        
        return true;
    }
    function burn(address _from, uint256 _amount) public onlyBurner whenNotPaused returns (bool) {
        _burn(_from, _amount);
        return true;
    }

    /**
     * @dev Constructor will mint initial 280,000,000 tokens to contract address
     */
    constructor() {
        mint(_msgSender(), totalTokens);
    }
}
