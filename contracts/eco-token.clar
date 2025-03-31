
;; title: eco-token
;; version:
;; summary:
;; description:This initiative combines blockchain technology with philanthropy to combat pediatric cancer, particularly neuroblastoma. Developed by a team experienced in web3 charities, its mission is to enhance research, improve access to advanced treatments, and provide emotional support to affected families. The token operates within a comprehensive crypto ecosystem to ensure that technological advancements directly benefit those in need

(define-fungible-token eco-token)

(define-data-var admin principal 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM')  ; Admin wallet
(define-data-var charity-wallet principal 'ST1SJ3DTE5DN7X54YDH5D64R3BCB6A2AG2ZQ8YPD5')  ; Wallet for donations

(define-map balances {owner: principal} {balance: uint})
(define-map votes {proposal: (buff 50)} {votes: uint})  ; Track votes for fund allocation

;; Minting tokens (only admin)
(define-public (mint (recipient principal) (amount uint))
    (begin
        (asserts! (is-eq tx-sender (var-get admin)) (err "Only admin can mint"))
        (map-set balances {owner: recipient} {balance: amount})
        (ok amount)))

;; Transfer tokens
(define-public (transfer (amount uint) (to principal))
    (let ((sender-balance (unwrap! (map-get? balances {owner: tx-sender}) {balance: 0})))
        (begin
            (asserts! (>= sender-balance amount) (err "Insufficient balance"))
            (map-set balances {owner: tx-sender} {balance: (- sender-balance amount)})
            (map-set balances {owner: to} {balance: (+ (unwrap! (map-get? balances {owner: to}) {balance: 0}) amount)})
            (ok amount))))

            ;; Get balance
(define-read-only (get-balance (who principal))
    (unwrap! (map-get? balances {owner: who}) {balance: 0}))

;; Donate tokens to the charity wallet
(define-public (donate (amount uint))
    (let ((sender-balance (unwrap! (map-get? balances {owner: tx-sender}) {balance: 0})))
        (begin
            (asserts! (>= sender-balance amount) (err "Insufficient balance"))
            (map-set balances {owner: tx-sender} {balance: (- sender-balance amount)})
            (map-set balances {owner: (var-get charity-wallet)} {balance: (+ (unwrap! (map-get? balances {owner: (var-get charity-wallet)}) {balance: 0}) amount)})
            (ok amount))))

;; Allocate funds to hospitals/research centers (only admin)
(define-public (allocate-funds (recipient principal) (amount uint))
    (let ((charity-balance (unwrap! (map-get? balances {owner: (var-get charity-wallet)}) {balance: 0})))
        (begin
            (asserts! (is-eq tx-sender (var-get admin)) (err "Only admin can allocate"))
            (asserts! (>= charity-balance amount) (err "Insufficient funds in charity wallet"))
            (map-set balances {owner: (var-get charity-wallet)} {balance: (- charity-balance amount)})
            (map-set balances {owner: recipient} {balance: (+ (unwrap! (map-get? balances {owner: recipient}) {balance: 0}) amount)})
            (ok amount))))

;; Governance - Token holders can vote on fund allocation
(define-public (vote (proposal (buff 50)) (vote-weight uint))
    (let ((sender-balance (unwrap! (map-get? balances {owner: tx-sender}) {balance: 0})))
        (begin
            (asserts! (>= sender-balance vote-weight) (err "Not enough tokens to vote"))
            (map-set votes {proposal: proposal} {votes: (+ (unwrap! (map-get? votes {proposal: proposal}) {votes: 0}) vote-weight)})
            (ok vote-weight))))

;; Get total votes for a proposal
(define-read-only (get-votes (proposal (buff 50)))
    (unwrap! (map-get? votes {proposal: proposal}) {votes: 0}))

