  // SPDX-License-Identifier: MIT

pragma solidity ^0.8.6;

/**
 * @dev Interface of the BEP20 standard as defined in the EIP.
 */
interface IBEP20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /**
     * @dev Emitted whenever the mint() function is fired. `from` is the caller of the
     * mint function. `to` refers to the address the tokens are minted to. `value` is the
     * amount of tokens minted.
     */
    event Minted(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted whenever the burn() function is fired. `by` is the caller of the
     * burn function. `from` refers to the address the tokens were burnt from. `value` is the
     * amount of tokens burnt.
     */
    event Burnt (address indexed by, address indexed from, uint256 value);

    /**
     * @dev Resolution for the Multiple Withdrawal Attack on ERC20 Tokens (ISBN:978-1-7281-3027-9)
     *
     * @dev Similar to ERC20 Transfer event, but also logs an address which executed transfer
     *
     * @dev Fired in transfer(), transferFrom() and some other (non-ERC20) functions
     *
     * @param _by an address which performed the transfer
     * @param _from an address tokens were consumed from
     * @param _to an address tokens were sent to
     * @param _value number of tokens transferred
     */
    event Transferred(address indexed _by, address indexed _from, address indexed _to, uint256 _value);

     /**
     * @dev Resolution for the Multiple Withdrawal Attack on ERC20 Tokens (ISBN:978-1-7281-3027-9)
     *
     * @dev Similar to ERC20 Approve event, but also logs old approval value
     *
     * @dev Fired in approve() and approveAtomic() functions
     *
     * @param _owner an address which granted a permission to transfer
     *      tokens on its behalf
     * @param _spender an address which received a permission to transfer
     *      tokens on behalf of the owner `_owner`
     * @param _oldValue previously granted amount of tokens to transfer on behalf
     * @param _value new granted amount of tokens to transfer on behalf
     */
    event Approved(address indexed _owner, address indexed _spender, uint256 _oldValue, uint256 _value);
}