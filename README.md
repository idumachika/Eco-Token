# ECO Token - Blockchain Philanthropy

## Overview
**ECO Token** is a blockchain-powered initiative aimed at merging technology with philanthropy to combat pediatric cancer, particularly neuroblastoma. Developed by an experienced team in Web3 charities, this project enhances research, improves access to advanced treatments, and provides emotional support to affected families.

## Features
- **Token Minting**: Only an admin can mint new tokens.
- **Secure Transactions**: Users can transfer tokens securely.
- **Charitable Donations**: Token holders can donate to a designated charity wallet.
- **Fund Allocation**: Admins can allocate funds to hospitals and research centers.
- **Decentralized Governance**: Token holders can vote on fund distribution.

## Smart Contract Details
The smart contract is built using the **Clarity** language and includes the following components:

### **Token Definition**
```clarity
(define-fungible-token eco-token)
```

### **Data Variables**
```clarity
(define-data-var admin principal 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM')  ; Admin wallet
(define-data-var charity-wallet principal 'ST1SJ3DTE5DN7X54YDH5D64R3BCB6A2AG2ZQ8YPD5')  ; Wallet for donations
```

### **Functions**
#### **Mint Tokens (Admin Only)**
```clarity
(define-public (mint (recipient principal) (amount uint))
    (begin
        (asserts! (is-eq tx-sender (var-get admin)) (err "Only admin can mint"))
        (map-set balances {owner: recipient} {balance: amount})
        (ok amount)))
```
#### **Transfer Tokens**
```clarity
(define-public (transfer (amount uint) (to principal))
    (let ((sender-balance (unwrap! (map-get? balances {owner: tx-sender}) {balance: 0})))
        (begin
            (asserts! (>= sender-balance amount) (err "Insufficient balance"))
            (map-set balances {owner: tx-sender} {balance: (- sender-balance amount)})
            (map-set balances {owner: to} {balance: (+ (unwrap! (map-get? balances {owner: to}) {balance: 0}) amount)})
            (ok amount))))
```
#### **Donate to Charity Wallet**
```clarity
(define-public (donate (amount uint))
    (let ((sender-balance (unwrap! (map-get? balances {owner: tx-sender}) {balance: 0})))
        (begin
            (asserts! (>= sender-balance amount) (err "Insufficient balance"))
            (map-set balances {owner: tx-sender} {balance: (- sender-balance amount)})
            (map-set balances {owner: (var-get charity-wallet)} {balance: (+ (unwrap! (map-get? balances {owner: (var-get charity-wallet)}) {balance: 0}) amount)})
            (ok amount))))
```
#### **Vote on Fund Allocation**
```clarity
(define-public (vote (proposal (buff 50)) (vote-weight uint))
    (let ((sender-balance (unwrap! (map-get? balances {owner: tx-sender}) {balance: 0})))
        (begin
            (asserts! (>= sender-balance vote-weight) (err "Not enough tokens to vote"))
            (map-set votes {proposal: proposal} {votes: (+ (unwrap! (map-get? votes {proposal: proposal}) {votes: 0}) vote-weight)})
            (ok vote-weight))))
```

## Installation
1. **Clone the repository**:
   ```sh
   git clone https://github.com/idumachika/Eco-Token
   ```
2. **Navigate to the project directory**:
   ```sh
   cd eco-token
   ```
3. **Install dependencies** (if applicable):
   ```sh
   npm install  # or yarn install
   ```
4. **Deploy the contract using Clarinet**:
   ```sh
   clarinet check
   clarinet test
   ```

## License
This project is licensed under the **MIT License**. See the `LICENSE` file for details.

## Contributors
- **Your Name** (GitHub: [@yourusername](https://github.com/idumachika))

## Contact
For any inquiries, reach out via email: `idumachika@gmail.com` or open an issue on GitHub.

---
**ECO Token: Empowering Philanthropy Through Blockchain.** 🚀