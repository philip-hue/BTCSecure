;; BTCSecure: Bitcoin-Backed Lending Protocol for Stacks Blockchain
;; 
;; A decentralized lending protocol enabling Bitcoin collateralized loans
;; on Stacks Layer 2. Users can lock Bitcoin as collateral to borrow
;; stablecoins with dynamic interest rates, flexible repayment options,
;; and protocol-protected liquidation mechanisms.
;;

;; Error Codes

(define-constant ERR_UNAUTHORIZED (err u1000))
(define-constant ERR_INSUFFICIENT_COLLATERAL (err u1001))
(define-constant ERR_BORROW_LIMIT_EXCEEDED (err u1002))
(define-constant ERR_INSUFFICIENT_LIQUIDITY (err u1003))
(define-constant ERR_VAULT_ALREADY_EXISTS (err u1004))
(define-constant ERR_VAULT_NOT_FOUND (err u1005))
(define-constant ERR_INSUFFICIENT_DEPOSIT (err u1006))
(define-constant ERR_INSUFFICIENT_REPAYMENT (err u1007))
(define-constant ERR_INVALID_AMOUNT (err u1008))
(define-constant ERR_MINIMUM_COLLATERAL_RATIO (err u1009))
(define-constant ERR_VAULT_NOT_UNDERCOLLATERALIZED (err u1010))
(define-constant ERR_ORACLE_ERROR (err u1011))
(define-constant ERR_PROTOCOL_PAUSED (err u1012))

;; Protocol Configuration

;; Minimum collateral ratio (150%)
(define-data-var minimum-collateral-ratio uint u150)

;; Threshold at which a vault can be liquidated (125%)
(define-data-var liquidation-threshold uint u125)

;; Penalty applied during liquidation (10%)
(define-data-var liquidation-penalty uint u10)

;; Annual interest rate applied to borrowed amounts (5%)
(define-data-var borrow-interest-rate uint u5)

;; Protocol fee taken from interest (1%)
(define-data-var protocol-fee-rate uint u1)

;; Validity period for oracle price data in seconds (1 hour)
(define-data-var oracle-price-validity-period uint u3600)

;; Emergency protocol pause flag
(define-data-var protocol-paused bool false)

;; Administration

;; Protocol owner with administrative privileges
(define-data-var contract-owner principal tx-sender)

;; Oracle Data

;; Current BTC price in USD (scaled by 10^8)
(define-data-var btc-price-in-usd uint u0)

;; Last update timestamp for BTC price
(define-data-var btc-price-last-updated uint u0)

;; State Storage

;; Vault data for each user
(define-map vaults
  { owner: principal }
  {
    collateral-amount: uint,      ;; Amount in satoshis
    borrowed-amount: uint,        ;; Amount in USD cents
    interest-accumulated: uint,   ;; Accumulated interest in USD cents
    last-interest-update: uint    ;; Block height of last interest calculation
  }
)

;; Protocol reserve balances by asset
(define-map protocol-reserves
  { asset: (string-ascii 10) }
  { amount: uint }
)