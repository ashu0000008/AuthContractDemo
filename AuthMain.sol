pragma solidity >=0.4.22 <0.7.0;
import "./AuthContract.sol";

contract AuthMain {
    
    AuthContract mAuthContract;
    
    struct ContractAuthInfo{
        uint256 mCount;
        mapping (string => bool) mAuthedMap;
    }

    mapping (string => ContractAuthInfo) mAuthInfos;
    
    constructor(address contractAddress) public {
        mAuthContract = AuthContract(contractAddress);
    }
    
    function canAuth(string memory contractId) public view returns (bool, string memory){
        bool success;
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
    
    function reqAuth(string memory contractId, string memory deviceId) public{
        bool success;
        string memory reason;
        uint256 amount;
        uint256 expireAt;
        (success, reason, amount, expireAt) = checkContract(contractId);
        if (!success){
            return ;
        }
        
        ContractAuthInfo storage info = mAuthInfos[contractId];
        if (info.mCount >= amount){
            return ;
        }
        
        info.mAuthedMap[deviceId] = true;
        info.mCount = info.mCount + 1;
        return ;
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
}