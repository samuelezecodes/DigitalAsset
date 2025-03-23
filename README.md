# Digital Asset Registry

A secure and flexible smart contract solution for registering and protecting digital assets on the blockchain.

## Overview

The Digital Asset Registry is a Clarity smart contract designed to provide creators with a reliable way to register, verify, and manage their digital assets. Built with security and flexibility in mind, this system allows creators to timestamp their work, set validity periods, update metadata, and transfer ownership securely.

## Features

- **Secure Asset Registration**: Register assets with cryptographic digests to prove authenticity
- **Validity Period Management**: Set and extend time-limited validity periods for registered assets
- **Ownership Verification**: Easily verify the current owner of any registered asset
- **Metadata Updates**: Update asset information while maintaining registration history
- **Ownership Transfer**: Securely transfer asset ownership to other principals
- **Duplicate Prevention**: Built-in protection against duplicate asset registration

## Technical Details

The Digital Asset Registry operates through a series of public and read-only functions that interact with two main data structures:

1. **Asset Registrations Map**: Stores all registered assets with associated metadata
2. **Registered Digests Map**: Tracks registered asset digests to prevent duplicates

## Functions

### Public Functions

- `register-asset`: Register a new digital asset with an optional validity period
- `transfer-asset`: Transfer ownership of an asset to another principal
- `extend-asset-validity`: Extend the validity period of a registered asset
- `update-asset-metadata`: Update the digest (metadata) of a registered asset

### Read-Only Functions

- `check-asset-ownership`: Verify the ownership of a specific asset
- `verify-asset-digest`: Check if a provided digest matches a registered asset
- `is-digest-registered`: Check if a digest is already registered
- `verify-asset-creator`: Get detailed information about an asset's creator and validity

## Error Handling

The contract includes robust error handling with specific error codes for different scenarios:

- Authorization errors
- Input validation errors
- Registration status errors
- Expiration errors

## Getting Started

### Prerequisites

- A Stacks blockchain wallet
- Basic understanding of blockchain transactions

### Usage Examples

#### Registering a New Asset

```clarity
(contract-call? .digital-asset-registry register-asset 
  0x1a2b3c4d5e6f7g8h9i0j1k2l3m4n5o6p7q8r9s0t1u2v3w4x5y6z7a8b9c0d 
  (some u1000000))
```

#### Verifying Asset Ownership

```clarity
(contract-call? .digital-asset-registry check-asset-ownership u1)
```

#### Transferring Asset Ownership

```clarity
(contract-call? .digital-asset-registry transfer-asset u1 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM)
```

## Security Considerations

- All asset operations verify the caller is the registered creator
- Assets with expired validity periods cannot be modified
- Input validation prevents various attack vectors

