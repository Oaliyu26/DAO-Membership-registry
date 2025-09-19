;; ------------------------------------------------------------
;; Membership Registry with Governance (Refined Skeleton)
;; ------------------------------------------------------------

;; -------------------
;; State Variables
;; -------------------

(define-data-var membership-fee uint u1000000)   ;; 1 STX = 1_000_000 microSTX
(define-data-var admin principal tx-sender)      ;; contract deployer is admin

;; Members map: each member has a role and join height
(define-map members 
  {user: principal} 
  {role: (string-ascii 12), joined: uint}
)

;; -------------------
;; Read-Only Helpers
;; -------------------

(define-read-only (is-admin (user principal))
  (is-eq user (var-get admin))
)

(define-read-only (is-member (user principal))
  (is-some (map-get? members {user: user}))
)

(define-read-only (get-member-role (user principal))
  (match (map-get? members {user: user})
    entry (get role entry)
    "none"
  )
)

(define-read-only (get-fee) (var-get membership-fee))
(define-read-only (get-admin) (var-get admin))
(define-read-only (get-member-info (user principal))
  (map-get? members {user: user})
)

;; -------------------
;; Membership Functions
;; -------------------

(define-public (join)
  (begin
    ;; Must not already be a member
    (asserts! (not (is-member tx-sender)) (err u100))

    ;; Must transfer exact fee into contract
    (asserts! 
      (is-eq (stx-transfer? (var-get membership-fee) tx-sender (as-contract tx-sender)) (ok true)) 
      (err u101)
    )

    ;; Register new member
    (map-set members 
      {user: tx-sender} 
      {role: "member", joined: u0} ;; Temporarily set joined to 0 for debugging
    )
    (ok "joined successfully")
  )
)

(define-public (leave)
  (begin
    (asserts! (is-member tx-sender) (err u102))
    (map-delete members {user: tx-sender})
    (ok "left successfully")
  )
)

;; -------------------
;; Admin Functions
;; -------------------

(define-public (set-fee (new-fee uint))
  (begin
    (asserts! (is-admin tx-sender) (err u200))
    (var-set membership-fee new-fee)
    (ok new-fee)
  )
)

(define-public (promote (user principal) (new-role (string-ascii 12)))
  (begin
    (asserts! (is-admin tx-sender) (err u201))
    (asserts! (is-member user) (err u202))
    (let ((current-member (unwrap! (map-get? members {user: user}) (err u203)))) ;; Ensure data is checked
      (map-set members 
        {user: user} 
        {role: new-role, joined: (get joined current-member)}
      )
    )
    (ok "promoted")
  )
)

(define-public (revoke (user principal))
  (begin
    (asserts! (is-admin tx-sender) (err u203))
    (map-delete members {user: user})
    (ok "revoked membership")
  )
)

;; -------------------
;; Treasury Helpers (Future Expansion)
;; -------------------

(define-read-only (get-contract-balance)
  (stx-get-balance (as-contract tx-sender))
)

;; Admin-only withdrawal (could later be replaced by DAO voting)
(define-public (withdraw (amount uint) (recipient principal))
  (begin
    (asserts! (is-admin tx-sender) (err u300))
    (asserts! (<= amount (stx-get-balance (as-contract tx-sender))) (err u301))
    (asserts! (is-eq (stx-transfer? amount (as-contract tx-sender) recipient) (ok true)) (err u302))
    (ok amount)
  )
)
