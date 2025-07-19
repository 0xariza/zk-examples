pragma circom 2.1.9;

include "../../node_modules/circomlib/circuits/poseidon.circom";

template Reveal() {
    signal input planetId;
    signal input x;
    signal input y;
    signal input z;
    signal output out;

    // Hash the inputs using Poseidon
    component poseidonHash = Poseidon(4);
    poseidonHash.inputs[0] <== planetId;
    poseidonHash.inputs[1] <== x;
    poseidonHash.inputs[2] <== y;
    poseidonHash.inputs[3] <== z;

    // Compare the computed hash with the expected hash
    out <== poseidonHash.out;
}

component main = Reveal();

