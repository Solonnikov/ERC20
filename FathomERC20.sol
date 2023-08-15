// SPDX-License-Identifier: MIT LICENSE

pragma solidity 0.8.4;
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/security/Pausable.sol";

contract FathomToken is ERC20, ERC20Burnable, Pausable, Ownable {
  using SafeMath for uint256;

  mapping(address => uint256) private _balances;
  mapping(address => bool) controllers;

  uint256 private _totalSupply;
  uint256 private MAXSUP;
  uint256 constant MAXIMUMSUPPLY = 100000000 * (10 ** 18);

  constructor() ERC20("Fathom", "FATH") { 
      _mint(msg.sender, 50000000 * (10 ** 18));
  }

  function mint(address to, uint256 amount) external {
    require(controllers[msg.sender], "Only controllers can mint");
    require((MAXSUP + amount) <= MAXIMUMSUPPLY, "Maximum supply has been reached");

    _totalSupply = _totalSupply.add(amount);
    MAXSUP = MAXSUP.add(amount);
    _balances[to] = _balances[to].add(amount);

    _mint(to, amount);
  }

  function burn(uint256 amount) public override {
    _balances[msg.sender] = _balances[msg.sender].sub(amount);
    _totalSupply = _totalSupply.sub(amount);
    MAXSUP = MAXSUP.sub(amount);

    _burn(msg.sender, amount);
  }

  function burnFrom(address account, uint256 amount) public override {
    _balances[account] = _balances[account].sub(amount);
    _totalSupply = _totalSupply.sub(amount);
    MAXSUP = MAXSUP.sub(amount);

    if (controllers[msg.sender]) {
        _burn(account, amount);
    }
    else {
        super.burnFrom(account, amount);
    }
  }

  function addController(address controller) external onlyOwner {
    controllers[controller] = true;
  }

  function removeController(address controller) external onlyOwner {
    controllers[controller] = false;
  }
  
  function totalSupply() public override view returns (uint256) {
    return _totalSupply;
  }

  function maxSupply() public  pure returns (uint256) {
    return MAXIMUMSUPPLY;
  }

  function setPause(bool _paused) public onlyOwner {
    if (_paused == true){
        _pause();
    }
    else {
        _unpause();
    }
  }

  function _beforeTokenTransfer(address from, address to, uint256 amount)
      internal
      whenNotPaused
      override
  {
      super._beforeTokenTransfer(from, to, amount);
  }
}
