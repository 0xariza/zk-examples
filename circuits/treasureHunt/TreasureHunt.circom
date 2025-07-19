pragma circom 2.0.0;

include "circomlib/poseidon.circom";
include "circomlib/comparators.circom";
include "circomlib/bitify.circom";
include "circomlib/mux1.circom";
include "circomlib/mimcsponge.circom";

/*
 * Enhanced treasure hunt circuit using value-based positions
 * Each position contains a random value derived from the seed
 * Players need to find the position with the correct value
 */
template SecureTreasureHunt() {
    // Public inputs
    signal input boardHash;           // Current board state hash
    signal input difficulty;          // Current mining difficulty
    signal input positionValue;       // Value at the attempted position
    signal input nonce;               // Mining nonce
    signal input commitHash;          // Hash of player's commit
    
    // Private inputs
    signal private input boardSeed;   // Secret seed for board generation
    signal private input position;    // Player's chosen position (0 to BOARD_SIZE^2 - 1)
    signal private input randomness;  // Player's random value for commit
    signal private input blinding;    // Blinding factor for position value calculation
    
    // Output signals
    signal output isValidMining;      // Whether mining difficulty is met
    signal output isValidPosition;    // Whether position value is correct
    signal output isValidCommit;      // Whether commit matches revealed values
    
    // Constants
    var BOARD_SIZE = 10000; // 100x100 flattened
    var VALUE_MODULUS = 2**128; // Range for position values
    
    // ===== Position Value Generation =====
    
    // Generate position value using MiMCSponge (more unpredictable than Poseidon for this use case)
    component valueGenerator = MiMCSponge(1, 220, 1);
    valueGenerator.ins[0] <== position;
    valueGenerator.k <== boardSeed;
    
    // Apply blinding factor to make values unpredictable
    component blindedValue = MiMCSponge(2, 220, 1);
    blindedValue.ins[0] <== valueGenerator.outs[0];
    blindedValue.ins[1] <== blinding;
    blindedValue.k <== boardSeed;
    
    // Ensure position value matches the attempted value
    signal computedValue;
    computedValue <== blindedValue.outs[0] % VALUE_MODULUS;
    positionValue === computedValue;
    
    // ===== Board State Verification =====
    
    // Verify board state using multiple hash rounds
    component boardStateHasher = BoardStateVerifier();
    boardStateHasher.boardSeed <== boardSeed;
    boardStateHasher.blinding <== blinding;
    
    // Check computed board hash matches input
    boardHash === boardStateHasher.out;
    
    // ===== Position Validation =====
    
    // Check position is within board bounds
    component positionCheck = LessThan(32);
    positionCheck.in[0] <== position;
    positionCheck.in[1] <== BOARD_SIZE;
    isValidPosition <== positionCheck.out;
    
    // ===== Mining Verification =====
    
    // Compute mining hash using position value and nonce
    component miningHasher = MiningVerifier();
    miningHasher.positionValue <== positionValue;
    miningHasher.nonce <== nonce;
    miningHasher.position <== position;
    
    // Verify mining difficulty
    component difficultyCheck = LessThan(254);
    difficultyCheck.in[0] <== miningHasher.out;
    difficultyCheck.in[1] <== difficulty;
    isValidMining <== difficultyCheck.out;
    
    // ===== Commit Verification =====
    
    // Verify commit matches revealed values
    component commitVerifier = CommitVerifier();
    commitVerifier.position <== position;
    commitVerifier.positionValue <== positionValue;
    commitVerifier.randomness <== randomness;
    
    // Check computed commit matches input
    commitHash === commitVerifier.out;
}

/*
 * Verifies the overall board state
 * Uses multiple hash rounds and mixing functions
 */
template BoardStateVerifier() {
    signal input boardSeed;
    signal input blinding;
    signal output out;
    
    // Multiple hash rounds for better security
    component hasher1 = MiMCSponge(2, 220, 1);
    hasher1.ins[0] <== boardSeed;
    hasher1.ins[1] <== blinding;
    
    // Additional mixing round
    component hasher2 = Poseidon(2);
    hasher2.inputs[0] <== hasher1.outs[0];
    hasher2.inputs[1] <== blinding;
    
    out <== hasher2.out;
}

/*
 * Verifies mining proof-of-work
 * Combines position value, nonce, and position for unpredictability
 */
template MiningVerifier() {
    signal input positionValue;
    signal input nonce;
    signal input position;
    signal output out;
    
    // Mix inputs using MiMCSponge
    component hasher = MiMCSponge(3, 220, 1);
    hasher.ins[0] <== positionValue;
    hasher.ins[1] <== nonce;
    hasher.ins[2] <== position;
    
    out <== hasher.outs[0];
}

/*
 * Verifies commitment to prevent front-running
 * Combines position, value, and random nonce
 */
template CommitVerifier() {
    signal input position;
    signal input positionValue;
    signal input randomness;
    signal output out;
    
    // Compute commitment hash
    component hasher = Poseidon(3);
    hasher.inputs[0] <== position;
    hasher.inputs[1] <== positionValue;
    hasher.inputs[2] <== randomness;
    
    out <== hasher.out;
}

component main = SecureTreasureHunt();