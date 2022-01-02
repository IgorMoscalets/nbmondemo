//SPDX-License-Identifier: MIT

pragma solidity ^0.8.6;

import "../chainlink/VRF.sol";
import "../security/Strings.sol";
import "./NBMonCore.sol";
import "../security/ConvertTo.sol";

/**
 * @dev This contract is the extended counterpart to NBMonBreeding.sol. In this case most of the logic is done in this contract. Randomizing functions
 * are done through using Chainlink's VRF. Some logic that requires to be dynamic will still be done from the server and passed on as an argument.
 * NOTE: This contract does NOT have any of the advanced features yet (e.g. using artifacts to boost certain stats when breeding). It also only considers
 * ONE type (e.g. Beast, Ancient etc.); it does not consider the NBMon to have 2 or more types.
 */
contract NBMonBreedingExtended is VRF, NBMonCore, ConvertTo {
    /**
     * @dev breeds 2 NBMons to give birth to an offspring.
     *
     * Note: The current randomization logic for SHINYID is:
     * It doesn't matter if both parents are shiny or if none of them are or if only 1 of them are. 
     * The chances of receiving a shiny offspring is currently set to 1/4096. If the randomization falls within this number:
     * the offspring will receive a shinyId of 2. If it isn't shiny, its shinyId is 1.
     *
     * Logic: if (randomNumber() % 100 > (1/4096*100)) {
        shinyId = 1
    } else {
        shinyId = 2
    }
     *
     *
     * Note: The current randomization logic for NBMONTYPE, SPECIES and FERTILITY is:
     * 1) If both parent A and B are origins, the offspring is an origin too. Species of offspring is randomized from any of the two parents.
     * 2) If parent A is an origin and parent B is a hybrid (or vice versa), the offspring is a hybrid. Species of offspring is always based on the Origin parent.
     * 3) If parent A is an origin and parent B is a wild (or vice versa), the offspring is a hybrid. Species of offspring is always based on the Origin parent.
     * 4) If parent A is a hybrid and parent B is a wild (or vice versa), then offspring is a hybrid. Species of offspring is always based on the Hybrid parent.
     * If both parents have the same fertility (e.g. 6 and 6) their offspring will have a fertility of both parents - 1 (5).
     * If one parent has a higher fertility (e.g. 4 and 2), the offspring will have the lowest fertility of both parents as its fertility (fertility - 1).
     * 
     * Note: The current randomization logic for GENERA is:
     * An NBMon can be categorized as part of a different species but will only be part of one Genus.
     * For example, Lamox is a genus and Licorine is a genus. If a Lamox breeds with a Licorine, its offspring can either be a Lamox or Licorine genus.
     *
     * Note: The current randomization logic for RARITY is:
     * There are 6 rarities: common, uncommon, rare, epic, legendary, mythical.
     * The rarity that the offspring gets is NOT dependent on the parents (even if they're mythical) and will be as follows:
     * 65% common, 20% uncommmon, 10% rare, 4% epic, 0.9% legendary, 0.1% mythical.
     *
     * Note: The current randomization logic for IV is:
     * Rarity will NOT play a part for IV to make it fair for everyone.
     * 1) If the offspring is an origin , the IV for each stat can be up to 30.
     * 2) If the offspring is a hybrid of a wild, the IV for each stat can only be up to 20.
     * There is a 40% chance it will follow the male parent, 40% chance it will follow the mom parent, 20% chance it will be randomized.
     * 
     * Note: The current randomization logic for EV is:
     * For each stat (HP, energy, attack, defense, spA, spD, speed), the NBMon can earn up to 65 EV.
     * 1) If the offspring is an origin, the EV for each stat can be up to 65.
     * 2) If the offspring is either a hybrid or wild, the EV for each stat can only be up to 50.
     * Rarity plays a part into the EVs. 
     * 1) For common, you can earn up to 20 EV for origin and 15 for H + W
     * 2) For uncommon, you can earn up to 25 EV for origin and 20 for H + W
     * 3) For rare, you can earn up to 35 EV for origin and 25 for H + W
     * 4) For epic, you can earn up to 45 EV for origin and 30 for H + W
     * 5) For legendary, you can earn up to 55 EV for origin and 40 for H + W
     * 6) For mythical, you can earn up to 65 EV for origin and 50 for H + W
     * 
     *
     * Note: The current randomization logic for PASSIVEONE and PASSIVETWO is:
     * Each parent can have up to 10 passives of which 2 can be chosen in battle. 
     * The offspring can inherit up to 2 passives from either or both the parents. The logic is as follows:
     * For passiveOne, there's a 50% chance to inherit from parent A and 50% chance to inherit from parent B.  
     * Let's assume that the number rolls below 50. Then passiveOne will be inheriting from parent A.
     * Now, it needs to randomize from one of the passives that parent A has. That will be passiveOne for the offspring.
     * The logic will reset and follow the same route for passiveTwo. Bare in mind that inheriting the same exact passives for both passiveOne and passiveTwo can happen.
     *
     * Note: The current randomization logic for MOVEONE and MOVETWO is:
     * The logic is similar to inheriting passiveOne and passiveTwo, just like mentioned above. 
     * However, instead of having up to 10 for passives, NBMons can have up to 20 moves. 
     *
     */
    function breedNBMon(uint256 _parentOne, uint256 _parentTwo) public onlyMinter {
        
        // getting both species of parentOne and parentTwo
        

        // getting both 
    }


}