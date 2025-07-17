// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import {Pausable} from "openzeppelin/contracts/utils/Pausable.sol";
import {RiscZeroVerifierRouter} from "@risc0-ethereum/RiscZeroVerifierRouter.sol";

import {Test} from "forge-std/Test.sol";

import {ProtocolAdapter} from "../src/ProtocolAdapter.sol";
import {Transaction, Action} from "../src/Types.sol";
import {Example} from "./mocks/Example.sol";

contract ProtocolAdapterTest is Test {
    ProtocolAdapter internal _pa;

    RiscZeroVerifierRouter internal _sepoliaVerifierRouter;

    function setUp() public {
        // Fork Sepolia
        vm.selectFork(vm.createFork("sepolia"));

        string memory path = "./script/constructor-args.txt";

        _sepoliaVerifierRouter = RiscZeroVerifierRouter(vm.parseAddress(vm.readLine(path)));

        _pa = new ProtocolAdapter({
            riscZeroVerifierRouter: RiscZeroVerifierRouter(_sepoliaVerifierRouter), // Sepolia verifier
            commitmentTreeDepth: uint8(vm.parseUint(vm.readLine(path))),
            actionTagTreeDepth: uint8(vm.parseUint(vm.readLine(path)))
        });
    }

    function test_execute() public {
        address riscZeroEmergencyStop =
            address(_sepoliaVerifierRouter.getVerifier(bytes4(Example._CONSUMED_LOGIC_PROOF)));

        vm.expectRevert(Pausable.EnforcedPause.selector, riscZeroEmergencyStop);

        _pa.execute(Example.transaction());
    }

    function test_execute_empty_tx() public {
        Transaction memory txn = Transaction({actions: new Action[](0), deltaProof: ""});
        _pa.execute(txn);
    }

    function test_verify() public {
        address riscZeroEmergencyStop =
            address(_sepoliaVerifierRouter.getVerifier(bytes4(Example._CONSUMED_LOGIC_PROOF)));

        vm.expectRevert(Pausable.EnforcedPause.selector, riscZeroEmergencyStop);
        _pa.verify(Example.transaction());
    }

    function test_verify_empty_tx() public view {
        Transaction memory txn = Transaction({actions: new Action[](0), deltaProof: ""});
        _pa.verify(txn);
    }
}
