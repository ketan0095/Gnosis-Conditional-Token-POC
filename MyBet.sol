pragma solidity >0.6.0 <=0.8.10;

import {IERC20} from "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/ERC20.sol";
import {ConditionalTokens} from "./ConditionalTokens.sol";

contract MyBet {
    IERC20 ks;
    ConditionalTokens conditionalTokens;
    address public oracle;
    mapping(bytes32 => mapping(uint256 => uint256)) tokenBalance;
    address admin;
    uint256 outcomecount;
    bool betStatus;
    uint256[] betresultarray;

    constructor(
        address _ks,
        address _conditionalTokens,
        address _oracle
    ) public {
        ks = IERC20(_ks);
        conditionalTokens = ConditionalTokens(_conditionalTokens);
        oracle = _oracle;
        admin = msg.sender;
        outcomecount = 2;
        betStatus = false;
    }

    function createBet(bytes32 questionID, uint256 amount)
        public
        payable
        returns (bytes32)
    {
        // prepare conditionID
        conditionalTokens.prepareCondition(oracle, questionID, outcomecount);

        // create conditionID
        bytes32 CondID;
        CondID = conditionalTokens.getConditionId(
            oracle,
            questionID,
            outcomecount
        ); // 0xd70c1896331c669ce62ff7d35ebcde5ae9fef6f7af44c01614ab273707add946

        //bitarray [01,10] --> [1,2]
        uint256[] memory partition = new uint256[](2);
        partition[0] = 1;
        partition[1] = 2;

        // before splitting get approval from spender for CT account
        bool approve_flag;
        approve_flag = ks.approve(address(conditionalTokens), amount); //get approval

        if (approve_flag) {
            // if approved by owner
            uint256 totalallowance;
            totalallowance = ks.allowance(
                msg.sender,
                address(conditionalTokens)
            ); //get allowance for conditional token address

            conditionalTokens.splitPosition(
                ks,
                bytes32(0), // considering root index
                CondID,
                partition, // all the possible outcmoes , represented in terms of bitmap
                totalallowance
            );

            // add token to each condition index slots
            tokenBalance[questionID][0] += amount;
            tokenBalance[questionID][1] += amount;
            betStatus = true;

            return CondID;
        } else {
            revert("Not allowed !");
            return bytes32(0);
        }
    }

    function reverseBet(
        bytes32 questionID,
        bytes32 conditionID,
        uint256[] calldata partition,
        uint256 amount
    ) public {
        require(partition.length > 0, "no index set supplied !");
        require(amount > 0, "amount should be > 0");
        require(
            conditionalTokens.getOutcomeSlotCount(conditionID) > 0,
            "condition is not prepared!"
        );

        // give return back collateral tokens to user
        conditionalTokens.mergePositions(
            ks,
            bytes32(0),
            conditionID,
            partition,
            amount
        );

        if (partition.length > 0) {
            tokenBalance[questionID][0] -= amount;
        } else {
            tokenBalance[questionID][1] -= amount;
        }
    }

    function betResult(bytes32 questionID, uint256[] calldata partition)
        private
    {
        require(msg.sender == oracle, "unidentified oracle validator !");
        betresultarray = partition;
        conditionalTokens.reportPayouts(questionID, partition);
        betStatus = false;
    }

    function transferTokens(
        bytes32 questionId, // so we can identify bet
        uint256 indexSet, // outcoe collection
        address to, // recepient of conditional token
        uint256 amount
    ) external {
        require(msg.sender == admin, "Only admin !");
        require(
            tokenBalance[questionId][indexSet] >= amount,
            "not enough balance!"
        );

        bytes32 conditionID = conditionalTokens.getConditionId(
            oracle,
            questionId,
            3 // no. of outcomes
        );

        bytes32 collectionId = conditionalTokens.getCollectionId(
            bytes32(0),
            conditionID,
            indexSet
        );

        uint256 positionId = conditionalTokens.getPositionId(ks, collectionId);

        conditionalTokens.safeTransferFrom(
            address(this),
            to, //need to implement IERC1155Recieiver
            positionId,
            amount,
            ""
        );
    }

    function reedemTokens(bytes32 conditionId, uint256[] calldata indexSet)
        external
    {
        require(betStatus == false, "Betting is not finished yet !");
        conditionalTokens.redeemPositions(
            ks,
            bytes32(0),
            conditionId,
            indexSet
        );
    }

    function transferks(address to, uint256 amount) external {
        require(msg.sender == admin, "only admin");
        ks.transfer(to, amount);
    }
}
