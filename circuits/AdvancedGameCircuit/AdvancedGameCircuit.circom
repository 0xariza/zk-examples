pragma circom 2.0.0;

include "../../node_modules/circomlib/circuits/comparators.circom";
include "../../node_modules/circomlib/circuits/poseidon.circom";
include "../../node_modules/circomlib/circuits/bitify.circom";

template ModuloCheck() {
    signal input in;
    signal input n; // modulus
    signal output out;
    signal output div;

    div <-- in \ n;
    out <-- in % n;

    // Check that out < n
    component lt = LessThan(252);
    lt.in[0] <== out;
    lt.in[1] <== n;
    lt.out === 1;

    // Verify the division
    in === div * n + out;
}

template AdvancedPlanetVerification() {
    // Public inputs
    signal input publicGameSeed;  
    signal input universeSize;
    signal input blockNumber;     
    signal input difficulty;      
    signal input validityThreshold;
    
    // Position signals
    signal input claimedX;
    signal input claimedY;
    signal input claimedZ;
    
    // Private inputs
    signal input playerSeed;      
    signal input discoveryNonce;  
    signal input explorationProof;
    
    // Outputs
    signal output nullifier;      
    signal output rewardAmount;   
    signal output planetType;     
    
    // Input range checks
    component universeSizeCheck = LessThan(252);
    universeSizeCheck.in[0] <== universeSize;
    universeSizeCheck.in[1] <== 1000000001; // Max universe size
    universeSizeCheck.out === 1;

    component difficultyCheck = LessThan(252);
    difficultyCheck.in[0] <== difficulty;
    difficultyCheck.in[1] <== 1000000; // Max difficulty
    difficultyCheck.out === 1;

    // Position validation
    component positionHash = Poseidon(5);
    positionHash.inputs[0] <== publicGameSeed;
    positionHash.inputs[1] <== playerSeed;
    positionHash.inputs[2] <== discoveryNonce;
    positionHash.inputs[3] <== blockNumber;
    positionHash.inputs[4] <== explorationProof;
    
    // Calculate valid positions
    component mod1 = ModuloCheck();
    component mod2 = ModuloCheck();
    component mod3 = ModuloCheck();
    
    // X position
    component pos1Hash = Poseidon(2);
    pos1Hash.inputs[0] <== positionHash.out;
    pos1Hash.inputs[1] <== 1;
    
    mod1.in <== pos1Hash.out;
    mod1.n <== universeSize;
    signal validX;
    validX <== mod1.out;
    
    // Y position
    component pos2Hash = Poseidon(2);
    pos2Hash.inputs[0] <== positionHash.out;
    pos2Hash.inputs[1] <== 2;
    
    mod2.in <== pos2Hash.out;
    mod2.n <== universeSize;
    signal validY;
    validY <== mod2.out;
    
    // Z position
    component pos3Hash = Poseidon(2);
    pos3Hash.inputs[0] <== positionHash.out;
    pos3Hash.inputs[1] <== 3;
    
    mod3.in <== pos3Hash.out;
    mod3.n <== universeSize;
    signal validZ;
    validZ <== mod3.out;
    
    // Position matching constraints
    claimedX === validX;
    claimedY === validY;
    claimedZ === validZ;
    
    // Planet rarity calculation
    component rarityHash = Poseidon(3);
    rarityHash.inputs[0] <== positionHash.out;
    rarityHash.inputs[1] <== blockNumber;
    rarityHash.inputs[2] <== difficulty;
    
    // Planet type calculation
    component typeModulo = ModuloCheck();
    typeModulo.in <== rarityHash.out;
    typeModulo.n <== 5;
    planetType <== typeModulo.out;
    
    // Rarity check with safety
    component rarityCheck = LessThan(252);
    rarityCheck.in[0] <== rarityHash.out;
    rarityCheck.in[1] <== validityThreshold;
    
    // Add explicit verification of rarity check
    signal rarityValid;
    rarityValid <== rarityCheck.out;
    rarityValid === 1;
    
    // Reward calculation
    component rewardHash = Poseidon(6);
    rewardHash.inputs[0] <== positionHash.out;
    rewardHash.inputs[1] <== rarityHash.out;
    rewardHash.inputs[2] <== planetType;
    rewardHash.inputs[3] <== difficulty;
    rewardHash.inputs[4] <== blockNumber;
    rewardHash.inputs[5] <== explorationProof;
    
    // Base reward calculation
    component rewardModulo = ModuloCheck();
    rewardModulo.in <== rewardHash.out;
    rewardModulo.n <== 1000;
    signal baseReward;
    baseReward <== rewardModulo.out + 100;
    
    // Rarity multiplier
    signal rarityMultiplier;
    rarityMultiplier <== 1 + planetType;
    
    // Final reward
    rewardAmount <== baseReward * rarityMultiplier;
    
    // Nullifier generation
    component nullifierHash = Poseidon(7);
    nullifierHash.inputs[0] <== publicGameSeed;
    nullifierHash.inputs[1] <== playerSeed;
    nullifierHash.inputs[2] <== discoveryNonce;
    nullifierHash.inputs[3] <== validX;
    nullifierHash.inputs[4] <== validY;
    nullifierHash.inputs[5] <== validZ;
    nullifierHash.inputs[6] <== blockNumber;
    
    nullifier <== nullifierHash.out;
}

component main {public [
    publicGameSeed, 
    universeSize, 
    blockNumber, 
    difficulty, 
    validityThreshold,
    claimedX,
    claimedY,
    claimedZ
]} = AdvancedPlanetVerification();