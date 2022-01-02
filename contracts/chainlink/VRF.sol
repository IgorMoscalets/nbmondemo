//SDPX-License-Identifier: MIT

pragma solidity ^0.8.6;

import "@chainlink/contracts/src/v0.8/VRFConsumerBase.sol";

contract VRF is VRFConsumerBase {
    bytes32 internal keyHash;
    uint256 internal fee;
    
    uint256 public randomResult;

    constructor() VRFConsumerBase(
        //BSC Testnet VRF Coordinator address
        0xa555fC018435bef5A13C6c6870a9d4C11DEC329C,
        //BSC Testnet LINK address
        0x84b9B910527Ad5C03A9Ca831909E21e236EA7b06
    ) {
        //BSC Testnet keyHash
        keyHash = 0xcaf3c3727e033261d383b315559476f48034c13b18f8cafed4d871abe5049186;
        fee = 0.1 * 10 ** 18; //0.1 LINK in BSC Testnet
    }

    function getRandomNumber() public returns (bytes32 requestId) {
        require(LINK.balanceOf(address(this)) >= fee, "VRF: Not enough LINK to execute function");
        return requestRandomness(keyHash, fee);
    }

    function fulfillRandomness(bytes32 requestId, uint256 randomness) internal override {
        randomResult = randomness;
    }

}