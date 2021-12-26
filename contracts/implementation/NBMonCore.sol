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

    struct NBMon {
        // tokenId for NBMon
        uint256 nbmonId;
        //species for NBMon (currently only contains 7, there will be more in the future)
        uint8 species;
        // shinyId for NBMon (1 is not shiny, 2-5 if isShiny == true)
        uint8 shinyId;
        // current owner for NBMon
        address owner;
        // timestamp of when NBMon is/was born
        uint256 bornAt;
        // duration of when NBMon can be evolved
        uint32 evolveDuration;
        // types: 1 - origin, 2 - wild, 3 - hybrid
        uint8 checkType;
        /// @dev contains all of the stats of the NBMon
        /// including health pool, energy, attack, special attack, defense, special defense, speed, passive one, passive two, moveset one, moveset two
        /// Note: Each stat takes up 2 integers in the string (e.g. combinationStats = 50403040... means that 50 is health pool, 40 is energy, 30 is attack, 40 is defense etc) 
        string combinationStats;
        // checks the amount of times it has bred 
        uint8 breedCount;
    }

    NBMon[] private nbmons;

    // mapping from owner address to amount of NBMons owned
    mapping(address => uint256) private ownerNBMonCount;
    // mapping from owner address to array of IDs of the NBMons the owner owns
    mapping(address => uint256[]) private ownerNBMonIds;
    // mapping from owner address to list of NBMons owned;
    mapping(address => NBMon[]) private ownerNBMons;

    /// used primarily for minting NBMons to keep track of current nbmonId
    uint256 public currentNBMonCount = 0;

    event NBMonMinted(uint256 indexed _nbmonId, address indexed _owner);
    event NBMonBurned(uint256 indexed _nbmonId);

    // returns a single NBMon given an ID
    function getNBMon(uint256 _nbmonId) public view returns (
        uint256 nbmonId_,
        uint8 _species,
        uint8 _shinyId, 
        address _owner, 
        uint256 _bornAt, 
        uint32 _evolveDuration, 
        uint8 checkType,
        string memory combinationStats,
        uint8 _breedCount
        ) {
        require(_exists(_nbmonId), "NBMonCore: NBMon with the specified ID does not exist");
        NBMon storage _nbmon = nbmons[_nbmonId];
        return(
            _nbmon.nbmonId,
            _nbmon.species,
            _nbmon.shinyId,
            _nbmon.owner,
            _nbmon.bornAt,
            _nbmon.evolveDuration,
            _nbmon.checkType,
            _nbmon.combinationStats,
            _nbmon.breedCount
            );
    }

    // returns all NBMons owned by the owner
    function getAllNBMonsOfOwner(address _owner) public view returns (NBMon[] memory) {
        return ownerNBMons[_owner];
    }

    function getOwnerNBMonCount(address _owner) public view returns (uint256) {
        return ownerNBMonCount[_owner];
    }

    function getOwnerNBMonIds(address _owner) public view returns (uint256[] memory) {
        return ownerNBMonIds[_owner];
    }

    function mintNBMon(address _owner) public onlyMinter {
        return _mintNBMon(_owner);
    }

    /// Note: current minting is done by hardcoding the fields. this will NOT be the final form and will only
    /// be used for testing purposes currently. we're working on finishing the breeding and the rest
    /// of the minting contract.
    function _mintNBMon(address _owner) private {
        NBMon memory _nbmon = NBMon(
            currentNBMonCount,
            1,
            2,
            _owner,
            block.timestamp,
            345600 seconds,
            1,
            "5040304040504002020401",
            0
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
     * Otherwise not needed since getNBMon and getAllNBMonsOfOwner contains complete information at once
     */
     function getSpecies(uint256 _nbmonId) public view returns (uint8) {
         return nbmons[_nbmonId - 1].species;
     }
     function getShinyId(uint256 _nbmonId) public view returns (uint8) {
         return nbmons[_nbmonId - 1].shinyId;
     }
     function getBornAt(uint256 _nbmonId) public view returns (uint256) {
         return nbmons[_nbmonId - 1].bornAt;
     }
     function getEvolveDuration(uint256 _nbmonId) public view returns (uint32) {
         return nbmons[_nbmonId - 1].evolveDuration;
     }
     function getCheckType(uint256 _nbmonId) public view returns (uint8) {
         return nbmons[_nbmonId - 1].checkType;
     }
     function getcombinationStats(uint256 _nbmonId) public view returns (string memory) {
         return nbmons[_nbmonId - 1].combinationStats;
     }
     function getBreedCount(uint256 _nbmonId) public view returns (uint8) {
         return nbmons[_nbmonId - 1].breedCount;
     }
}