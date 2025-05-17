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

;; Protocol Statistics

;; Total collateral held by the protocol (in satoshis)
(define-data-var total-collateral uint u0)

;; Total amount borrowed from the protocol (in USD cents)
(define-data-var total-borrowed uint u0)

;; Total fees collected by the protocol (in USD cents)
(define-data-var total-fees-collected uint u0)

;; Governance Token

;; Governance token balances by user
(define-map governance-token-balances
  { owner: principal }
  { balance: uint }
)

;; Authorization Functions

;; Check if caller is the contract owner
(define-private (is-contract-owner)
  (is-eq tx-sender (var-get contract-owner))
)

;; Check if caller is an authorized oracle provider
(define-private (is-authorized-oracle)
  ;; In production, would check against a whitelist
  (is-eq tx-sender (var-get contract-owner))
)

;; Check if the protocol is currently paused
(define-private (assert-not-paused)
  (ok (asserts! (not (var-get protocol-paused)) ERR_PROTOCOL_PAUSED))
)

;; Math Helpers

;; Safely perform multiplication and division: (a * b) / c
(define-private (mul-div (a uint) (b uint) (c uint))
  (begin
    (asserts! (> c u0) ERR_INVALID_AMOUNT)
    (ok (/ (* a b) c))
  )
)

;; Oracle Functions

;; Update the BTC price from an authorized oracle
(define-public (update-btc-price (new-price uint))
  (begin
    (asserts! (is-authorized-oracle) ERR_UNAUTHORIZED)
    (asserts! (> new-price u0) ERR_INVALID_AMOUNT)
    (asserts! (< new-price u10000000000) ERR_INVALID_AMOUNT) ;; $100,000 ceiling
    (var-set btc-price-in-usd new-price)
    (var-set btc-price-last-updated stacks-block-height)
    (ok new-price)
  )
)

;; Get the current BTC price, checking for validity
(define-private (get-btc-price)
  (let ((current-price (var-get btc-price-in-usd))
        (last-updated (var-get btc-price-last-updated)))
    (if (or (is-eq current-price u0) 
            (> (- stacks-block-height last-updated) (var-get oracle-price-validity-period)))
      ERR_ORACLE_ERROR
      (ok current-price)
    )
  )
)

;; Administrative Functions

;; Change contract ownership
(define-public (set-contract-owner (new-owner principal))
  (begin
    (asserts! (is-contract-owner) ERR_UNAUTHORIZED)
    (asserts! (not (is-eq new-owner 'SP000000000000000000002Q6VF78)) ERR_INVALID_AMOUNT)
    (var-set contract-owner new-owner)
    (ok new-owner)
  )
)

;; Update minimum collateral ratio requirement
(define-public (set-minimum-collateral-ratio (new-ratio uint))
  (begin
    (asserts! (is-contract-owner) ERR_UNAUTHORIZED)
    (asserts! (>= new-ratio (var-get liquidation-threshold)) ERR_INVALID_AMOUNT)
    (var-set minimum-collateral-ratio new-ratio)
    (ok new-ratio)
  )
)

;; Update liquidation threshold
(define-public (set-liquidation-threshold (new-threshold uint))
  (begin
    (asserts! (is-contract-owner) ERR_UNAUTHORIZED)
    (asserts! (<= new-threshold (var-get minimum-collateral-ratio)) ERR_INVALID_AMOUNT)
    (var-set liquidation-threshold new-threshold)
    (ok new-threshold)
  )
)

;; Update liquidation penalty percentage
(define-public (set-liquidation-penalty (new-penalty uint))
  (begin
    (asserts! (is-contract-owner) ERR_UNAUTHORIZED)
    (asserts! (<= new-penalty u50) ERR_INVALID_AMOUNT) ;; Maximum 50% penalty
    (var-set liquidation-penalty new-penalty)
    (ok new-penalty)
  )
)

;; Update interest rate
(define-public (set-interest-rate (new-rate uint))
  (begin
    (asserts! (is-contract-owner) ERR_UNAUTHORIZED)
    (asserts! (<= new-rate u50) ERR_INVALID_AMOUNT) ;; Maximum 50% interest rate
    (var-set borrow-interest-rate new-rate)
    (ok new-rate)
  )
)

;; Update protocol fee percentage
(define-public (set-protocol-fee (new-fee uint))
  (begin
    (asserts! (is-contract-owner) ERR_UNAUTHORIZED)
    (asserts! (<= new-fee u50) ERR_INVALID_AMOUNT) ;; Maximum 50% fee
    (var-set protocol-fee-rate new-fee)
    (ok new-fee)
  )
)

;; Emergency protocol pause toggle
(define-public (toggle-protocol-pause)
  (begin
    (asserts! (is-contract-owner) ERR_UNAUTHORIZED)
    (var-set protocol-paused (not (var-get protocol-paused)))
    (ok (var-get protocol-paused))
  )
)

;; Core Lending Functions

;; Deposit BTC collateral
(define-public (deposit-collateral (btc-amount uint))
  (let ((user tx-sender)
        (vault-data (map-get? vaults { owner: user })))
    (begin
      (try! (assert-not-paused))
      (asserts! (> btc-amount u0) ERR_INVALID_AMOUNT)
      
      ;; Create or update vault
      (if (is-some vault-data)
        (let ((existing-vault (unwrap-panic vault-data)))
          (map-set vaults 
            { owner: user }
            {
              collateral-amount: (+ (get collateral-amount existing-vault) btc-amount),
              borrowed-amount: (get borrowed-amount existing-vault),
              interest-accumulated: (get interest-accumulated existing-vault),
              last-interest-update: (get last-interest-update existing-vault)
            }
          )
        )
        (map-set vaults 
          { owner: user }
          {
            collateral-amount: btc-amount,
            borrowed-amount: u0,
            interest-accumulated: u0,
            last-interest-update: stacks-block-height
          }
        )
      )
      
      ;; Update total collateral
      (var-set total-collateral (+ (var-get total-collateral) btc-amount))
      
      (ok btc-amount)
    )
  )
)

;; Calculate the USD value of BTC collateral
(define-private (calculate-collateral-value (btc-amount uint))
  (let ((btc-price (get-btc-price)))
    (if (is-err btc-price)
      btc-price
      (mul-div btc-amount (unwrap-panic btc-price) u100000000)
    )
  )
)

;; Calculate maximum borrowable amount based on collateral
(define-private (calculate-max-borrow-amount (collateral-amount uint))
  (let ((collateral-value-result (calculate-collateral-value collateral-amount)))
    (if (is-err collateral-value-result)
      collateral-value-result
      (let ((collateral-value (unwrap-panic collateral-value-result)))
        (mul-div collateral-value u100 (var-get minimum-collateral-ratio))
      )
    )
  )
)

;; Calculate interest for a given period
(define-private (calculate-interest (borrowed-amount uint) (blocks-passed uint))
  (let ((interest-per-block (/ (var-get borrow-interest-rate) u52560)))
    (unwrap-panic (mul-div borrowed-amount interest-per-block blocks-passed))
  )
)