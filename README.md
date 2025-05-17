# BTCSecure: Bitcoin-Backed Lending Protocol

![Stacks Badge](https://img.shields.io/badge/Stacks-L2-blue)

A decentralized lending protocol enabling Bitcoin-collateralized loans on the Stacks Layer 2 blockchain. Secure your digital assets while accessing liquidity.

## Overview

BTCSecure revolutionizes decentralized finance by enabling Bitcoin holders to:
- **Secure Loans**: Borrow stablecoins against BTC collateral
- **Maintain Ownership**: Retain BTC exposure while accessing liquidity
- **Benefit from Security**: Leverage Bitcoin's security through Stacks L2

## Key Features

🛡️ **Bitcoin-Centric Design**
- Native BTC collateralization
- Stacks blockchain settlement
- Bitcoin-finalized transactions

📈 **Dynamic Financial Mechanics**
- Risk-adjusted interest rates
- Protocol-managed liquidations
- Collateral health monitoring

🔐 **Institutional-Grade Security**
- Non-custodial architecture
- Time-locked oracle updates
- Multi-layered safety mechanisms

## Architecture Overview

```mermaid
graph TD
    A[User] -->|Lock BTC| B[Stacks L2]
    B --> C[BTCSecure Protocol]
    C --> D[Vault Manager]
    C --> E[Risk Engine]
    C --> F[Liquidation Bot]
    D --> G[Collateral Tracking]
    E --> H[Price Oracle]
    F --> I[Auto-Liquidation]
    H -->|Price Feed| J[External APIs]
    C -->|Settlement| K[Bitcoin L1]
```

### Core Components

1. **Vault Management**
   - Collateral-to-debt ratio tracking
   - Interest accrual system
   - Multi-asset support

2. **Risk Engine**
   - Real-time collateral valuation
   - Liquidation threshold enforcement
   - Protocol-wide risk monitoring

3. **Oracle System**
   - Decentralized price feeds
   - Validity time windows
   - Emergency price freeze

4. **Liquidation Module**
   - Penalty-based liquidations
   - Partial position closure
   - Incentivized liquidation bots

## Workflow Diagrams

### Loan Lifecycle

```mermaid
sequenceDiagram
    participant User
    participant Vault
    participant Oracle
    participant Reserve
    
    User->>Vault: Deposit BTC
    Oracle->>Vault: Update Price
    User->>Vault: Borrow Stablecoins
    Vault->>Reserve: Lock Collateral
    loop Daily
        Vault->>Vault: Accrue Interest
    end
    User->>Vault: Repay Loan
    Vault->>User: Release Collateral
```

### Liquidation Process

```mermaid
graph TD
    A[Collateral Value] --> B{Below Threshold?}
    B -->|Yes| C[Flag Position]
    C --> D[Calculate Shortfall]
    D --> E[Liquidate Collateral]
    E --> F[Apply Penalty]
    F --> G[Update Reserves]
    B -->|No| H[Monitor Position]
```

## Security Model

### Protection Layers
1. **Collateral Buffers**
   - 150% minimum ratio
   - 125% liquidation threshold

2. **Protocol Safeguards**
   - Emergency pause functionality
   - Governance-controlled parameters
   - Time-locked admin actions

3. **Financial Controls**
   - Interest rate ceilings
   - Liquidation penalty floors
   - Protocol reserve requirements

## Development Setup

### Requirements
- Clarinet 2.0+
- Node.js 18.x
- Bitcoin testnet node
- Stacks testnet access

### Installation
```bash
git clone https://github.com/philip-hue/BTCSecure.git
cd BTCSecure
clarinet check
npm install
```

### Testing Suite
```bash
# Run unit tests
clarinet test --watch

# Start local network
clarinet integrate

# Deploy to testnet
clarinet deploy --testnet
```

## Governance & DAO

BTCSecure features a progressive decentralization roadmap:
1. **Phase 1**: Admin-controlled parameters
2. **Phase 2**: Time-locked governance
3. **Phase 3**: Full DAO control

Governance token holders will eventually control:
- Risk parameters
- Fee structures
- Protocol upgrades
- Treasury management
