// //SPDX-License-Identifier: MIT

// pragma solidity ^0.8.6;

// import "../security/Context.sol";
// import "../security/AccessControl.sol";
// import "./BEP20.sol";

// abstract contract BEP20Mintable is BEP20, AccessControl {
//     /**
//      * @dev Creates `amount` tokens and assigns them to `msg.sender`, increasing
//      * the total supply.
//      *
//      * Requirements
//      *
//      * - `msg.sender` must be the token owner
//      */
//     function mint(uint256 amount) public virtual onlyMinter returns (bool) {
//         _mint(_msgSender(), amount);
//         return true;
//     }

//     /** @dev Creates `amount` tokens and assigns them to `account`, increasing
//      * the total supply.
//      *
//      * Emits a {Transfer} event with `from` set to the zero address.
//      *
//      * Requirements:
//      *
//      * - `account` cannot be the zero address.
//      */
//     function _mint(address account, uint256 amount) internal virtual {
//         require(account != address(0), "BEP20: Mint to the zero address");

//         _beforeTokenTransfer(address(0), account, amount);

//         _totalSupply += amount;
//         _balances[account] += amount;
//         emit Minted(_msgSender(), account, amount);
//         emit Transfer(address(0), account, amount);

//         _afterTokenTransfer(address(0), account, amount);
//     }

// }