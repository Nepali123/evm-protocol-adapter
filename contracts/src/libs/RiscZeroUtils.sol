// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import {Compliance} from "../proving/Compliance.sol";
import {Logic} from "../proving/Logic.sol";
import "forge-std/console.sol";

/// @title RiscZeroUtils
/// @author Anoma Foundation, 2025
/// @notice A library containing utility functions to convert and encode types for RISC Zero.
/// @custom:security-contact security@anoma.foundation
library RiscZeroUtils {
    /// @notice Calculates the digest of the compliance instance (journal).
    /// @param instance The compliance instance.
    /// @return digest The journal digest.
    function toJournalDigest(Compliance.Instance memory instance) internal pure returns (bytes32 digest) {
        bytes4 eight = hex"08000000";
        bytes memory encodedInstance = abi.encodePacked(eight);
        encodedInstance = abi.encodePacked(encodedInstance, instance.consumed.nullifier);
        encodedInstance = abi.encodePacked(encodedInstance, eight);
        encodedInstance = abi.encodePacked(encodedInstance, instance.consumed.logicRef);
        encodedInstance = abi.encodePacked(encodedInstance, eight);
        encodedInstance = abi.encodePacked(encodedInstance, instance.consumed.commitmentTreeRoot);
        encodedInstance = abi.encodePacked(encodedInstance, eight);
        encodedInstance = abi.encodePacked(encodedInstance, instance.created.commitment);
        encodedInstance = abi.encodePacked(encodedInstance, eight);
        encodedInstance = abi.encodePacked(encodedInstance, instance.created.logicRef);
        encodedInstance = abi.encodePacked(encodedInstance, eight);
        encodedInstance = abi.encodePacked(encodedInstance, instance.unitDeltaX);
        encodedInstance = abi.encodePacked(encodedInstance, eight);
        encodedInstance = abi.encodePacked(encodedInstance, instance.unitDeltaY);
        console.logBytes(encodedInstance);
        digest = sha256(encodedInstance);
    }

    /// @notice Calculates the digest of the logic instance (journal).
    /// @param instance The logic instance.
    /// @return digest The journal digest.
    function toJournalDigest(Logic.Instance memory instance) internal pure returns (bytes32 digest) {
        digest = sha256(convertJournal(instance));
    }

    /// @notice Converts the logic instance to match the RISC Zero journal.
    /// @param instance The logic instance.
    /// @return converted The converted journal.
    function convertJournal(Logic.Instance memory instance) internal pure returns (bytes memory converted) {
        uint32 nBlobs = uint32(instance.appData.discoveryPayload.length);
        bytes memory encodedAppData = abi.encodePacked(toRiscZero(nBlobs));
        {
            for (uint256 i = 0; i < nBlobs; ++i) {
                bytes memory blobEncoded = abi.encodePacked(
                    uint32(instance.appData.discoveryPayload[i].blob.length),
                    instance.appData.discoveryPayload[i].blob,
                    uint32(instance.appData.discoveryPayload[i].deletionCriterion)
                );
                encodedAppData = abi.encodePacked(encodedAppData, blobEncoded);
            }
        }

        nBlobs = uint32(instance.appData.resourcePayload.length);
        {
            for (uint256 i = 0; i < nBlobs; ++i) {
                bytes memory blobEncoded = abi.encodePacked(
                    uint32(instance.appData.resourcePayload[i].blob.length),
                    instance.appData.resourcePayload[i].blob,
                    uint32(instance.appData.resourcePayload[i].deletionCriterion)
                );
                encodedAppData = abi.encodePacked(encodedAppData, blobEncoded);
            }
        }

        nBlobs = uint32(instance.appData.externalPayload.length);
        {
            for (uint256 i = 0; i < nBlobs; ++i) {
                bytes memory blobEncoded = abi.encodePacked(
                    uint32(instance.appData.externalPayload[i].blob.length),
                    instance.appData.externalPayload[i].blob,
                    uint32(instance.appData.externalPayload[i].deletionCriterion)
                );
                encodedAppData = abi.encodePacked(encodedAppData, blobEncoded);
            }
        }

        nBlobs = uint32(instance.appData.applicationPayload.length);
        {
            for (uint256 i = 0; i < nBlobs; ++i) {
                bytes memory blobEncoded = abi.encodePacked(
                    uint32(instance.appData.applicationPayload[i].blob.length),
                    instance.appData.applicationPayload[i].blob,
                    uint32(instance.appData.applicationPayload[i].deletionCriterion)
                );
                encodedAppData = abi.encodePacked(encodedAppData, blobEncoded);
            }
        }

        converted =
            abi.encodePacked(instance.tag, toRiscZero(instance.isConsumed), instance.actionTreeRoot, encodedAppData);
    }

    /// @notice Converts a `bool` to the RISC Zero format to `bytes4` by appending three zero bytes.
    /// @param value The value.
    /// @return converted The converted value.
    function toRiscZero(bool value) internal pure returns (bytes4 converted) {
        converted = value ? bytes4(0x01000000) : bytes4(0x00000000);
    }

    /// @notice Converts a `uint32` to the RISC Zero format to `bytes4` by appending three zero bytes.
    /// @param value The value.
    /// @return converted The converted value.
    function toRiscZero(uint32 value) internal pure returns (bytes4 converted) {
        converted = bytes4(
            ((value & 0x000000FF) << 24) | ((value & 0x0000FF00) << 8) | ((value & 0x00FF0000) >> 8)
                | ((value & 0xFF000000) >> 24)
        );
    }
}
