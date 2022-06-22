pragma solidity >0.6.0 <=0.8.10;

import {ERC20} from "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/ERC20.sol";

contract ToyToken is ERC20 {
    constructor(string memory name, string memory symbol)
        public
        ERC20(name, symbol)
    {}

    function mint(address account, uint256 amount) external {
        _mint(account, amount);
    }

    function onERC1155Received(
        address operator,
        address from,
        uint256 id,
        uint256 value,
        bytes calldata data
    ) external returns (bytes4) {
        return
            bytes4(
                keccak256(
                    "onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"
                )
            );
    }

    function onERC1155BatchReceived(
        address operator,
        address from,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    ) external returns (bytes4) {
        return
            bytes4(
                keccak256(
                    "onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"
                )
            );
    }
}

//1.
// OWNER : 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4
// TOYTOKEN1 ADDRESS : 0xd9145CCE52D386f254917e481eB44e9943F39138
// TOYTOKEN2 ADDRESS : 0xd8b934580fcE35a11B58C6D73aDeE468a2833fa8

//2.
// mint some coins in contract

//3.
// select any other account to be oracle account :
// oracle1 : 0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2

//4.
// questionID can be set by user
// QuestionID : 0x0000000000000000000000000000000000000000000000000000000000000001   32byte value
// using oracle & questionid get
// outcomes : 3
// conditionID1 : 0xe4b72c4248b79248da6c25679753732098504f52cc5d563e95bd1b1408416478
// outcome slots :
// A B C (3)
// 0 1 1 --> 0X110 --> 6 ( condition B | C)
// collectionID for outcome B or C found using : (0xe4b72c4248b79248da6c25679753732098504f52cc5d563e95bd1b1408416478,6)
// collectionID for outcome A (0x001) found using : (0xe4b72c4248b79248da6c25679753732098504f52cc5d563e95bd1b1408416478,1)
// similary for all outcomes a diff. collectionID can be calc.

//5.
// to make aware the CT contract about the condition , we need to prepare it
// while preparing it doesnt req. to do it from oracle account , can be any account
// check outcomecount using getOutcomeSlotCount

//6. create another conditionID using diff. oracle address,questionID
// oracle2 :0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db
// QuestionID : 0x0000000000000000000000000000000000000000000000000000000000000002
// conditionID2 : 0x7a7c13c20d1c7e0d063f204ed76add6ff4de42db8a832df06a5b102af16ee95d
// outomeslots : low ,high (2)
// low : 0x01 --> 1
// low : 0x10 --> 2

//7. get collection ID
// use parentCollectionID : 0x0000000000000000000000000000000000000000000000000000000000000000   32byte value
//(B|C) collID : 0x5d9936091647cb3018c35c3850a3086a136e9a47d15ba511f69ca08ac8517bb8
// A collID : 0x47473e4382c5af8e619747ef68304f02f84e594d673c0c09e1a1cfaa909c6269

//8. get position ID
// positions : (token address,collectionID)
// T1:(B|C) --> (0xd9145CCE52D386f254917e481eB44e9943F39138,0x5d9936091647cb3018c35c3850a3086a136e9a47d15ba511f69ca08ac8517bb8)
// T1:(B|C) ===> 48226566970516594365202345079899389683268014862480297981185721461448212473971
// T1:(A) --> (0xd9145CCE52D386f254917e481eB44e9943F39138,0x47473e4382c5af8e619747ef68304f02f84e594d673c0c09e1a1cfaa909c6269)
// T1:(A) ====> 10777551540131446913629271022624352700287335646292712876943173991950159603857

//9.splitting collateral
// conditional tokens are mapped to positionIDs
// before splitting owner of collateral has to approve the tokens with CT , so as to check if he actually has the tokens using approve(CTaddress ,amount)
// set allowance for CT contract (owner of tokens ,CT address )
//
