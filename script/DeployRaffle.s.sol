// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity >=0.8.13 <0.9.0;

import {Script} from "forge-std/Script.sol";
import {Raffle} from "../src/Raffle.sol";
import {HelperConfig} from "./HelperConfig.s.sol";
import {Interactions, FundSubscription, AddConsumer} from "./Interactions.s.sol";

contract DeployRaffle is Script {
    function run() public {}

    function deployRaffle() public returns (Raffle, HelperConfig) {
        HelperConfig helperConfig = new HelperConfig();
        // local -> deploy mocks, get local config.
        // sepolia -> get sepolia config.
        HelperConfig.NetworkConfig memory config = helperConfig.getConfig();

        if (config.subscriptionId == 0) {
            // create a new subscription
            Interactions interaction = new Interactions();
            (config.subscriptionId, config.vrfCoordinator) = interaction.createSubscription(config.vrfCoordinator);

            //fund it

            FundSubscription fundSubscription = new FundSubscription();
            fundSubscription.fundSubscription(config.vrfCoordinator, config.subscriptionId, config.link);

        }

        vm.startBroadcast();

        Raffle raffle = new Raffle(
            config.entranceFee,
            config.interval,
            config.vrfCoordinator,
            config.gasLane,
            config.subscriptionId,
            config.callbackGasLimit
        );

        vm.stopBroadcast();

        AddConsumer addConsumer = new AddConsumer();
        addConsumer.addConsumer(address(raffle), config.vrfCoordinator, config.subscriptionId);

        return (raffle, helperConfig);
    }
}
