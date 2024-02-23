// SPDX-License-Identifier: GPL-3.0
interface IERC721 {//nftaddress 0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2
    function safeTransferFrom(address from, address to, uint tokenId) external;

    function transferFrom(address, address, uint) external;
}
pragma solidity ^0.8.0;
contract EnglishAuction{
    uint endAt;
    bool start;
    bool end;
    uint public payment;
    uint public highestBid;
    mapping (address=>uint) public bid;
    mapping(address=>bool) public withRequest;
    address[] Participant;

    IERC721 NFT;
    uint NFTId;
    address payable seller;
    address highestBidder;
    constructor(address _NFTAddress, uint _NFTId)payable{
        NFT=IERC721(_NFTAddress);
        NFTId=_NFTId;
        seller=payable(msgsender());

    }
    function msgvalue()public payable returns(uint){
        return msg.value;
    }
    function msgsender()public payable returns(address){
        return msg.sender;
    }
    function Start()public{
        require(!start,"already started");
        start =true;
        endAt=block.timestamp+15;

    }
    function Bid()external payable returns(string memory){ //if you want to transfer directly to this address is needed
        require(start,"Aucktion not started yet");
        require(block.timestamp<endAt,"aucktion time is ended");
        require(bid[msgsender()]+msgvalue()>highestBid,"it is not the highest bid");
        bid[msgsender()]+=msgvalue();
        highestBid=bid[msgsender()];
        highestBidder=msgsender();
            return ("successful");
    }
    function balanceof()public view returns(uint){
        return address(this).balance;
    }
    function Withrequest()public{
        require(!withRequest[msgsender()],"Already requested");
        withRequest[msgsender()]=true;
    }
    function wihdraw(address _address)public returns(string memory _result){
            require(withRequest[_address],"address didnt request");      
            require (bid[_address]<highestBid,"you are winner and couldnt withdraw");
            require(bid[_address]>0,"you dont have any to withdraw");
            (bool success,)=_address.call{value:bid[_address]}("");
            require(success, "failed to withdraw");
            bid[_address]=0;
            payment+=bid[_address];
            _result="completed";
    }
    function End()public {
        require(start,"not started yet");
        require(block.timestamp>endAt,"not ended yet");
        require(!end,"already ended");
        end=true;
        if (highestBid>0){
            NFT.safeTransferFrom(address(this),highestBidder,NFTId);
            seller.transfer(highestBid);
        }
        else{
        NFT.safeTransferFrom(address(this),seller,NFTId);
        }
    }
}


contract A{
    event log(bytes,bool);
    receive() external payable {}
    constructor()payable{}
    event ErrorOccured(string errorMessage);
    function participantA(uint _value,address  _AuctionAdd)public {
        (bool success,bytes memory data)= _AuctionAdd.call{value:_value}(abi.encodeWithSignature("Bid()"));
        emit log(data,success);
    }
    function withdraw(address _address)public{
        EnglishAuction(_address).Withrequest();
    }
}
contract B{
    event log(bytes,bool);
    receive() external payable {}
    constructor()payable{}
    event ErrorOccured(string errorMessage);

    function participantB(uint _value,address  _AuctionAdd)public {
        (bool success,bytes memory data)= _AuctionAdd.call{value:_value}(abi.encodeWithSignature("Bid()"));
        emit log(data,success);
    }
    function withdraw(address _address)public{
        EnglishAuction(_address).Withrequest();
    }
}
contract C{
    event log(bytes,bool);
    receive() external payable {}
    constructor()payable{}
    event ErrorOccured(string errorMessage);

    function participantC(uint _value,address  _AuctionAdd)public {
        (bool success,bytes memory data)= _AuctionAdd.call{value:_value}(abi.encodeWithSignature("Bid()"));
        emit log(data,success);
    }
    function withdraw(address _address)public{
        EnglishAuction(_address).Withrequest();
    }
}