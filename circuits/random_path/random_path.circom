pragma circom 2.1.9;

include "../../node_modules/circomlib/circuits/poseidon.circom";
include "../../node_modules/circomlib/circuits/bitify.circom";

template RandomPath(n) {
    // Public inputs
    signal input targetX;
    signal input targetY;
    signal input targetZ;
    
    // Private input
    signal input seed;
    
    // Intermediate signal
    signal path[n];
    
    // Output
    signal output hashedPath;

    component hasher[n];
    component num2Bits[n];
    component bits2Num[n];

    // Generate the first path element
    hasher[0] = Poseidon(4); // Changed to 4 inputs to include target coordinates
    hasher[0].inputs[0] <== seed;
    hasher[0].inputs[1] <== targetX;
    hasher[0].inputs[2] <== targetY;
    hasher[0].inputs[3] <== targetZ;
    num2Bits[0] = Num2Bits(254);
    num2Bits[0].in <== hasher[0].out;
    bits2Num[0] = Bits2Num(2);
    bits2Num[0].in[0] <== num2Bits[0].out[0];
    bits2Num[0].in[1] <== num2Bits[0].out[1];
    path[0] <== bits2Num[0].out;

    // Generate subsequent path elements
    for (var i = 1; i < n; i++) {
        hasher[i] = Poseidon(1);
        hasher[i].inputs[0] <== hasher[i-1].out;
        num2Bits[i] = Num2Bits(254);
        num2Bits[i].in <== hasher[i].out;
        bits2Num[i] = Bits2Num(2);
        bits2Num[i].in[0] <== num2Bits[i].out[0];
        bits2Num[i].in[1] <== num2Bits[i].out[1];
        path[i] <== bits2Num[i].out;
    }

    // Hash the entire path to create the final hashedPath
    component finalHasher = Poseidon(n+3); // +3 for target coordinates
    finalHasher.inputs[0] <== targetX;
    finalHasher.inputs[1] <== targetY;
    finalHasher.inputs[2] <== targetZ;
    for (var i = 0; i < n; i++) {
        finalHasher.inputs[i+3] <== path[i];
    }

    hashedPath <== finalHasher.out;
}

component main = RandomPath(10); // Generate a hashed path of length 10
