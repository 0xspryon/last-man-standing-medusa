// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test, console2} from "forge-std/Test.sol";
import {GameMedusaTest} from "./Game.m.sol";

contract GameTest is Test, GameMedusaTest {
    // forge test --match-test test_game_claimThrone_0 -vvv

    function test_game_claimThrone_0() public {
        vm.roll(12);
        vm.warp(12);
        vm.prank(address(0x30000));
        game_claimThrone(100000000000000234);
    }
}

