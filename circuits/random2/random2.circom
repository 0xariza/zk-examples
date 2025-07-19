// pragma circom 2.1.9;

// include "../../node_modules/circomlib/circuits/mimcsponge.circom";
// include "../../node_modules/circomlib/circuits/bitify.circom";

// template Random2(max_value) {
//     signal input max_value;
//     signal input KEY;
//     signal output out;

//     // Define private signals for random numbers
//     signal private x;
//     signal private y;
//     signal private z;

//     // Generate random numbers within the given range
//     component rng_x = RandomGenerator();
//     rng_x.key <== KEY;
//     rng_x.seed <== 0; // Different seed for each number
//     x <== rng_x.out % max_value;

//     component rng_y = RandomGenerator();
//     rng_y.key <== KEY;
//     rng_y.seed <== 1; // Different seed for each number
//     y <== rng_y.out % max_value;

//     component rng_z = RandomGenerator();
//     rng_z.key <== KEY;
//     rng_z.seed <== 2; // Different seed for each number
//     z <== rng_z.out % max_value;

//     // Poseidon Hash Function
//     component poseidon = Poseidon(3);

//     poseidon.ins[0] <== x;
//     poseidon.ins[1] <== y;
//     poseidon.ins[2] <== z;

//     out <== poseidon.outs[0];
// }

// template RandomGenerator() {
//     signal input key;
//     signal input seed;
//     signal output out;

//     component mimc = MiMCSponge(2, 1, 1);
//     mimc.ins[0] <== key;
//     mimc.ins[1] <== seed;
//     out <== mimc.outs[0];
// }

//  component main = Random(1000);