pragma solidity >=0.4.22 <0.7.0;
import "./AuthContract.sol";
import "./AuthMain.sol";

contract AuthEntrance {
    event authedEventFinal(string contractId, string deviceId);
    event modifyContractEvent(bool success, string reason);
    
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
    
    function modifyContract(string memory contractId, uint256 amount, uint256 expireAfter) public returns (bool){
        AuthContract authContract = AuthContract(mContractAddress);
        bool result =  authContract.modifyContract(contractId, amount, expireAfter + now);
        if (result){
            emit modifyContractEvent(true, "");
        }else{
            emit modifyContractEvent(false, "Contract not exist!");
        }
        return result;
    }
    
    function delContract(string memory contractId) public{
        AuthContract authContract = AuthContract(mContractAddress);
        authContract.delContract(contractId);
        AuthMain authMain = AuthMain(mAuthAddress);
        authMain.delContract(contractId);
    }
    
    function canAuth(string memory contractId, string memory deviceId) public view returns (bool, string memory){
        AuthMain authMain = AuthMain(mAuthAddress);
        return authMain.canAuth(contractId, deviceId);
    }
    
    function reqAuth(string memory contractId, string memory deviceId) public {
        AuthMain authMain = AuthMain(mAuthAddress);
        bool result = authMain.reqAuth(contractId, deviceId);
        if (result){
            emit authedEventFinal(contractId, deviceId);
        }
    }
    
    function reqAuth4Performance(string memory contractId, string memory deviceId) public returns(string memory){
        AuthMain authMain = AuthMain(mAuthAddress);
        bool result = authMain.reqAuth(contractId, deviceId);
        if (result){
            emit authedEventFinal(contractId, deviceId);
        }
        return deviceId;
    }
    
    
    
    function isAuthed(string memory contractId, string memory deviceId) public view returns (bool, string memory){
        AuthMain authMain = AuthMain(mAuthAddress);
        return authMain.isAuthed(contractId, deviceId);
    }
    
    function forbiddenDevice(string memory contractId, string memory deviceId) public{
        AuthMain authMain = AuthMain(mAuthAddress);
        authMain.addForbiddenDevice(contractId, deviceId);
    }
    
}