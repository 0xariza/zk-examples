const snarkjs = require("snarkjs");
const fs = require("fs");
const path = require("path");

async function run() {
  try {
    const wasmPath = path.resolve(
      __dirname,
      "../build/reveal/reveal_js/reveal.wasm"
    );
    const validation_0001 = path.resolve(
      __dirname,
      "../build/reveal/reveal_0001.zkey"
    );

    // Check if file exists
    if (!fs.existsSync(wasmPath)) {
      throw new Error(`Wasm file not found at ${wasmPath}`);
    }

    if (!fs.existsSync(validation_0001)) {
      throw new Error(`reveal file not found at ${validation_0001}`);
    }

    const publicSignalsPath = path.resolve(
      __dirname,
      "../build/random/public.json"
    );

    const publicSignals = JSON.parse(fs.readFileSync(publicSignalsPath));

    for (let i = 0; i < 4; i++) {
      for (let x = 0; x < 4; x++) {
        for (let y = 0; y < 4; y++) {
          for (let z = 0; z < 4; z++) {
            const { proof } = await snarkjs.groth16.fullProve(
              {
                planetId: i,
                x,
                y,
                z,
              },
              wasmPath,
              validation_0001
            );

            // console.log("Proof: ");

            // console.log(JSON.stringify(proof, null, 1));

            // console.log("public signal: ");
            // console.log(JSON.stringify(publicSignals, null, 1));

            // Export Solidity call data
            const SolidityCallData =
              await snarkjs.groth16.exportSolidityCallData(
                proof,
                publicSignals
              );
            // console.log("SolidityCallData: ", SolidityCallData);

            const vKeyPath = path.resolve(
              __dirname,
              "../build/reveal/verification_key.json"
            );

            if (!fs.existsSync(vKeyPath)) {
              throw new Error(`vKey file not found at ${vKeyPath}`);
            }
            const vKey = JSON.parse(fs.readFileSync(vKeyPath));

            const res = await snarkjs.groth16.verify(
              vKey,
              publicSignals,
              proof
            );

            // console.log(res, "res");

            if (res === true) {
              console.log("Verification OK");
              console.log(i,x,y,z);
            } else {
              console.log("Invalid proof");
            }
          }
        }
      }
    }
  } catch (err) {
    console.error("Error:", err.message);
  }
}

run().then(() => {
  process.exit(0);
});
