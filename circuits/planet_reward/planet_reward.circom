pragma circom 2.0.0;

include "../../node_modules/circomlib/circuits/pedersen_old.circom";
include "../../node_modules/circomlib/circuits/bitify.circom";

template PlanetReward(numCoords) {
    signal input planetId;
    signal input coords[numCoords][3]; // An array of coordinates (x, y, z)
    signal output hashedCoords[numCoords][2]; // Hashed outputs for each coordinate

    component n2b[numCoords][3];
    component pedersen[numCoords];

    var i, j;

    for (i = 0; i < numCoords; i++) {
        // Initialize Num2Bits components
        for (j = 0; j < 3; j++) {
            n2b[i][j] = Num2Bits(250);
            coords[i][j] ==> n2b[i][j].in;
        }

        // Initialize Pedersen hash components
        pedersen[i] = Pedersen(250 * 3);

        // Feed the bits into the Pedersen hash input
        for (j = 0; j < 250; j++) {
            n2b[i][0].out[j] ==> pedersen[i].in[j];
            n2b[i][1].out[j] ==> pedersen[i].in[250 + j];
            n2b[i][2].out[j] ==> pedersen[i].in[500 + j];
        }

        // Get the hashed output
        pedersen[i].out[0] ==> hashedCoords[i][0];
        pedersen[i].out[1] ==> hashedCoords[i][1];
    }
}

component main = PlanetReward(3);
