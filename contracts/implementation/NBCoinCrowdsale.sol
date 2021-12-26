//SPDX-License-Identifier: MIT

pragma solidity ^0.8.6;

import "../crowdsale/Crowdsale.sol";

contract NBCoinCrowdsale is Crowdsale {
    constructor() Crowdsale(
        //rate, which is 4000 NBCoins/BNB
        4000, 
        //wallet to receive BNB after NBCoin purchase
        payable(0x213D2806B07fB2BFCd51fCbC7503755784C72F09),
        //NBCoin address 
        IBEP20(0x80801BDC978efE99E01CBa129579aB178BfE191b),
        //Minimum purchase, 0.1 BNB
        0.1 * 10 ** 18,
        //Maximum purchase, 2 BNB
        2 * 10 ** 18
        ) {
        }
}

