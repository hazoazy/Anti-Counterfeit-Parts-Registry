# 🛡️ Anti-Counterfeit Parts Registry

A blockchain-based smart contract system for tracking and verifying the authenticity of critical machine parts in aviation and automotive manufacturing. This system ensures counterfeit parts cannot enter the supply chain by providing each part with a unique, immutable blockchain identity.

## 🔧 Features

### 🏭 Manufacturer Management
- **Verified Manufacturer Registration**: Only authorized manufacturers can register parts
- **Certification Levels**: Track different levels of manufacturer certification
- **Manufacturing Statistics**: Monitor total parts produced per manufacturer

### 📦 Parts Registration & Tracking
- **Unique Part Identity**: Each part gets a blockchain-based unique ID
- **Serial Number Mapping**: Direct lookup of parts by serial number
- **Manufacturing Details**: Track production date, batch number, and part type
- **Ownership Transfer**: Secure transfer of parts between entities
- **Metadata Storage**: Additional part information and specifications

### ✅ Authentication & Verification
- **Authenticity Verification**: Multi-step verification process for parts
- **Counterfeit Reporting**: Flag and mark counterfeit parts in the system
- **Verification History**: Track verification count and timestamps
- **Chain Validation**: Complete supply chain validation

### 📊 Analytics & Reporting
- **Contract Statistics**: Total parts and manufacturers in the system
- **Part History**: Complete lifecycle tracking of individual parts
- **Batch Operations**: Verify multiple parts simultaneously

## 🚀 Getting Started

### Prerequisites
- Clarinet CLI installed
- Stacks wallet for transactions

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd Anti-Counterfeit-Parts-Registry
   ```

2. **Check contract syntax**
   ```bash
   clarinet check
   ```

3. **Deploy to testnet**
   ```bash
   clarinet console
   ```

## 📋 Usage Examples

### Register a Manufacturer
```clarity
(contract-call? .Anti-Counterfeit-Parts-Registry register-manufacturer "AviationParts Inc" u3)
```

### Register a New Part
```clarity
(contract-call? .Anti-Counterfeit-Parts-Registry register-part 
    "AP-2024-001234" 
    "Turbine Blade" 
    "BATCH-A-2024" 
    "High-grade titanium alloy")
```

### Verify Part Authenticity
```clarity
(contract-call? .Anti-Counterfeit-Parts-Registry verify-part-authenticity u1)
```

### Transfer Part Ownership
```clarity
(contract-call? .Anti-Counterfeit-Parts-Registry transfer-part u1 'SP2J6ZY48GV1EZ5V2V5RB9MP66SW86PYKKNRV9EJ7)
```

### Check Part Information
```clarity
(contract-call? .Anti-Counterfeit-Parts-Registry get-part-info u1)
```

## 📖 Smart Contract Functions

### 📝 Public Functions

| Function | Purpose | Access |
|----------|---------|---------|
| `register-manufacturer` | Register a new verified manufacturer | Contract Owner |
| `register-part` | Add a new part to the registry | Verified Manufacturers |
| `transfer-part` | Transfer part ownership | Current Owner |
| `verify-part-authenticity` | Verify a part's authenticity | Public |
| `report-counterfeit` | Mark part as counterfeit | Contract Owner |
| `batch-verify-parts` | Verify multiple parts | Contract Owner |

### 🔍 Read-Only Functions

| Function | Purpose |
|----------|---------|
| `get-part-info` | Get complete part information |
| `get-part-by-serial` | Find part by serial number |
| `is-part-authentic` | Check if part is authentic |
| `get-manufacturer-info` | Get manufacturer details |
| `get-contract-stats` | Get system statistics |
| `validate-part-chain` | Validate entire supply chain |

## 🏗️ Contract Architecture

### Data Structures

- **Parts Map**: Stores complete part information including serial numbers, manufacturing details, and ownership
- **Manufacturers Map**: Tracks verified manufacturers and their certification levels
- **Serial Mapping**: Enables quick part lookup by serial number
- **Ownership Tracking**: Maintains current ownership records

### Security Features

- ✅ **Access Control**: Role-based permissions for different operations
- ✅ **Duplicate Prevention**: Ensures no duplicate serial numbers
- ✅ **Authenticity Validation**: Multi-layer verification system
- ✅ **Immutable Records**: Blockchain-based permanent record keeping

## 🛠️ Error Codes

| Code | Error | Description |
|------|--------|-------------|
| u100 | `ERR_UNAUTHORIZED` | Caller lacks required permissions |
| u101 | `ERR_PART_NOT_FOUND` | Part ID does not exist |
| u102 | `ERR_PART_ALREADY_EXISTS` | Part with serial already registered |
| u103 | `ERR_INVALID_MANUFACTURER` | Manufacturer not verified |
| u104 | `ERR_PART_NOT_AUTHENTIC` | Part marked as counterfeit |
| u105 | `ERR_INVALID_SERIAL` | Invalid serial number format |

## 🎯 Use Cases

### ✈️ Aviation Industry
- **Engine Components**: Track critical engine parts with full provenance
- **Safety Systems**: Ensure authentic parts in life-critical systems
- **Maintenance Records**: Complete part lifecycle tracking

### 🚗 Automotive Manufacturing
- **Safety Parts**: Verify authenticity of brake systems, airbags
- **Performance Components**: Track high-performance engine parts
- **Recall Management**: Quick identification of affected parts

### 🏭 Industrial Equipment
- **Heavy Machinery**: Track critical components in manufacturing equipment
- **Medical Devices**: Ensure authentic parts in life-support systems
- **Defense Systems**: Secure supply chain for sensitive equipment

## 🔄 Development Workflow

1. **Part Registration**: Manufacturer registers new parts with unique identifiers
2. **Supply Chain**: Parts move through verified entities with ownership transfers
3. **Verification**: Regular authenticity checks throughout the lifecycle
4. **Monitoring**: Continuous tracking and reporting of system status

## 📊 Benefits

- 🔒 **Enhanced Security**: Blockchain immutability prevents tampering
- 📈 **Supply Chain Transparency**: Complete visibility into part provenance  
- ⚡ **Quick Verification**: Instant authenticity checking via serial lookup
- 📱 **Easy Integration**: Simple API for existing manufacturing systems
- 💰 **Cost Reduction**: Reduced losses from counterfeit parts

## 🤝 Contributing

Contributions are welcome! Please ensure all contracts pass `clarinet check` before submitting.

## 📄 License

This project is licensed under the MIT License.
