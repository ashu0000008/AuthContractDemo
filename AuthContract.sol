pragma solidity >=0.4.22 <0.7.0;

contract AuthContract {

    struct ContractInfo{
        uint256 amount;
        uint256 expireAt;
    }
    
    mapping (string => ContractInfo) private mContractInfos; 
    

    function addContract(string memory contractId, uint256 amount, uint256 expireAt) public returns (bool){
        ContractInfo memory info = ContractInfo(amount, expireAt);
        mContractInfos[contractId] = info;
        return true;
    }
    
    function getContractInfo(string memory contractId) public view returns (uint256, uint256){
        ContractInfo memory info = mContractInfos[contractId];
        return (info.amount, info.expireAt);
    }
    
    function delContract(string memory contractId) public {
        delete mContractInfos[contractId];
    }
    
}