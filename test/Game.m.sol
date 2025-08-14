// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {console2} from "forge-std/Test.sol";
import {Game} from "../src/Game.sol";
import {IStdCheats} from "./Cheats.sol";
import {TestSetup} from "./GameSetup.m.sol";

contract GameMedusaTest is TestSetup {
    // Invariant: The `claimFee` increases by `feeIncreasePercentage` per expected after each call to `claimThrone`
    function test_claimFeeUpdatesPerFeeIncreasePercentage() public view {
        require(!game.gameEnded());
        if (game.currentKing() == address(0)) {
            require(false, "No king yet");
        }
        uint expectedClaimFee = ghost_claimFee +
            (ghost_claimFee * game.feeIncreasePercentage()) /
            100;
        assert(game.claimFee() == expectedClaimFee);
    }

    // System-wide Invariant: sum of all user claims equals `totalClaims`
    function test_sumUserClaimsEqualsTotalClaims() public view {
        uint expectedTotalClaims = 0;
        for (uint i = 0; i < ghost_players.length; i++) {
            expectedTotalClaims += ghost_playerClaimCount[ghost_players[i]];
        }
        for (uint i = 0; i < ghost_players.length; i++) {
            assert(
                game.playerClaimCount(ghost_players[i]) ==
                    ghost_playerClaimCount[ghost_players[i]]
            );
        }
        assert(game.totalClaims() == expectedTotalClaims);
    }
}
