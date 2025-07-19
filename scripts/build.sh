#!/bin/bash

# Exit script on any error
set -e

# Check if a circuit name was provided
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <circuit_name>"
    exit 1
fi

# Assign the first argument to a variable
CIRCUIT_NAME=$1

# Create necessary directories if they do not exist
echo "Setting up directories for $CIRCUIT_NAME..."
mkdir -p build/$CIRCUIT_NAME

# Check and create input.json if it doesn't exist based on a template
if [ ! -f build/$CIRCUIT_NAME/input.json ]; then
    if [ -f input_templates/$CIRCUIT_NAME.json ]; then
        echo "Creating input.json for $CIRCUIT_NAME from template..."
        cp input_templates/$CIRCUIT_NAME.json build/$CIRCUIT_NAME/input.json
    else
        echo "Error: No input template found for $CIRCUIT_NAME"
        exit 1
    fi
fi

# Step 1: Compile the circuit with Circom
echo "Compiling $CIRCUIT_NAME circuit..."
circom circuits/$CIRCUIT_NAME/$CIRCUIT_NAME.circom  --r1cs --wasm --sym --c -o build/$CIRCUIT_NAME

# Step 2: Compute the witness using the WebAssembly output
echo "Computing witness for $CIRCUIT_NAME..."
node build/$CIRCUIT_NAME/${CIRCUIT_NAME}_js/generate_witness.js build/$CIRCUIT_NAME/${CIRCUIT_NAME}_js/$CIRCUIT_NAME.wasm build/$CIRCUIT_NAME/input.json build/$CIRCUIT_NAME/${CIRCUIT_NAME}_js/witness.wtns

# Step 3: Trusted setup phase (Phase 1)
echo "Starting trusted setup phase 1 for $CIRCUIT_NAME..."
cd build/$CIRCUIT_NAME
snarkjs powersoftau new bn128 14 pot14_0000.ptau -v
snarkjs powersoftau contribute pot14_0000.ptau pot14_0001.ptau --name="First contribution" -v
snarkjs powersoftau prepare phase2 pot14_0001.ptau pot14_final.ptau -v

# Step 4: Trusted setup phase (Phase 2)
echo "Starting trusted setup phase 2 for $CIRCUIT_NAME..."
snarkjs zkey new $CIRCUIT_NAME.r1cs pot14_final.ptau ${CIRCUIT_NAME}_0000.zkey -v
snarkjs zkey contribute ${CIRCUIT_NAME}_0000.zkey ${CIRCUIT_NAME}_0001.zkey --name="1st Contributor Name" -v
snarkjs zkey export verificationkey ${CIRCUIT_NAME}_0001.zkey verification_key.json

# Step 5: Generating a proof
echo "Generating proof for $CIRCUIT_NAME..."
snarkjs groth16 prove ${CIRCUIT_NAME}_0001.zkey ${CIRCUIT_NAME}_js/witness.wtns proof.json public.json

# Step 6: Verifying the proof
echo "Verifying proof for $CIRCUIT_NAME..."
snarkjs groth16 verify verification_key.json public.json proof.json

# Step 7: Export verifier to Solidity contract
echo "Exporting verifier to Solidity for $CIRCUIT_NAME..."
snarkjs zkey export solidityverifier ${CIRCUIT_NAME}_0001.zkey verifier.sol

# Step 8: Generate the call data for the verification smart contract
echo "Generating call data for the smart contract..."
snarkjs generatecall

echo "Script execution completed successfully."
