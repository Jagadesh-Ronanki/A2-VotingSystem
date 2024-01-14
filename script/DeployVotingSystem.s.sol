// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Script} from "forge-std/Script.sol";
import {VotingSystem} from "../src/VotingSystem.sol";
import {HelperConfig} from "./HelperConfig.s.sol";

contract DeployVotingSystem is Script {

    function run() external returns(VotingSystem, HelperConfig) {
        HelperConfig helperConfig = new HelperConfig();
        (,uint256 deployerKey) = helperConfig.activeNetworkConfig();

        vm.startBroadcast(deployerKey);
        VotingSystem votingSystemContract = new VotingSystem();
        vm.stopBroadcast();

        return (votingSystemContract, helperConfig);
    }
}