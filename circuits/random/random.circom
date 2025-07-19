pragma circom 2.1.9;

// include "../../node_modules/circomlib/circuits/mimcsponge.circom";
// include "../../node_modules/circomlib/circuits/bitify.circom";

// template Random() {
//     signal input in[3];
//     signal input KEY;
//     signal output out;

//     component mimc = MiMCSponge(3, 4, 1);

//     mimc.ins[0] <== in[0];
//     mimc.ins[1] <== in[1];
//     mimc.ins[2] <== in[2];
//     mimc.k <== KEY;

//     // component num2Bits = Num2Bits(254);
//     // num2Bits.in <== mimc.outs[0];

//     // Extract the first 4 bits and compute the output
//     out <== mimc.outs[0];
// }

//  component main = Random();


include "../../node_modules/circomlib/circuits/mimcsponge.circom";
include "../../node_modules/circomlib/circuits/bitify.circom";
include "../../node_modules/circomlib/circuits/comparators.circom";
include "../../node_modules/circomlib/circuits/poseidon.circom";


template Random() {
    signal input in[3];
    signal input KEY;
    signal input NONCE;
    signal input MAX_PLANET_ID;
    signal input MAX_COORDINATE;
    signal output out;


    // Ensure inputs are valid
    component max_planet_id_check = Num2Bits(252);
    max_planet_id_check.in <== MAX_PLANET_ID;
    component max_coordinate_check = Num2Bits(252);
    max_coordinate_check.in <== MAX_COORDINATE;

    // Use multiple MiMCSponge instances for better randomness
    component mimc1 = MiMCSponge(4, 220, 1);
    component mimc2 = MiMCSponge(4, 220, 1);
    component mimc3 = MiMCSponge(4, 220, 1);
    component mimc4 = MiMCSponge(4, 220, 1);

    mimc1.ins[0] <== in[0];
    mimc1.ins[1] <== in[1];
    mimc1.ins[2] <== in[2];
    mimc1.ins[3] <== NONCE;
    mimc1.k <== KEY;

    mimc2.ins[0] <== in[1];
    mimc2.ins[1] <== in[2];
    mimc2.ins[2] <== in[0];
    mimc2.ins[3] <== NONCE + 1;
    mimc2.k <== KEY;

    mimc3.ins[0] <== in[2];
    mimc3.ins[1] <== in[0];
    mimc3.ins[2] <== in[1];
    mimc3.ins[3] <== NONCE + 2;
    mimc3.k <== KEY;

    mimc4.ins[0] <== NONCE;
    mimc4.ins[1] <== in[0];
    mimc4.ins[2] <== in[1];
    mimc4.ins[3] <== in[2];
    mimc4.k <== KEY;

    // Generate planetId
    component poseidonHash = Poseidon(4);

    component planetIdMod = ModuloGate();
    planetIdMod.dividend <== mimc1.outs[0];
    planetIdMod.divisor <== MAX_PLANET_ID;
    poseidonHash.inputs[0] <== planetIdMod.remainder;

    // Generate x coordinate
    component xMod = ModuloGate();
    xMod.dividend <== mimc2.outs[0];
    xMod.divisor <== MAX_COORDINATE;
    poseidonHash.inputs[1] <== xMod.remainder;

    // Generate y coordinate
    component yMod = ModuloGate();
    yMod.dividend <== mimc3.outs[0];
    yMod.divisor <== MAX_COORDINATE;
    poseidonHash.inputs[2] <== yMod.remainder;

    // Generate z coordinate
    component zMod = ModuloGate();
    zMod.dividend <== mimc4.outs[0];
    zMod.divisor <== MAX_COORDINATE;
    poseidonHash.inputs[3] <== zMod.remainder;

    out <== poseidonHash.out;


    
}

// Custom modulo gate (unchanged)
template ModuloGate() {
    signal input dividend;
    signal input divisor;
    signal output remainder;

    signal quotient;
    quotient <-- dividend \ divisor;
    remainder <-- dividend % divisor;

    dividend === quotient * divisor + remainder;

    // Ensure remainder is less than divisor
    component lt = LessThan(252);
    lt.in[0] <== remainder;
    lt.in[1] <== divisor;
    lt.out === 1;
}

component main = Random();