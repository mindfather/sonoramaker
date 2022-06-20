// SPDX-License-Identifier: VPL
pragma solidity ^0.8.14;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "erc721a/contracts/ERC721A.sol";

/**
 * @title keybladee contract
 * @dev Simple implementation for a mint w/ whitelist based on ERC721A
 * */
contract Keybladee is ERC721A, Ownable {
  enum SaleState { CLOSED, PRESALE, SALE };
  address public constant MILADY_MAKER = 0x5Af0D9827E0c53E4799BB226655A1de152A425a5;
  uint public constant MAX_KEYBLADEE = 111;
  uint256 mintPrice = 60000000000000000; //0.06 ETH
  string private _baseTokenURI;
  SaleState saleState = SaleState.CLOSED;

  constructor(string memory baseURI) ERC721A("keybladee", "KBLD") {
    _baseTokenURI = baseURI;
  }

  modifier saleActive() {
    require(
      saleState != SaleState.CLOSED
    , "Sale must be active to mint keybladee."
    );
    _;
  }

  modifier callerIsUser() {
    require(
      tx.origin == msg.sender
    , "Are you who you say you are?"
    );
    _;
  }

  modifier supplyRemaining() {
    require(
      _totalMinted() < MAX_KEYBLADEE
    , "All keybladees have been minted."
    );
    _;
  }

  modifier onlyOne() {
    require(
      balanceOf(msg.sender) < 1
    , "Save some keybladees for everyone else!"
    );
    _;
  }

  function disableSale() public
    onlyOwner
  {
    saleState = SaleState.CLOSED;
  }

  function activatePresale() public
    onlyOwner
  {
    saleState = SaleState.PRESALE;
  }

  function activateSale() public
    onlyOwner
  {
    saleState = SaleState.SALE;
  }

  function mint(uint256 quantity) external payable
    callerIsUser
    saleActive
  {
    if(saleState == SaleState.PRESALE) {
      require(
        ERC721(MILADY_MAKER).balanceOf(msg.sender) >= 1
      , "You need more network spirit if you wish to mint a keybladee right now."
      );
    }
    require(
      _totalMinted() + quantity <= MAX_KEYBLADEE
    , "All keybladees have been minted."
    );
    require(
      mintPrice.mul(quantity) <= msg.value
    , "This is not enough ETH to mint your keybladees."
    );
    _safeMint(msg.sender, quantity);
  }

  function reserveMint(uint256 quantity) external
    onlyOwner
    callerIsUser
    supplyRemaining
  {
    require(
      quantity + _totalMinted() <= MAX_KEYBLADEE
    , "Sorry, but there can only be 111 keybladees."
    );
    _safeMint(msg.sender, quantity);
  }

  function setBaseURI(string calldata baseURI) external
    onlyOwner
  {
    _baseTokenURI = baseURI;
  }

  function _baseURI() internal view virtual override returns (string memory) {
		return _baseTokenURI;
	}
}
