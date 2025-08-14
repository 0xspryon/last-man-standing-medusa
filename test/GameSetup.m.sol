// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test, console2} from "forge-std/Test.sol";
import {Game} from "../src/Game.sol";
import {IStdCheats} from "./Cheats.sol";

contract TestSetup {
    Game public game;
    IStdCheats cheats = IStdCheats(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);

    address public deployer;
    address public player1;
    address public player2;
    address public player3;
    address public maliciousActor;

    // Initial game parameters for testing
    uint256 public constant INITIAL_CLAIM_FEE = 0.1 ether; // 0.1 ETH
    uint256 public constant GRACE_PERIOD = 1 days; // 1 day in seconds
    uint256 public constant FEE_INCREASE_PERCENTAGE = 10; // 10%
    uint256 public constant PLATFORM_FEE_PERCENTAGE = 5; // 5%

    uint256 public ghost_claimFee;
    uint256 public ghost_claimFeeIncreasePercentage = FEE_INCREASE_PERCENTAGE;
    mapping(address => uint256) public ghost_playerClaimCount;
    address[] public ghost_players;

    constructor() payable asMsgSender {
        game = new Game(
            INITIAL_CLAIM_FEE,
            GRACE_PERIOD,
            FEE_INCREASE_PERCENTAGE,
            PLATFORM_FEE_PERCENTAGE
        );
        // Even though we prank the msg.sender in each function,
        // The actual value transfer debits this contract and not the pranked msg.sender.
        cheats.deal(address(this), 1000 ether);
    }

    modifier notAsOwner() {
        require(msg.sender != game.owner(), "Can not be called by owner");
        _;
    }

    modifier asMsgSender() {
        cheats.startPrank(msg.sender);
        _;
        cheats.stopPrank();
    }

    modifier updateGhost() {
        ghost_claimFee = game.claimFee();
        if (ghost_playerClaimCount[msg.sender] == 0) {
            ghost_players.push(msg.sender);
        }
        ghost_playerClaimCount[msg.sender] += 1;
        _;
    }

    function game_claimThrone(
        uint amount
    ) public asMsgSender notAsOwner updateGhost {
        require(
            amount < 20_000 ether,
            "Amount should be less than 20_000 ether"
        );
        ghost_claimFee = game.claimFee();
        game.claimThrone{value: amount}();
        // _assertClaimThrone();
    }

    function game_declareWinner() public asMsgSender notAsOwner {
        game.declareWinner();
    }

    function game_resetGame() public asMsgSender {
        game.resetGame();
    }

    function game_updateClaimFeeParameters(
        uint256 _newInitialClaimFee,
        uint256 _newFeeIncreasePercentage
    ) public asMsgSender {
        ghost_claimFeeIncreasePercentage = _newFeeIncreasePercentage;
        ghost_claimFee = _newInitialClaimFee;
        require(
            !game.gameEnded(),
            "Can not update parameter if game isn't ended."
        );
        game.updateClaimFeeParameters(
            _newInitialClaimFee,
            _newFeeIncreasePercentage
        );
    }

    function game_updateGracePeriod(
        uint256 _newGracePeriod
    ) public asMsgSender {
        game.updateGracePeriod(_newGracePeriod);
    }

    function game_updatePlatformFeePercentage(
        uint256 _newPlatformFeePercentage
    ) public asMsgSender {
        game.updatePlatformFeePercentage(_newPlatformFeePercentage);
    }

    function game_withdrawPlatformFees() public asMsgSender {
        game.withdrawPlatformFees();
    }

    function game_withdrawWinnings() public asMsgSender notAsOwner {
        game.withdrawWinnings();
    }

    // function _assertClaimThrone() internal virtual {}
}
