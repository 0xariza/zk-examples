# ZK-Examples: A Comprehensive Collection of Zero-Knowledge Proof Circuits

A sophisticated collection of zero-knowledge proof (ZKP) circuits implemented in Circom, demonstrating advanced cryptographic techniques for privacy-preserving applications. This repository showcases various use cases including gaming mechanics, secure validation systems, and cryptographic primitives.

## 🚀 Features

- **Advanced Gaming Circuits**: Complex game mechanics with secure reward validation
- **Cryptographic Primitives**: Hash functions, random number generation, and commitment schemes
- **Privacy-Preserving Validation**: Secure verification without revealing sensitive data
- **Smart Contract Integration**: Exportable verifiers for blockchain applications
- **Comprehensive Testing**: Complete build pipeline with proof generation and verification

## 📁 Circuit Collection

### 🎮 Gaming & Interactive Circuits

#### **AdvancedGameCircuit** - Planet Discovery System
A sophisticated 3D universe exploration system with:
- **3D Position Validation**: Secure coordinate verification in 3D space
- **Planet Rarity System**: Dynamic rarity calculation based on multiple factors
- **Reward Distribution**: Fair reward calculation with rarity multipliers
- **Nullifier Generation**: Prevents double-spending and replay attacks
- **Difficulty Scaling**: Adaptive difficulty based on universe size and block number

#### **TreasureHunt** - Secure Treasure Hunting Game
Advanced treasure hunting mechanics featuring:
- **Board State Verification**: Secure board generation with seed-based randomness
- **Mining Difficulty**: Proof-of-work style mining with adjustable difficulty
- **Commitment Scheme**: Anti-front-running protection with commit-reveal pattern
- **Position Validation**: Secure position verification with blinding factors
- **Multi-Hash Security**: Multiple hash rounds for enhanced security

#### **TreasureMap** - Pathfinding Verification
3D pathfinding validation system:
- **Path Verification**: Validates step-by-step movement in 3D grid
- **Boundary Checking**: Ensures all coordinates stay within grid bounds
- **Treasure Location**: Secure treasure placement and discovery
- **Movement Constraints**: Enforces valid movement patterns (one step at a time)

### 🔐 Cryptographic Primitives

#### **Random** - Secure Random Number Generation
Advanced random number generation with:
- **Multi-MiMC Hashing**: Multiple MiMCSponge instances for enhanced randomness
- **Coordinate Generation**: Secure 3D coordinate generation
- **Modulo Operations**: Safe modular arithmetic with bounds checking
- **Poseidon Integration**: Final hash using Poseidon for consistency

#### **Reveal** - Commitment Verification
Simple but secure commitment scheme:
- **Poseidon Hashing**: Fast and secure hash function
- **4-Input Hashing**: Combines planet ID and 3D coordinates
- **Verification Ready**: Outputs hash for external verification

#### **LrValidation** - Pedersen Hash Validation
Classic cryptographic validation:
- **Pedersen Hashing**: Zero-knowledge friendly hash function
- **Bit Decomposition**: Converts numbers to bit arrays
- **Multi-Input Processing**: Handles 3 input values efficiently

### 🧮 Mathematical & Utility Circuits

#### **Multiplier2** - Basic Arithmetic
Simple multiplication circuit demonstrating:
- **Basic Operations**: Fundamental arithmetic in ZKP context
- **Signal Handling**: Proper input/output signal management
- **Template Structure**: Clean circuit template organization

#### **PlanetReward** - Coordinate Hashing
Specialized coordinate processing:
- **Multi-Coordinate Support**: Handles arrays of 3D coordinates
- **Pedersen Hashing**: Secure hash generation for coordinate sets
- **Bit-Level Processing**: Detailed bit manipulation for precision

#### **RandomPath** - Path Generation
Path-based random generation system (referenced in templates)

## 🛠️ Technical Architecture

### Circuit Design Principles
- **Modular Design**: Each circuit is self-contained and reusable
- **Security First**: Multiple validation layers and bounds checking
- **Gas Optimization**: Efficient constraint generation for blockchain deployment
- **Privacy Preservation**: Zero-knowledge properties maintained throughout

### Cryptographic Components
- **Poseidon Hash**: Primary hash function for most circuits
- **MiMCSponge**: Used for random number generation and complex hashing
- **Pedersen Hash**: Zero-knowledge friendly hash function
- **Modulo Gates**: Safe modular arithmetic operations
- **Comparators**: Range checking and validation

### Build System
- **Automated Compilation**: Single command circuit building
- **Trusted Setup**: Complete Groth16 trusted setup process
- **Proof Generation**: Automated proof creation and verification
- **Smart Contract Export**: Ready-to-deploy Solidity verifiers

## 🚀 Quick Start

### Prerequisites
```bash
# Install Rust (required for Circom)
curl --proto '=https' --tlsv1.2 https://sh.rustup.rs -sSf | sh

# Install Node.js (v10 or higher)
# Download from https://nodejs.org/

# Install Circom
git clone https://github.com/iden3/circom.git
cd circom
cargo build --release
cargo install --path .
```

### Installation
```bash
# Clone the repository
git clone <your-repo-url>
cd zk-examples

# Install dependencies
yarn install
```

### Building Circuits
```bash
# Build any circuit (replace 'circuitName' with actual circuit name)
yarn run build -- circuitName

# Examples:
yarn run build -- multiplier2
yarn run build -- treasureHunt
yarn run build -- AdvancedGameCircuit
```

### Available Circuits
- `multiplier2` - Basic multiplication
- `treasureHunt` - Treasure hunting game
- `treasure_map` - Pathfinding verification
- `random` - Random number generation
- `reveal` - Commitment verification
- `lr_validation` - Pedersen hash validation
- `planet_reward` - Coordinate hashing
- `AdvancedGameCircuit` - Planet discovery system
- `AdvancedPlanetVerification` - Advanced planet verification
- `random_path` - Path-based generation
- `random2` - Alternative random generation

## 📊 Circuit Complexity Analysis

| Circuit | Lines of Code | Complexity | Use Case |
|---------|---------------|------------|----------|
| Multiplier2 | 10 | Basic | Learning/Testing |
| Reveal | 25 | Low | Commitment Schemes |
| LrValidation | 34 | Low | Hash Validation |
| PlanetReward | 40 | Medium | Coordinate Processing |
| Random | 130 | High | Random Generation |
| TreasureMap | 76 | Medium | Path Verification |
| TreasureHunt | 159 | Very High | Gaming Mechanics |
| AdvancedGameCircuit | 175 | Very High | Complex Gaming |

## 🔧 Development

### Project Structure
```
zk-examples/
├── circuits/           # All Circom circuit files
├── input_templates/    # JSON input templates for testing
├── scripts/           # Build and utility scripts
├── src/               # JavaScript utilities
└── build/             # Generated files (created during build)
```

### Adding New Circuits
1. Create a new directory in `circuits/`
2. Add your `.circom` file
3. Create corresponding input template in `input_templates/`
4. Test with `yarn run build -- yourCircuitName`

### Testing
Each circuit includes:
- Input validation
- Bounds checking
- Constraint verification
- Proof generation and verification
- Smart contract export

## 🌟 Key Features

### Security Features
- **Bounds Checking**: All inputs validated against reasonable ranges
- **Nullifier Generation**: Prevents double-spending in gaming circuits
- **Commitment Schemes**: Anti-front-running protection
- **Multi-Hash Security**: Multiple hash rounds for critical operations

### Performance Optimizations
- **Efficient Constraints**: Minimal constraint count for gas optimization
- **Modular Design**: Reusable components across circuits
- **Smart Hashing**: Appropriate hash functions for each use case

### Blockchain Integration
- **Solidity Export**: All circuits export verifier contracts
- **Gas Optimization**: Efficient constraint generation
- **Standard Compliance**: Compatible with major ZKP frameworks

## 🤝 Contributing

We welcome contributions! Please see [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

### Contribution Areas
- New circuit implementations
- Performance optimizations
- Security improvements
- Documentation enhancements
- Testing and validation

## 📄 License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details.

## 🙏 Acknowledgments

- **Circom Team**: For the excellent circuit compilation framework
- **SnarkJS**: For the comprehensive ZKP toolkit
- **Circomlib**: For the essential cryptographic primitives

---

**Built with ❤️ for the ZKP community**

*This repository demonstrates advanced zero-knowledge proof techniques suitable for production applications in gaming, DeFi, and privacy-preserving systems.*
