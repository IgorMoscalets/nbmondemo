//SPDX-License-Identifier: MIT

pragma solidity ^0.8.6;

import "../BEP721/NFTCore.sol";

/**
 @dev Base contract for NBMon which contains all functionality and methods related with our Realm Hunter game
 */
contract NBMonCore is NFTCore {
    constructor() BEP721("NBMon", "NBMON") {
        setBaseURI("https://nbcompany.io/nbmon/");
    }

    /**
     * @dev Instance of an NBMon with detailed stats instantiated as a struct
     * Note: A lot of the fields are assigned a uint type so that changes are easier to be amended in the future.
     */
    struct NBMon {
        // tokenId for NBMon
        uint256 nbmonId;
        // current owner for NBMon
        address owner;
        uint256 bornAt;
        // timestamp of when NBMon was transferred to current owner (when selling in marketplace, transferring from wallet etc)
        uint256 transferredAt;
        //contains gender, rarity, isShiny, nbmonType, evolveDuration, genera and fertility
        // check './gamestats/genders.txt' for more info.
        // check './gamestats/rarityChance.txt' for more info.
        // check './gamestats/shinyChance.txt' for more info.
        //check './gamestats/evolveDuration.txt' for more info.
        // check './gamestats/nbmonTypes.txt' for more info.
        // check './gamestats/genera.txt' for more info.
        // check './gamestats/fertility.txt' for more info
        uint32[] nbmonStats;

        // Each NBMon can have up to two elements. There is also a chance to get "null" for any of the two element slots.
        // more on elements at './gamestats/elements.txt'
        uint8[] elements;

        /// @dev contains all of the potential of the NBMon
        /// including health pool, energy, attack, special attack, defense, special defense, speed
        /// Note: does NOT take into consideration of rarity in the blockchain side. Actual EV stats will be reflected in-game.
        /// check './gamestats/potential.txt' for more info.
        uint8[] potential;

        // only used for breeding to inherit 2 passives from the passive set of the parent NBMons
        // if minted, it will be an empty array
        // check './gamestats/passives.txt' for more info
        uint8[] inheritedPassives;

        // only used for breeding to inherit 2 moves from the move set of the parent NBMons
        // if minted, it will be an empty array
        // check './gamestats/moveset.txt' for more info
        uint8[] inheritedMoves;  
    }

    NBMon[] internal nbmons;

    // mapping from owner address to amount of NBMons owned
    mapping(address => uint256) internal ownerNBMonCount;
    // mapping from owner address to array of IDs of the NBMons the owner owns
    mapping(address => uint256[]) internal ownerNBMonIds;
    // mapping from owner address to list of NBMons owned;
    mapping(address => NBMon[]) internal ownerNBMons;

    // checks the current NBMon supply for enumeration. Starts at 1 when contract is deployed.
    uint256 public currentNBMonCount = 1;

    event NBMonMinted(uint256 indexed _nbmonId, address indexed _owner);
    event NBMonBurned(uint256 indexed _nbmonId);

    // returns a single NBMon given an ID
    function getNBMon(uint256 _nbmonId) public view returns (NBMon memory) {
        require(_exists(_nbmonId), "NBMonCore: NBMon with the specified ID does not exist");
        return nbmons[_nbmonId - 1];
    }

    // returns all NBMons owned by the owner
    function getAllNBMonsOfOwner(address _owner) public view returns (NBMon[] memory) {
        return ownerNBMons[_owner];
    }

    //returns the amount of NBMons the owner has
    function getOwnerNBMonCount(address _owner) public view returns (uint256) {
        return ownerNBMonCount[_owner];
    }

    // returns the NBMon IDs of the owner's NBMons
    function getOwnerNBMonIds(address _owner) public view returns (uint256[] memory) {
        return ownerNBMonIds[_owner];
    }

    /**
     * @dev These numbers are the base modulo for the values of each NBMon stat. If changed, the minted NBMon can have a different stat.
     * Note: Bare in mind that the descriptions for each variable are based off during contract deployment. These variables may change. 
     * Check in BSCSCAN or by taking an instance of this contract for the actual values of each variable.
     */
    uint8 public _genders = 2;
    // check ./gamestats/rarityChance.txt for further information
    uint16 public _rarityChance = 1000;
    // check ./gamestats/nbmonTypes.txt for further information
    uint8 public _nbmonTypes = 3;
    //check ./gamestats/genera.txt for further information
    uint16 public _genera = 11;
    // chance to obtain shiny NBMon is 1/4096.
    uint16 public _shinyChance = 4096;
    //if result is 1, it's considered null, and therefore no element is assigned. 2-13 are elements identified in elements.txt.
    uint8 public _elementTypes = 13;
    uint8 public _maxPotential = 65;
    // an NBMon can have 0-8 fertility. however, depending on the rarity, the end fertility result will be different and that's why a base fertility chance is used.
    // check ./gamestats/fertility.txt' for further information
    uint16 public _baseFertilityChance = 900;

    function changeGenders(uint8 genders_) public onlyAdmin {
        _genders = genders_;
    }
    function changeRarityChance(uint16 rarityChance_) public onlyAdmin {
        _rarityChance = rarityChance_;
    }
    function changeNbmonTypes(uint8 nbmonTypes_) public onlyAdmin {
        _nbmonTypes = nbmonTypes_;
    }
    function changeGenera(uint16 genera_) public onlyAdmin {
        _genera = genera_;
    }
    function changeShinyChance(uint8 shinyChance_) public onlyAdmin {
        _shinyChance = shinyChance_;
    }
    function changeElementTypes(uint8 elementTypes_) public onlyAdmin {
        _elementTypes = elementTypes_;
    }
    function changeMaxPotential(uint8 maxPotential_) public onlyAdmin {
        _maxPotential = maxPotential_;
    }
    function changeBaseFertilityChance(uint16 baseFertilityChance_) public onlyAdmin {
        _baseFertilityChance = baseFertilityChance_;
    }
    /**
     * END OF BASE STATS CHANGE
     */

     function _randomizePotential(uint256 _randomNumber) private view returns (uint8[] memory _potential) {
         _potential = new uint8[](7);

         for (uint8 i = 0; i < 7; i++) {
             _potential[i] = uint8(uint256(keccak256(abi.encode(_randomNumber, i))) % _maxPotential + 1);
         }

         return _potential;
     }

     function _randomizeElements(uint256 _randomNumber) private view returns (uint8[] memory _elements) {
         _elements = new uint8[](2);

         for (uint8 i = 0; i < 2; i++) {
             _elements[i] = uint8(uint256(keccak256(abi.encode(_randomNumber, i))) % _elementTypes + 1);
         }
         // first element must NOT be null. If it is null, it is converted to a natural species instead.
         // second element MAY be a null element.
         if (_elements[0] == 1) {
             _elements[0] = 2;
         }

         return _elements;
     }

     function _randomizeNbmonStatsOrigin(uint256 _randomNumber, uint32 _baseEvolveDuration) private view returns (uint32[] memory _nbmonStats) {
         _nbmonStats = new uint32[](7);
         
         //randomizing gender
         _nbmonStats[0] = uint32(uint256(keccak256(abi.encode(_randomNumber, 0))) % _genders + 1);
         //randomizing rarity
         _nbmonStats[1] = uint32(uint256(keccak256(abi.encode(_randomNumber, 1))) % _rarityChance + 1);
         //randomizing isShiny
         _nbmonStats[2] = uint32(uint256(keccak256(abi.encode(_randomNumber, 2))) % _shinyChance + 1);
         //randomizing nbmonType (only origin, so result is always 1)
         _nbmonStats[3] = uint32(uint256(keccak256(abi.encode(_randomNumber, 3))) % 1 + 1);
         //evolveDuration
         _nbmonStats[4] = _baseEvolveDuration;
         //randomizing genera
         _nbmonStats[5] = uint32(uint256(keccak256(abi.encode(_randomNumber, 4))) % _genera + 1);
         //randomizing fertility
         _nbmonStats[6] = uint32(uint256(keccak256(abi.encode(_randomNumber, 5))) % _baseFertilityChance + 1);
     }
     
     function mintOrigin(uint256 _randomNumber, address _owner, uint32 _evolveDurationTime) public {
         _mintOrigin(_randomNumber, _owner, _evolveDurationTime);
     }

    /// Note: _randomNumber will be randomized from the server side and passed on as an argument.
    function _mintOrigin(uint256 _randomNumber, address _owner, uint32 _baseEvolveDuration) private {
        uint32[] memory _nbmonStats = _randomizeNbmonStatsOrigin(_randomNumber, _baseEvolveDuration);
        uint8[] memory _elements = _randomizeElements(_randomNumber);
        uint8[] memory _potential = _randomizePotential(_randomNumber);
        uint8[] memory _inheritedPassives;
        uint8[] memory _inheritedMoves;

        NBMon memory _nbmon = NBMon(
            currentNBMonCount,
            _owner,
            block.timestamp,
            block.timestamp,
            _nbmonStats,
            _elements,
            _potential,
            _inheritedPassives,
            _inheritedMoves
        );
        nbmons.push(_nbmon);
        ownerNBMons[_owner].push(_nbmon);
        _safeMint(_owner, currentNBMonCount);
        ownerNBMonIds[_owner].push(currentNBMonCount);
        currentNBMonCount++;
        ownerNBMonCount[_owner]++;
        emit NBMonMinted(currentNBMonCount, _owner);
    }

    /**
     * @dev Singular purpose functions designed to make reading code easier for front-end
     * Otherwise not needed since getNBMon and getAllNBMonsOfOwner and getNBMon contains complete information at once
     */
    function getNbmonStats(uint256 _nbmonId) public view returns (uint32[] memory) {
        return nbmons[_nbmonId - 1].nbmonStats;
    }
    function getBornAt(uint256 _nbmonId) public view returns (uint256) {
        return nbmons[_nbmonId - 1].bornAt;
    }
    function getTransferredAt(uint256 _nbmonId) public view returns (uint256) {
        return nbmons[_nbmonId - 1].transferredAt;
    }
    function getElements(uint256 _nbmonId) public view returns (uint8[] memory) {
        return nbmons[_nbmonId - 1].elements;
    }
    function getPotential(uint256 _nbmonId) public view returns (uint8[] memory) {
        return nbmons[_nbmonId - 1].potential;
    }
    function getInheritedPassives(uint256 _nbmonId) public view returns (uint8[] memory) {
        return nbmons[_nbmonId - 1].inheritedPassives;
    }
    function getInheritedMoves(uint256 _nbmonId) public view returns (uint8[] memory) {
        return nbmons[_nbmonId - 1].inheritedMoves;
    }
}