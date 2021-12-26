//SPDX-License-Identifier: MIT

// pragma solidity ^0.8.6;

// import "./BEP20.sol";

// abstract contract BEP20Governance is BEP20 {
//     /**
//      * @notice A voting power record binds voting power of a delegate to a particular
//      *      block when the voting power delegation change happened
//      */
//     struct VotingPowerRecord {
//         /**
//          * @dev block.number when delegation has changed; starting from
//          *      that block voting power value is in effect
//          */  
//         uint64 blockNumber;

//         /**
//          * @dev Cumulative voting power a delegate has obtained starting
//          *      from the block stored in blockNumber
//          */
//         uint192 votingPower;
//     }

//     /**
//      * @notice A record of each account's voting delegate
//      *
//      * @dev Auxiliary data structure used to sum up an account's voting power
//      *
//      * @dev This mapping keeps record of all voting power delegations:
//      *      voting delegator (token owner) => voting delegate
//      */

//     mapping (address => address) public votingDelegates;
    
//     /**
//      * @notice A record of each account's voting power
//      *
//      * @dev Primarily data structure to store voting power for each account.
//      *      Voting power sums up from the account's token balance and delegated
//      *      balances.
//      *
//      * @dev Stores current value and entire history of its changes.
//      *      The changes are stored as an array of checkpoints.
//      *      VotingPowerRecord is an auxiliary data structure containing voting
//      *      power (number of votes) and block number when the checkpoint is saved
//      *
//      * @dev Maps voting delegate => voting power record
//      */
//     mapping (address => VotingPowerRecord[]) public votingPowerHistory;

//     /**
//      * @dev A record of nonces for signing/validating signatures in `delegateWithSig`
//      *      for every delegate, increases after successful validation
//      * 
//      * @dev Maps delegate address => delegate nonce
//      */
//     mapping (address => uint256) public nonces;

//     /**
//      * @notice EIP-712 contract's domain typeHash, see https://eips.ethereum.org/EIPS/eip-712#rationale-for-typehash
//      */
//     bytes32 public constant DOMAIN_TYPEHASH = keccak256("EIP712Domain(string name,uint256 chainId,address verifyingContract)");

//     /**
//      * @notice EIP-712 delegation struct typeHash, see https://eips.ethereum.org/EIPS/eip-712#rationale-for-typehash
//      */
//     bytes32 public constant DELEGATION_TYPEHASH = keccak256("Delegation(address delegate,uint256 nonce,uint256 expiry)");

//     /**
//      * @dev Notifies that a key-value pair in `votingDelegates` mapping has changed,
//      *      i.e. a delegator address has changed its delegate address
//      *
//      * @param _of delegator address, a token owner
//      * @param _from old delegate, an address whose delegate rights are revoked
//      * @param _to new delegate, an address which received the voting power
//      */
//     event DelegateChanged(address indexed _of, address indexed _from, address indexed _to);

//      /**
//      * @dev Notifies that a key-value pair in `votingPowerHistory` mapping has changed,
//      *      i.e. a delegate's voting power has changed.
//      *
//      * @param _of delegate whose voting power has changed
//      * @param _fromVal previous number of votes delegate had
//      * @param _toVal new number of votes delegate has
//      */
//     event VotingPowerChanged(address indexed _of, uint256 _fromVal, uint256 _toVal);

//     /**
//      * @notice Gets current voting power of the account `_of`
//      * @param _of the address of account to get voting power of
//      * @return current cumulative voting power of the account,
//      *      sum of token balances of all its voting delegators
//      */
//     function getVotingPower(address _of) public view returns (uint256) {
//         // get a link to an array of voting power history records for an address specified
//         VotingPowerRecord[] storage history = votingPowerHistory[_of];

//         // lookup the history and return latest element
//         return history.length == 0 ? 0: history[history.length - 1].votingPower;
//     }

//      /**
//      * @notice Gets past voting power of the account `_of` at some block `_blockNum`
//      * @dev Throws if `_blockNum` is not in the past (not the finalized block)
//      * @param _of the address of account to get voting power of
//      * @param _blockNum block number to get the voting power at
//      * @return past cumulative voting power of the account,
//      *      sum of token balances of all its voting delegators at block number `_blockNum`
//      */
//     function getVotingPowerAt(address _of, uint256 _blockNum) public view returns (uint256) {
//         // make sure block number is not in the past (not the finalized block)
//         require(_blockNum < block.number, "not yet determined"); // Compound msg

//         // get a link to an array of voting power history records for an address specified
//         VotingPowerRecord[] storage history = votingPowerHistory[_of];

//         // if voting power history for the account provided is empty
//         if(history.length == 0) {
//             // than voting power is zero - return the result
//             return 0;
//         }
//         // check latest voting power history record block number:
//         // if history was not updated after the block of interest
//         if(history[history.length - 1].blockNumber <= _blockNum) {
//             // we're done - return last voting power record
//             return getVotingPower(_of);
//         }

//         // check first voting power history record block number:
//         // if history was never updated before the block of interest
//         if(history[0].blockNumber > _blockNum) {
//             // we're done - voting power at the block num of interest was zero
//             return 0;
//         }

//         // `votingPowerHistory[_of]` is an array ordered by `blockNumber`, ascending;
//         // apply binary search on `votingPowerHistory[_of]` to find such an entry number `i`, that
//         // `votingPowerHistory[_of][i].blockNumber <= _blockNum`, but in the same time
//         // `votingPowerHistory[_of][i + 1].blockNumber > _blockNum`
//         // return the result - voting power found at index `i`
//         return history[_binaryLookup(_of, _blockNum)].votingPower;
//     }

//     /**
//      * @dev Reads an entire voting power history array for the delegate specified
//      *
//      * @param _of delegate to query voting power history for
//      * @return voting power history array for the delegate of interest
//      */
//     function getVotingPowerHistory(address _of) public view returns(VotingPowerRecord[] memory) {
//         // return an entire array as memory
//         return votingPowerHistory[_of];
//     }

//     /**
//      * @dev Returns length of the voting power history array for the delegate specified;
//      *      useful since reading an entire array just to get its length is expensive (gas cost)
//      *     
//      * @param _of delegate to query voting power history length for
//      * @return voting power history array length for the delegate of interest
//      */
//      function getVotingPowerHistoryLength(address _of) public view returns(uint256) {
//         // read array length and return
//         return votingPowerHistory[_of].length;
//     }

//     /**
//      * @notice Delegates voting power of the delegator `msg.sender` to the delegate `_to`
//      *
//      * @dev Accepts zero value address to delegate voting power to, effectively
//      *      removing the delegate in that case
//      *
//      * @param _to address to delegate voting power to
//      */
//     function delegate(address _to) public {
//         // delegate call to `_delegate`
//         _delegate(msg.sender, _to);
//     }

//     /**
//      * @notice Delegates voting power of the delegator (represented by its signature) to the delegate `_to`
//      *
//      * @dev Accepts zero value address to delegate voting power to, effectively
//      *      removing the delegate in that case
//      *
//      * @dev Compliant with EIP-712: Ethereum typed structured data hashing and signing,
//      *      see https://eips.ethereum.org/EIPS/eip-712
//      *
//      * @param _to address to delegate voting power to
//      * @param _nonce nonce used to construct the signature, and used to validate it;
//      *      nonce is increased by one after successful signature validation and vote delegation
//      * @param _exp signature expiration time
//      * @param v the recovery byte of the signature
//      * @param r half of the ECDSA signature pair
//      * @param s half of the ECDSA signature pair
//      */
//     function delegateWithSig(address _to, uint256 _nonce, uint256 _exp, uint8 v, bytes32 r, bytes32 s) public {
//         // build the EIP-712 contract domain separator
//         bytes32 domainSeparator = keccak256(abi.encode(DOMAIN_TYPEHASH, keccak256(bytes(name())), block.chainid, address(this)));

//         // build the EIP-712 hashStruct of the delegation message
//         bytes32 hashStruct = keccak256(abi.encode(DELEGATION_TYPEHASH, _to, _nonce, _exp));

//         // calculate the EIP-712 digest "\x19\x01" ‖ domainSeparator ‖ hashStruct(message)
//         bytes32 digest = keccak256(abi.encodePacked("\x19\x01", domainSeparator, hashStruct));

//         // recover the address who signed the message with v, r, s
//         address signer = ecrecover(digest, v, r, s);

//         // perform message integrity and security validations
//         require(signer != address(0), "invalid signature"); // Compound msg
//         require(_nonce == nonces[signer], "invalid nonce"); // Compound msg
//         require(block.timestamp < _exp, "signature expired"); // Compound msg

//         // update the nonce for that particular signer to avoid replay attack
//         nonces[signer]++;

//         // delegate call to `_delegate` - execute the logic required
//         _delegate(signer, _to);
//     }

//     /**
//      * @dev Auxiliary function to delegate delegator's `_from` voting power to the delegate `_to`
//      * @dev Writes to `votingDelegates` and `votingPowerHistory` mappings
//      *
//      * @param _from delegator who delegates his voting power
//      * @param _to delegate who receives the voting power
//      */
//     function _delegate(address _from, address _to) private {
//         // read current delegate to be replaced by a new one
//         address _fromDelegate = votingDelegates[_from];

//         // read current voting power (it is equal to token balance)
//         uint256 _value = _balances[_from];

//         // reassign voting delegate to `_to`
//         votingDelegates[_from] = _to;

//         // update voting power for `_fromDelegate` and `_to`
//         _moveVotingPower(_fromDelegate, _to, _value);

//         // emit an event
//         emit DelegateChanged(_from, _fromDelegate, _to);
//     }

//     /**
//      * @dev Auxiliary function to move voting power `_value`
//      *      from delegate `_from` to the delegate `_to`
//      *
//      * @dev Doesn't have any effect if `_from == _to`, or if `_value == 0`
//      *
//      * @param _from delegate to move voting power from
//      * @param _to delegate to move voting power to
//      * @param _value voting power to move from `_from` to `_to`
//      */
//     function _moveVotingPower(address _from, address _to, uint256 _value) private {
//         // if there is no move (`_from == _to`) or there is nothing to move (`_value == 0`)
//         if(_from == _to || _value == 0) {
//             // return silently with no action
//             return;
//         }

//         // if source address is not zero - decrease its voting power
//         if(_from != address(0)) {
//             // read current source address voting power
//             uint256 _fromVal = getVotingPower(_from);

//             // calculate decreased voting power
//             // underflow is not possible by design:
//             // voting power is limited by token balance which is checked by the callee
//             uint256 _toVal = _fromVal - _value;

//             // update source voting power from `_fromVal` to `_toVal`
//             _updateVotingPower(_from, _fromVal, _toVal);
//         }

//         // if destination address is not zero - increase its voting power
//         if(_to != address(0)) {
//             // read current destination address voting power
//             uint256 _fromVal = getVotingPower(_to);

//             // calculate increased voting power
//             // overflow is not possible by design:
//             // max token supply limits the cumulative voting power
//             uint256 _toVal = _fromVal + _value;

//             // update destination voting power from `_fromVal` to `_toVal`
//             _updateVotingPower(_to, _fromVal, _toVal);
//         }
//     }

//     /**
//      * @dev Auxiliary function to update voting power of the delegate `_of`
//      *      from value `_fromVal` to value `_toVal`
//      *
//      * @param _of delegate to update its voting power
//      * @param _fromVal old voting power of the delegate
//      * @param _toVal new voting power of the delegate
//      */
//     function _updateVotingPower(address _of, uint256 _fromVal, uint256 _toVal) private {
//         // get a link to an array of voting power history records for an address specified
//         VotingPowerRecord[] storage history = votingPowerHistory[_of];

//         // if there is an existing voting power value stored for current block
//         if(history.length != 0 && history[history.length - 1].blockNumber == block.number) {
//             // update voting power which is already stored in the current block
//             history[history.length - 1].votingPower = uint192(_toVal);
//         }

//         // otherwise - if there is no value stored for current block
//         else {
//             // add new element into array representing the value for current block
//             history.push(VotingPowerRecord(uint64(block.number), uint192(_toVal)));
//         }

//         // emit an event
//         emit VotingPowerChanged(_of, _fromVal, _toVal);
//     }

//     /**
//      * @dev Auxiliary function to lookup an element in a sorted (asc) array of elements
//      *
//      * @dev This function finds the closest element in an array to the value
//      *      of interest (not exceeding that value) and returns its index within an array
//      *
//      * @dev An array to search in is `votingPowerHistory[_to][i].blockNumber`,
//      *      it is sorted in ascending order (blockNumber increases)
//      *
//      * @param _to an address of the delegate to get an array for
//      * @param n value of interest to look for
//      * @return an index of the closest element in an array to the value
//      *      of interest (not exceeding that value)
//      */
//     function _binaryLookup(address _to, uint256 n) private view returns(uint256) {
//         // get a link to an array of voting power history records for an address specified
//         VotingPowerRecord[] storage history = votingPowerHistory[_to];

//         // left bound of the search interval, originally start of the array
//         uint256 i = 0;

//         // right bound of the search interval, originally end of the array
//         uint256 j = history.length - 1;

//         // the iteration process narrows down the bounds by
//         // splitting the interval in a half oce per each iteration
//         while(j > i) {
//             // get an index in the middle of the interval [i, j]
//             uint256 k = j - (j - i) / 2;

//             // read an element to compare it with the value of interest
//             VotingPowerRecord memory cp = history[k];

//             // if we've got a strict equal - we're lucky and done
//             if(cp.blockNumber == n) {
//                 // just return the result - index `k`
//                 return k;
//             }
//             // if the value of interest is bigger - move left bound to the middle
//             else if (cp.blockNumber < n) {
//                 // move left bound `i` to the middle position `k`
//                 i = k;
//             }
//             // otherwise, when the value of interest is smaller - move right bound to the middle
//             else {
//                 // move right bound `j` to the middle position `k - 1`:
//                 // element at position `k` is bigger and cannot be the result
//                 j = k - 1;
//             }
//         }
//         // reaching that point means no exact match found
//         // since we're interested in the element which is not bigger than the
//         // element of interest, we return the lower bound `i`
//         return i;
//     }
// }