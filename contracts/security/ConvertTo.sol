//SPDX-License-Identifier: MIT

pragma solidity ^0.8.6;

/**
 * @dev Contract that implements conversion use cases.
 */
contract ConvertTo {
    function StringToInt(string memory _str) public pure returns(uint256) {
        uint val = 0;
        bytes memory stringBytes = bytes(_str);
        
        for (uint i = 0; i < stringBytes.length; i++) {
          uint exp = stringBytes.length - i;
          bytes1 ival = stringBytes[i];
          uint8 uval = uint8(ival);
          uint jval = uval - uint(0x30);
   
          val +=  (uint(jval) * (10**(exp-1))); 
        }
      return val;
    }
}