pragma solidity >=0.4.22 <0.7.0;
import "./AuthContract.sol";

contract AuthMain {
    
    AuthContract mAuthContract;
    
    struct ContractAuthInfo{
        uint256 mCount;
        mapping (string => bool) mAuthedMap;
    }

    mapping (string => ContractAuthInfo) mAuthInfos;
    mapping (string=>bool) mForbiddenDevice;
    
    constructor(address contractAddress) public {
        mAuthContract = AuthContract(contractAddress);
    }
    
    function canAuth(string memory contractId, string memory deviceId) public view returns (bool, string memory){
        bool success;
        if (mForbiddenDevice[deviceId] == true){
            return (false, "Device is forbidden!");
        }
        
        string memory reason;
        uint256 amount;
        uint256 expireAt;
        (success, reason, amount, expireAt) = checkContract(contractId);
        if (!success){
            return (success, reason);
        }
        
        ContractAuthInfo storage info = mAuthInfos[contractId];
        if (info.mCount >= amount){
            return (false, "The license quantity has been used up!");
        }
        
        return (true, "");
    }
    
    function reqAuth(string memory contractId, string memory deviceId) public notForbidden(deviceId) returns(bool){
        bool success;
        string memory reason;
        uint256 amount;
        uint256 expireAt;
        (success, reason, amount, expireAt) = checkContract(contractId);
        if (!success){
            return false;
        }
        
        ContractAuthInfo storage info = mAuthInfos[contractId];
        if (info.mCount >= amount){
            return false;
        }
        
        info.mAuthedMap[deviceId] = true;
        info.mCount = info.mCount + 1;
        
        return true;
    }
    
    function isAuthed(string memory contractId, string memory deviceId) public view returns (bool, string memory){
        bool success;
        string memory reason;
        uint256 amount;
        uint256 expireAt;
        (success, reason, amount, expireAt) = checkContract(contractId);
        if (!success){
            return (success, reason);
        }
        
        ContractAuthInfo storage info = mAuthInfos[contractId];
        bool authed = info.mAuthedMap[deviceId];
        if (!authed){
            return (false, "Not authed!");
        }
        return (true, "");
    }
    
    function checkContract(string memory contractId) private view returns (bool, string memory, uint256, uint256){
        
        uint256 amount;
        uint256 expire;
        (amount, expire) = mAuthContract.getContractInfo(contractId);
        if (0 == amount){
            return (false, "No contract!", 0, 0);
        }
        if (0 == expire){
            return (false, "Contract expire!", 0, 0);
        }
        if (now > expire){
            return (false, "Contract expire!", 0, 0);
        }
        
        return (true, "", amount, expire);
    }
    
    
    
    function delContract(string memory contractId) public{
        delete mAuthInfos[contractId];
    }
    
    function addForbiddenDevice(string memory deviceId) public{
        mForbiddenDevice[deviceId] = true;
    }
    
    modifier notForbidden(string memory deviceId){
        require (mForbiddenDevice[deviceId] == false);
        _;
    }
}