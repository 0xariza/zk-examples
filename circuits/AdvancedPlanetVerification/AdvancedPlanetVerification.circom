pragma circom 2.0.0;

include "../../node_modules/circomlib/circuits/comparators.circom";
include "../../node_modules/circomlib/circuits/poseidon.circom";
include "../../node_modules/circomlib/circuits/bitify.circom";

template ModuloCheck() {
    signal input in;
    signal input n;
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
    // Public inputs with range checks
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
    
    // Debug signals
    signal posHashOutput;
    signal rarityHashOutput;
    signal rarityCheckResult;
    
    // Basic input validation
    component claimedXCheck = LessThan(252);
    component claimedYCheck = LessThan(252);
    component claimedZCheck = LessThan(252);
    
    claimedXCheck.in[0] <== claimedX;
    claimedXCheck.in[1] <== universeSize;
    claimedXCheck.out === 1;
    
    claimedYCheck.in[0] <== claimedY;
    claimedYCheck.in[1] <== universeSize;
    claimedYCheck.out === 1;
    
    claimedZCheck.in[0] <== claimedZ;
    claimedZCheck.in[1] <== universeSize;
    claimedZCheck.out === 1;
    
    // Initial position hash
    component positionHash = Poseidon(5);
    positionHash.inputs[0] <== publicGameSeed;
    positionHash.inputs[1] <== playerSeed;
    positionHash.inputs[2] <== discoveryNonce;
    positionHash.inputs[3] <== blockNumber;
    positionHash.inputs[4] <== explorationProof;
    
    posHashOutput <== positionHash.out;
    
    // Calculate positions
    component mod1 = ModuloCheck();
    component mod2 = ModuloCheck();
    component mod3 = ModuloCheck();
    
    component pos1Hash = Poseidon(2);
    pos1Hash.inputs[0] <== posHashOutput;
    pos1Hash.inputs[1] <== 1;
    
    mod1.in <== pos1Hash.out;
    mod1.n <== universeSize;
    signal validX;
    validX <== mod1.out;
    
    component pos2Hash = Poseidon(2);
    pos2Hash.inputs[0] <== posHashOutput;
    pos2Hash.inputs[1] <== 2;
    
    mod2.in <== pos2Hash.out;
    mod2.n <== universeSize;
    signal validY;
    validY <== mod2.out;
    
    component pos3Hash = Poseidon(2);
    pos3Hash.inputs[0] <== posHashOutput;
    pos3Hash.inputs[1] <== 3;
    
    mod3.in <== pos3Hash.out;
    mod3.n <== universeSize;
    signal validZ;
    validZ <== mod3.out;
    
    // Position verification
    claimedX === validX;
    claimedY === validY;
    claimedZ === validZ;
    
    // Rarity calculation with debug
    component rarityHash = Poseidon(3);
    rarityHash.inputs[0] <== posHashOutput;
    rarityHash.inputs[1] <== blockNumber;
    rarityHash.inputs[2] <== difficulty;
    
    rarityHashOutput <== rarityHash.out;
    
    // Ensure rarity hash is within valid range
    component rarityHashCheck = LessThan(252);
    rarityHashCheck.in[0] <== rarityHashOutput;
    rarityHashCheck.in[1] <== validityThreshold;
    
    // Store rarity check result
    rarityCheckResult <== rarityHashCheck.out;
    rarityCheckResult === 1;
    
    // Planet type calculation
    component typeModulo = ModuloCheck();
    typeModulo.in <== rarityHashOutput;
    typeModulo.n <== 5;
    planetType <== typeModulo.out;
    
    // Reward calculation
    component rewardHash = Poseidon(6);
    rewardHash.inputs[0] <== posHashOutput;
    rewardHash.inputs[1] <== rarityHashOutput;
    rewardHash.inputs[2] <== planetType;
    rewardHash.inputs[3] <== difficulty;
    rewardHash.inputs[4] <== blockNumber;
    rewardHash.inputs[5] <== explorationProof;
    
    component rewardModulo = ModuloCheck();
    rewardModulo.in <== rewardHash.out;
    rewardModulo.n <== 1000;
    
    signal baseReward;
    baseReward <== rewardModulo.out + 100;
    
    signal rarityMultiplier;
    rarityMultiplier <== 1 + planetType;
    
    rewardAmount <== baseReward * rarityMultiplier;
    
    // Nullifier calculation
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