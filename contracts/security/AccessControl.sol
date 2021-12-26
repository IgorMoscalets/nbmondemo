//SPDX-License-Identifier: MIT

pragma solidity ^0.8.6;

import "./Context.sol";

/**
 * @dev AccessControl allows role-based access control mechanisms
 * for contracts inheriting from it.
 */
abstract contract AccessControl is Context {
    address public admin;
    address public minter;
    address public burner;
    address public ceo;
    address public manager;
    
    constructor() {
        admin = _msgSender();
        minter = _msgSender();
        burner = _msgSender();
        ceo = _msgSender();
        manager = _msgSender();
    }

    modifier onlyAdmin() {
        require(_msgSender() == admin);
        _;
    }

    modifier onlyMinter() {
        require(_msgSender() == minter);
        _;
    }

    modifier onlyBurner() {
        require(_msgSender() == burner);
        _;
    }

    modifier onlyCEO() {
        require(_msgSender() == ceo);
        _;
    }

    modifier onlyManager() {
        require(_msgSender() == manager);
        _;
    }

    modifier onlyAdminOrCEO() {
        require(
            _msgSender() == admin || 
            _msgSender() == ceo
        );
        _;
    }

    modifier allRoles() {
        require(
            _msgSender() == admin ||
            _msgSender() == minter ||
            _msgSender() == burner ||
            _msgSender() == ceo || 
            _msgSender() == manager
        );
        _;
    }

    function newAdmin(address _newAdmin) public onlyAdmin {
        require(_newAdmin != address(0));
        admin = _newAdmin;
    }

    function newMinter(address _newMinter) public onlyAdminOrCEO {
        require(_newMinter != address(0));
        minter = _newMinter;
    }

    function newBurner(address _newBurner) public onlyAdminOrCEO {
        require(_newBurner != address(0));
        burner = _newBurner;
    }

    function newCEO(address _newCEO) public onlyAdmin {
        require(_newCEO != address(0));
        ceo = _newCEO;
    }

    function newManager(address _newManager) public onlyAdminOrCEO {
        require(_newManager != address(0));
        manager = _newManager;
    }
}