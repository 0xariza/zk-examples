
pragma circom 2.1.9;

include "../../node_modules/circomlib/circuits/comparators.circom";
include "../../node_modules/circomlib/circuits/poseidon.circom";

template TreasureMap(n, m) {
    // n: number of steps in the path
    // m: size of the grid (m x m x m)
    
    // Public inputs
    signal input startX;
    signal input startY;
    signal input startZ;
    signal input treasureHash;
    
    // Private inputs
    signal input path[n][3];  // Array of [x,y,z] coordinates
    signal input treasureX;
    signal input treasureY;
    signal input treasureZ;
    
    // Output
    signal output validPath;
    
    // Components
    component poseidon = Poseidon(3);
    component lessThan[n * 3];
    component greaterThan[n * 3];
    
    // Check start point
    path[0][0] === startX;
    path[0][1] === startY;
    path[0][2] === startZ;
    
    // Verify each step in the path
    for (var i = 0; i < n - 1; i++) {
        // Ensure coordinates are within grid
        for (var j = 0; j < 3; j++) {
            lessThan[i*3 + j] = LessThan(8);
            greaterThan[i*3 + j] = GreaterThan(8);
            
            lessThan[i*3 + j].in[0] <== path[i][j];
            lessThan[i*3 + j].in[1] <== m;
            greaterThan[i*3 + j].in[0] <== path[i][j];
            greaterThan[i*3 + j].in[1] <== 0;
            
            lessThan[i*3 + j].out === 1;
            greaterThan[i*3 + j].out === 1;
        }
        
        // Check if move is valid (only one coordinate changes by 1)
        var dx = path[i+1][0] - path[i][0];
        var dy = path[i+1][1] - path[i][1];
        var dz = path[i+1][2] - path[i][2];
        (dx * dx) + (dy * dy) + (dz * dz) === 1;
    }
    
    // Verify treasure location
    path[n-1][0] === treasureX;
    path[n-1][1] === treasureY;
    path[n-1][2] === treasureZ;
    
    // Hash the treasure location
    poseidon.inputs[0] <== treasureX;
    poseidon.inputs[1] <== treasureY;
    poseidon.inputs[2] <== treasureZ;
    
    // Verify the treasure hash
    treasureHash === poseidon.out;
    
    // Output 1 if path is valid
    validPath <== 1;
}

component main {public [startX, startY, startZ, treasureHash]} = TreasureMap(100, 20);