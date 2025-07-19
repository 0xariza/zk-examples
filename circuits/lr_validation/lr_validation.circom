pragma circom 2.0.0;

include "../../node_modules/circomlib/circuits/pedersen_old.circom";
include "../../node_modules/circomlib/circuits/bitify.circom";


template LrValidation() {
    signal input in[3];
    signal output out[2];

    component pedersen = Pedersen(250*3);

    component n2b[3];
    n2b[0] = Num2Bits(250); //11111010
    n2b[1] = Num2Bits(250);
    n2b[2] = Num2Bits(250);

    var i;

    in[0] ==> n2b[0].in; //123 == 1111011 == n2b[0].out 
    in[1] ==> n2b[1].in; //456 == 1110011000 == n2b[1].out
    in[2] ==> n2b[2].in; //16 == 10000 == n2b[2].out

    for  (i=0; i<250; i++) {
        n2b[0].out[i] ==> pedersen.in[i];
        n2b[1].out[i] ==> pedersen.in[250+i];
        n2b[2].out[i] ==> pedersen.in[500+i];
    }

    pedersen.out[0] ==> out[0];
    pedersen.out[1] ==> out[1];
}

component main = LrValidation();