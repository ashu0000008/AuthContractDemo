pragma solidity >=0.4.22 <0.7.0;
import "./AuthContract.sol";
import "./AuthMain.sol";

contract AuthEntrance {
    address private mContractAddress;
    address private mAuthAddress;
    
    constructor(address contractAddress, address authAddress) public {
        mContractAddress = contractAddress;
        mAuthAddress =authAddress;
    }
    
    function addContract(string memory contractId, uint256 amount, uint256 expireAfter) public returns (bool){
        AuthContract authContract = AuthContract(mContractAddress);
        return authContract.addContract(contractId, amount, expireAfter + now);
    }
    
    function delContract(string memory contractId){
        
    }
    
    function canAuth(string memory contractId) public view returns (bool, string memory){
        AuthMain authMain = AuthMain(mAuthAddress);
        return authMain.canAuth(contractId);
    }
    
    function reqAuth(string memory contractId, string memory deviceId) public {
        AuthMain authMain = AuthMain(mAuthAddress);
        authMain.reqAuth(contractId, deviceId);
    }
    
    function isAuthed(string memory contractId, string memory deviceId) public view returns (bool, string memory){
        AuthMain authMain = AuthMain(mAuthAddress);
        return authMain.isAuthed(contractId, deviceId);
    }
}