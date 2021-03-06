pragma solidity >=0.4.22 <=0.7.0;


import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

//import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC721/ERC721Full.sol";
//import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/ownership/Ownable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./MartianAuction.sol";

contract MartianMarket is ERC721, Ownable {
    
    constructor() ERC721("MartianMarket", "MARS") public {}

    // cast a payable address for the Martian Development Foundation to be the beneficiary in the auction
    // this contract is designed to have the owner of this contract (foundation) to pay for most of the function calls
    // (all but bid and withdraw)
    
    //using Counters for Counters.Counter;
    
    //Counters.Counter token_ids;
    
    address payable foundation_address = msg.sender;

    mapping(uint => MartianAuction) public auctions;
    


    function registerLand(string memory tokenURI) public payable onlyOwner {
       // token_ids.increment();
        
        uint _id = totalSupply();
        _mint(msg.sender, _id);
        _setTokenURI(_id, tokenURI);
        createAuction(_id);
    }

    function createAuction(uint tokenId) public onlyOwner {
        auctions[tokenId] = new MartianAuction(foundation_address);
    }

    function endAuction(uint tokenId) public onlyOwner {
        require(_exists(tokenId), "This Land is not registered!");
        MartianAuction auction = getAuction(tokenId);
        auction.auctionEnd();
        safeTransferFrom(owner(), auction.highestBidder(), tokenId);
       // token_owner[tokenId]=auction.highestBidder();
        
    }
    
    function getAuction(uint tokenId) public view returns(MartianAuction auction) {
        return auctions[tokenId];
      
    }

    function auctionEnded(uint tokenId) public view returns(bool) {
        require(_exists(tokenId), "This Land is not registered!");
        MartianAuction auction = getAuction(tokenId);
        return auction.ended();
    }
    
    function highestBid(uint tokenId) public view returns(uint) {
        require(_exists(tokenId), "This Land is not registered!");
        MartianAuction auction = getAuction(tokenId);
        return auction.highestBid();
    }

    function pendingReturn(uint tokenId, address sender) public view returns(uint) {
        require(_exists(tokenId), "This Land is not registered!");
        MartianAuction auction = getAuction(tokenId);
        return auction.pendingReturn(sender);
    }

   function bid(uint tokenId) public payable {
        require(_exists(tokenId), "This Land is not registered!");
        MartianAuction auction = getAuction(tokenId);
        auction.bid.value(msg.value)(msg.sender);
    }


}
