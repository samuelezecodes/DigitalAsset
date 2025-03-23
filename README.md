# Digital Asset Registry


[![Build Status](https://img.shields.io/badge/build-passing-brightgreen.svg)]()
[![Clarity Version](https://img.shields.io/badge/Clarity-2.4-orange.svg)]()

A robust, secure, and flexible smart contract solution for registering and protecting digital assets on the blockchain.

![Digital Asset Registry Banner](https://example.com/dar-banner.png)

## 📋 Table of Contents

- [Overview](#overview)
- [Key Features](#key-features)
- [Technical Architecture](#technical-architecture)
- [Smart Contract Functions](#smart-contract-functions)
- [Installation](#installation)
- [Usage Examples](#usage-examples)
- [Security Considerations](#security-considerations)
- [Performance Optimizations](#performance-optimizations)
- [Testing](#testing)
- [Deployment](#deployment)
- [Roadmap](#roadmap)
- [Contributing](#contributing)
- [Acknowledgements](#acknowledgements)
- [FAQ](#faq)

## 🔍 Overview

The Digital Asset Registry is a comprehensive Clarity smart contract designed to provide creators, developers, and businesses with a reliable and decentralized way to register, verify, and manage digital assets on the blockchain. 

This system leverages cryptographic principles to timestamp work, establish provable ownership records, manage validity periods, and facilitate secure transfers—all while maintaining an immutable record of each asset's history on the blockchain.

Whether you're an individual creator looking to protect your digital creations, a business wanting to manage digital rights, or a developer building applications that require verifiable digital asset management, the Digital Asset Registry provides the foundation you need.

## 🌟 Key Features

- **Secure Asset Registration**
  - Register assets using SHA-256 cryptographic digests
  - Immutable timestamp of registration preserved on-chain
  - Prevent unauthorized duplicates with built-in collision detection

- **Flexible Validity Management**
  - Set custom validity periods for time-limited assets
  - Extend validity periods as needed
  - Optional indefinite validity for permanent assets

- **Comprehensive Ownership Controls**
  - Secure ownership verification
  - Authorized ownership transfers
  - Clear ownership history maintained on-chain

- **Metadata Management**
  - Update asset metadata while preserving registration history
  - Track version history through digest updates

- **Advanced Security Features**
  - Robust permission checks on all operations
  - Input validation against common attack vectors
  - Time-based expiration enforcement

- **Efficiency Optimizations**
  - Optimized for minimal gas consumption
  - Streamlined data structures for fast lookups
  - Efficient batch operations where applicable

## 🏗️ Technical Architecture

The Digital Asset Registry is built on a carefully designed data architecture:

### Data Structures

1. **Asset Registrations Map**
   ```clarity
   (define-map asset-registrations
     { asset-id: uint }
     { creator: principal, creation-time: uint, digest: (buff 32), validity: (optional uint) }
   )
   ```
   Stores comprehensive details about each registered asset.

2. **Registered Digests Map**
   ```clarity
   (define-map registered-digests
     { digest: (buff 32) }
     { asset-id: uint }
   )
   ```
   Ensures uniqueness and provides fast lookups by digest.

3. **Asset Counter**
   ```clarity
   (define-data-var asset-counter uint u0)
   ```
   Maintains auto-incrementing IDs for registered assets.

### System Architecture Diagram

```
┌─────────────────────────────────────────────────────┐
│                Digital Asset Registry                │
└─────────────────┬─────────────────┬─────────────────┘
                  │                 │
┌─────────────────▼─────┐ ┌─────────▼─────────────┐
│  Asset Registration   │ │   Asset Management    │
│                       │ │                       │
│ ┌─────────────────┐   │ │ ┌─────────────────┐   │
│ │ register-asset  │   │ │ │ transfer-asset  │   │
│ └─────────────────┘   │ │ └─────────────────┘   │
│                       │ │                       │
│ ┌─────────────────┐   │ │ ┌─────────────────┐   │
│ │is-digest-       │   │ │ │update-asset-    │   │
│ │registered       │   │ │ │metadata         │   │
│ └─────────────────┘   │ │ └─────────────────┘   │
└───────────────────────┘ │                       │
                          │ ┌─────────────────┐   │
┌─────────────────────┐   │ │extend-asset-    │   │
│  Asset Verification │   │ │validity         │   │
│                     │   │ └─────────────────┘   │
│ ┌───────────────┐   │   └───────────────────────┘
│ │check-asset-   │   │
│ │ownership      │   │   ┌───────────────────────┐
│ └───────────────┘   │   │       Data Store      │
│                     │   │                       │
│ ┌───────────────┐   │   │ ┌─────────────────┐   │
│ │verify-asset-  │   │   │ │asset-           │   │
│ │digest         │   │   │ │registrations    │   │
│ └───────────────┘   │   │ └─────────────────┘   │
│                     │   │                       │
│ ┌───────────────┐   │   │ ┌─────────────────┐   │
│ │verify-asset-  │   │   │ │registered-      │   │
│ │creator        │   │   │ │digests          │   │
│ └───────────────┘   │   │ └─────────────────┘   │
└─────────────────────┘   └───────────────────────┘
```

## 📝 Smart Contract Functions

### Public Functions

#### `register-asset`
Registers a new digital asset with the system.

**Parameters:**
- `asset-digest`: 32-byte buffer containing the asset's cryptographic digest
- `validity-block` (optional): Block height when the registration expires

**Returns:**
- `(ok uint)`: The new asset ID if successful
- Error codes on failure

**Example:**
```clarity
(register-asset 0x1a2b3c4d5e6f7g8h9i0j1k2l3m4n5o6p7q8r9s0t1u2v3w4x5y6z7a8b9c0d (some u1000000))
```

#### `transfer-asset`
Transfers ownership of an asset to another principal.

**Parameters:**
- `asset-id`: ID of the asset to transfer
- `new-creator`: Principal address of the new owner

**Returns:**
- `(ok true)`: On successful transfer
- Error codes on failure

#### `extend-asset-validity`
Extends the validity period of an asset.

**Parameters:**
- `asset-id`: ID of the asset
- `new-validity`: New block height for validity expiration

**Returns:**
- `(ok true)`: On successful extension
- Error codes on failure

#### `update-asset-metadata`
Updates the digest (metadata) of a registered asset.

**Parameters:**
- `asset-id`: ID of the asset
- `new-digest`: New 32-byte buffer containing the updated asset digest

**Returns:**
- `(ok true)`: On successful update
- Error codes on failure

### Read-Only Functions

#### `check-asset-ownership`
Verifies the current owner of an asset.

**Parameters:**
- `asset-id`: ID of the asset to check

**Returns:**
- `(ok principal)`: The principal of the current owner
- Error codes on failure

#### `verify-asset-digest`
Verifies if a given digest matches the registered digest of an asset.

**Parameters:**
- `asset-id`: ID of the asset to check
- `digest-to-verify`: 32-byte buffer to compare against the registered digest

**Returns:**
- `(ok bool)`: Whether the digest matches
- Error codes on failure

#### `is-digest-registered`
Checks if a digest is already registered.

**Parameters:**
- `asset-digest`: 32-byte buffer to check

**Returns:**
- `bool`: Whether the digest is already registered

#### `verify-asset-creator`
Gets detailed information about an asset's creator and validity.

**Parameters:**
- `asset-id`: ID of the asset to verify

**Returns:**
- `(ok { creator: principal, validity: (optional uint) })`: Asset creator and validity period
- Error codes on failure

### Error Codes

| Error Code | Description |
|------------|-------------|
| `ERR-NOT-AUTHORIZED` | Caller is not authorized to perform the operation |
| `ERR-INVALID-DIGEST-LENGTH` | Digest does not have the required length |
| `ERR-DIGEST-ALL-ZEROS` | Digest contains all zeros |
| `ERR-DIGEST-ALREADY-REGISTERED` | Digest is already registered |
| `ERR-ASSET-NOT-FOUND` | Asset ID does not exist |
| `ERR-INVALID-ASSET-ID` | Asset ID is invalid |
| `ERR-ASSET-ID-OUT-OF-RANGE` | Asset ID is out of the valid range |
| `ERR-ASSET-EXPIRED` | Asset has expired and cannot be modified |
| `ERR-INVALID-VALIDITY` | Validity period is invalid |
| `ERR-NO-VALIDITY-SET` | No validity period has been set |

## 🚀 Installation

### Prerequisites

- [Clarinet](https://github.com/hirosystems/clarinet) (v2.0+)
- [Stacks CLI](https://github.com/blockstack/stacks.js)
- Node.js (v14+) for running test scripts

### Setup

1. Clone the repository:
   ```bash
   git clone https://github.com/yourusername/digital-asset-registry.git
   cd digital-asset-registry
   ```

2. Install development dependencies:
   ```bash
   npm install
   ```

3. Configure for your environment:
   ```bash
   cp .env.example .env
   # Edit .env with your specific configuration
   ```

## 🔬 Usage Examples

### Basic Asset Registration

```clarity
;; Generate a digest for your asset (you can use a SHA-256 hash of your file)
;; Register the asset with a validity period of 52,560 blocks (approximately 1 year)
(contract-call? .digital-asset-registry register-asset 
  0x1a2b3c4d5e6f7g8h9i0j1k2l3m4n5o6p7q8r9s0t1u2v3w4x5y6z7a8b9c0d 
  (some (+ block-height u52560)))
```

### Checking Asset Status

```clarity
;; Check who owns asset with ID 1
(contract-call? .digital-asset-registry check-asset-ownership u1)

;; Get full details of the asset creator and validity
(contract-call? .digital-asset-registry verify-asset-creator u1)
```

### Updating an Asset

```clarity
;; Update the asset metadata with a new digest
(contract-call? .digital-asset-registry update-asset-metadata 
  u1 
  0x0a1b2c3d4e5f6g7h8i9j0k1l2m3n4o5p6q7r8s9t0u1v2w3x4y5z6a7b8c9d)
```

### Extending Validity

```clarity
;; Extend the validity by another 52,560 blocks (approximately 1 year)
(contract-call? .digital-asset-registry extend-asset-validity 
  u1 
  (+ block-height u52560))
```

### Transferring Ownership

```clarity
;; Transfer ownership to another address
(contract-call? .digital-asset-registry transfer-asset 
  u1 
  'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM)
```

## 🔒 Security Considerations

The Digital Asset Registry is designed with security as a priority. Here are key security features:

### Authorization Controls

- All asset modification operations verify the caller is the registered creator
- Function-level permission checks prevent unauthorized access

### Input Validation

- Digest length verification prevents buffer overflow exploits
- Zero-digest check prevents trivial collision attacks
- Range validation on all numeric inputs

### Time-based Security

- Assets with expired validity periods cannot be modified
- Block height is used for secure time-based operations

### Potential Security Considerations

- **Key Management**: Protect your private keys, as they control asset ownership
- **Digest Generation**: Use strong cryptographic hashing algorithms for generating digests
- **Transaction Security**: Sign transactions securely to prevent man-in-the-middle attacks

## ⚡ Performance Optimizations

The contract has been optimized for efficient on-chain execution:

- **Minimal Storage**: Data structures use only necessary fields
- **Efficient Lookups**: Dual mapping approach provides O(1) lookup for both ID and digest-based queries
- **Gas Optimization**: Functions minimize loop usage and unnecessary operations
- **Memory Efficiency**: Buffer operations are optimized to minimize memory usage

## 🧪 Testing

Comprehensive tests are included to verify contract functionality.

### Running Tests

```bash
# Run all tests
clarinet test

# Run specific test file
clarinet test tests/asset-registration.test.ts
```

### Test Coverage

The test suite covers:

- ✅ Basic asset registration
- ✅ Duplicate prevention
- ✅ Ownership verification
- ✅ Validity period enforcement
- ✅ Transfer operations
- ✅ Update operations
- ✅ Error conditions
- ✅ Edge cases

## 📦 Deployment

### Testnet Deployment

1. Configure your Stacks testnet credentials:
   ```bash
   # Set your testnet deployment credentials
   export STACKS_PRIVATE_KEY=your_private_key
   ```

2. Deploy to testnet:
   ```bash
   clarinet deploy --testnet
   ```

### Mainnet Deployment

1. Prepare for production:
   ```bash
   # Review the contract for any final adjustments
   clarinet check
   ```

2. Deploy to mainnet (after thorough testing):
   ```bash
   clarinet deploy --mainnet
   ```

## 🛣️ Roadmap

- **Q2 2025**: Add batch registration capabilities for multiple assets
- **Q3 2025**: Implement fractional ownership model
- **Q4 2025**: Add royalty tracking and enforcement
- **Q1 2026**: Develop bridge to other blockchain ecosystems
- **Q2 2026**: Create marketplace integration layer

## 👥 Contributing

We welcome contributions from the community! Please follow these steps:

1. Fork the repository
2. Create a feature branch: `git checkout -b feature-name`
3. Commit your changes: `git commit -am 'Add feature'`
4. Push to the branch: `git push origin feature-name`
5. Submit a pull request

Please read [CONTRIBUTING.md](CONTRIBUTING.md) for detailed guidelines.

### Code Style

We follow the Clarity Best Practices. Run `clarinet check` before submitting PRs.


## 🙏 Acknowledgements

- Thanks to the Stacks Foundation for their support
- Inspired by the work of [Digital Asset Standards Working Group](https://example.com)
- Special thanks to all contributors and community members



## ❓ FAQ

### How is this different from NFTs?

While NFTs typically represent ownership of a specific item, the Digital Asset Registry provides a more flexible framework for registering various types of digital assets with advanced features like time-limited validity, metadata updates, and verification capabilities.

### Can I register any type of digital asset?

Yes, the registry accepts any digital content that can be represented as a cryptographic digest. This includes code, documents, images, videos, and more.

### How do I generate a digest for my asset?

You can use any SHA-256 hashing algorithm to generate a digest of your digital asset. For example:

```bash
# Using OpenSSL
openssl dgst -sha256 myfile.pdf

# Using Node.js
node -e "console.log(require('crypto').createHash('sha256').update('your content').digest('hex'))"
```

### Is my registered asset publicly visible?

The digest and ownership information are visible on the blockchain, but the actual content of your asset is not stored on-chain. Only the cryptographic reference is registered.

### What happens when an asset expires?

When an asset reaches its validity expiration block height, operations on that asset will be rejected with an `ERR-ASSET-EXPIRED` error. The creator can extend the validity period before expiration.

### Can I make my registration permanent?

Yes, by omitting the optional validity parameter when registering an asset, the registration will not have an expiration date.