// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import {MerkleTree} from "../../src/libs/MerkleTree.sol";
import {SHA256} from "../../src/libs/SHA256.sol";

import {console} from "forge-std/Test.sol";

contract MerkleTreeExample {
    uint256 internal constant _N_LEAFS = 7;
    uint256 internal constant _N_ROOTS = 8;

    // We will push 4 leafs - hence the tree will have 5 states

    bytes32[][_N_ROOTS] internal _leaves;
    bytes32[][_N_LEAFS][_N_ROOTS] internal _siblings;
    mapping(uint256 capacity => uint256[]) internal _directionBits; // One for every leaf

    bytes32[_N_ROOTS] internal _roots;

    function _setupMockTree() internal {
        /*
        (0)       (1)            (2)            (3)                   (4)                        (5)        
        []        B0             C0             C0'                   D0                         D0'        
                 /  \           /  \           /  \                  /  \                       /  \        
            -> A0    [] ->>   B0'  []   ->   B0'  B1  ->           /     \        ->          /     \        
                             / \   / \      / \   / \            /        \                 /        \     
                            A0 A1 [] []    A0 A1 A2 []         C0'         []             C0'         C1    
                                                              /  \        /  \           /  \        /  \   
                                                            B0'  B1'    []   []        B0'  B1'    B2   []  
                                                           / \   / \   / \   / \      / \   / \   / \   / \ 
                                                          A0 A1 A2 A3 [] [] [] []    A0 A1 A2 A3 A4 [] [] []
        */

        // State 0
        {
            _leaves[0] = new bytes32[](1);
            _leaves[0][0] = SHA256.EMPTY_HASH;

            _roots[0] = MerkleTree.computeRoot(_leaves[0]);
        }

        // State 1
        {
            _leaves[1] = new bytes32[](2);
            _leaves[1][0] = bytes32(uint256(1));
            _leaves[1][1] = SHA256.EMPTY_HASH;

            _roots[1] = MerkleTree.computeRoot(_leaves[1]);
        }

        // State 2
        {
            _leaves[2] = new bytes32[](4);
            _leaves[2][0] = _leaves[1][0];
            _leaves[2][1] = bytes32(uint256(2));
            _leaves[2][2] = SHA256.EMPTY_HASH;
            _leaves[2][3] = SHA256.EMPTY_HASH;

            _roots[2] = MerkleTree.computeRoot(_leaves[2]);
        }

        // State 3
        {
            _leaves[3] = new bytes32[](4);
            _leaves[3][0] = _leaves[2][0];
            _leaves[3][1] = _leaves[2][1];
            _leaves[3][2] = bytes32(uint256(3));
            _leaves[3][3] = SHA256.EMPTY_HASH;

            _roots[3] = MerkleTree.computeRoot(_leaves[3]);
        }

        // State 4
        {
            _leaves[4] = new bytes32[](8);
            _leaves[4][0] = _leaves[3][0];
            _leaves[4][1] = _leaves[3][1];
            _leaves[4][2] = _leaves[3][2];
            _leaves[4][3] = bytes32(uint256(4));
            _leaves[4][4] = SHA256.EMPTY_HASH;
            _leaves[4][5] = SHA256.EMPTY_HASH;
            _leaves[4][6] = SHA256.EMPTY_HASH;
            _leaves[4][7] = SHA256.EMPTY_HASH;

            _roots[4] = MerkleTree.computeRoot(_leaves[4]);
        }

        // State 5
        {
            _leaves[5] = new bytes32[](8);
            _leaves[5][0] = _leaves[4][0];
            _leaves[5][1] = _leaves[4][1];
            _leaves[5][2] = _leaves[4][2];
            _leaves[5][3] = _leaves[4][3];
            _leaves[5][4] = bytes32(uint256(5));
            _leaves[5][5] = SHA256.EMPTY_HASH;
            _leaves[5][6] = SHA256.EMPTY_HASH;
            _leaves[5][7] = SHA256.EMPTY_HASH;

            _roots[5] = MerkleTree.computeRoot(_leaves[5]);
        }

        // State 6
        {
            _leaves[6] = new bytes32[](8);
            _leaves[6][0] = _leaves[5][0];
            _leaves[6][1] = _leaves[5][1];
            _leaves[6][2] = _leaves[5][2];
            _leaves[6][3] = _leaves[5][3];
            _leaves[6][4] = _leaves[5][4];
            _leaves[6][5] = bytes32(uint256(6));
            _leaves[6][6] = SHA256.EMPTY_HASH;
            _leaves[6][7] = SHA256.EMPTY_HASH;

            _roots[6] = MerkleTree.computeRoot(_leaves[6]);
        }

        // State 7
        {
            _leaves[7] = new bytes32[](8);
            _leaves[7][0] = _leaves[6][0];
            _leaves[7][1] = _leaves[6][1];
            _leaves[7][2] = _leaves[6][2];
            _leaves[7][3] = _leaves[6][3];
            _leaves[7][4] = _leaves[6][4];
            _leaves[7][5] = _leaves[6][5];
            _leaves[7][6] = bytes32(uint256(7));
            _leaves[7][7] = SHA256.EMPTY_HASH;

            _roots[7] = MerkleTree.computeRoot(_leaves[7]);
        }

        //// State 8
        //{
        //    _leaves[8] = new bytes32[](8);
        //    _leaves[8][0] = _leaves[7][0];
        //    _leaves[8][1] = _leaves[7][1];
        //    _leaves[8][2] = _leaves[7][2];
        //    _leaves[8][3] = _leaves[7][3];
        //    _leaves[8][4] = _leaves[7][4];
        //    _leaves[8][5] = _leaves[7][5];
        //    _leaves[8][6] = _leaves[7][6];
        //    _leaves[8][7] = bytes32(uint256(8));
        //
        //    _roots[8] = MerkleTree.computeRoot(_leaves[8]);
        //}

        {
            _directionBits[1] = new uint256[](0);

            _directionBits[2] = new uint256[](2);
            _directionBits[2][0] = 1; // 1
            _directionBits[2][1] = 0; // 0

            _directionBits[4] = new uint256[](4);
            _directionBits[4][0] = 3; // 11
            _directionBits[4][1] = 2; // 11
            _directionBits[4][2] = 1; // 10
            _directionBits[4][3] = 0; // 10

            _directionBits[8] = new uint256[](8);
            _directionBits[8][0] = 7; // 111
            _directionBits[8][1] = 6; // 110
            _directionBits[8][2] = 5; // 101
            _directionBits[8][3] = 4; // 100
            _directionBits[8][4] = 3; // 011
            _directionBits[8][5] = 2; // 010
            _directionBits[8][6] = 1; // 001
            _directionBits[8][7] = 0; // 000
        }
    }
}
