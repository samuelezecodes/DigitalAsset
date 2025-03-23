;; Digital Asset Registry with Validity Period, Security Verification, Asset Update Capability, Creator Verification, and Optimized Validity Extension
;; Define error codes
(define-constant ERR-NOT-AUTHORIZED (err u1000))
(define-constant ERR-INVALID-DIGEST-LENGTH (err u1001))
(define-constant ERR-DIGEST-ALL-ZEROS (err u1002))
(define-constant ERR-DIGEST-ALREADY-REGISTERED (err u1003))
(define-constant ERR-ASSET-NOT-FOUND (err u1004))
(define-constant ERR-INVALID-ASSET-ID (err u1005))
(define-constant ERR-ASSET-ID-OUT-OF-RANGE (err u1006))
(define-constant ERR-ASSET-EXPIRED (err u1007))
(define-constant ERR-INVALID-VALIDITY (err u1008))
(define-constant ERR-NO-VALIDITY-SET (err u1009))

;; Define the contract
(define-data-var admin principal tx-sender)

;; Define a map to store asset registrations
(define-map asset-registrations
  { asset-id: uint }
  { creator: principal, creation-time: uint, digest: (buff 32), validity: (optional uint) }
)

;; Define a map to track registered digests
(define-map registered-digests
  { digest: (buff 32) }
  { asset-id: uint }
)

;; Define a counter for asset IDs
(define-data-var asset-counter uint u0)

;; Function to register new asset
(define-public (register-asset (asset-digest (buff 32)) (validity-block (optional uint)))
  (let
    (
      (new-id (+ (var-get asset-counter) u1))
      (current-block block-height)
    )
    ;; Perform input validation
    (asserts! (is-eq (len asset-digest) u32) ERR-INVALID-DIGEST-LENGTH)
    (asserts! (not (is-eq asset-digest 0x0000000000000000000000000000000000000000000000000000000000000000)) ERR-DIGEST-ALL-ZEROS)
    (asserts! (is-none (map-get? registered-digests { digest: asset-digest })) ERR-DIGEST-ALREADY-REGISTERED)
    ;; Check validity period
    (asserts! (match validity-block
                validity (> validity current-block)
                true
              )
              ERR-INVALID-VALIDITY)
    
    ;; Register the asset
    (map-set asset-registrations
      { asset-id: new-id }
      { creator: tx-sender, creation-time: current-block, digest: asset-digest, validity: validity-block }
    )
    ;; Track the registered digest
    (map-set registered-digests
      { digest: asset-digest }
      { asset-id: new-id }
    )
    (var-set asset-counter new-id)
    (ok new-id)
  )
)

;; Function to check asset ownership
(define-read-only (check-asset-ownership (asset-id uint))
  (let
    (
      (asset-data (map-get? asset-registrations { asset-id: asset-id }))
    )
    (if (is-some asset-data)
      (let
        (
          (unwrapped-asset-data (unwrap-panic asset-data))
          (current-block block-height)
        )
        (if (and
              (is-some (get validity unwrapped-asset-data))
              (>= current-block (unwrap-panic (get validity unwrapped-asset-data)))
            )
          ERR-ASSET-EXPIRED
          (ok (get creator unwrapped-asset-data))
        )
      )
      ERR-ASSET-NOT-FOUND
    )
  )
)

;; Function to verify asset digest
(define-read-only (verify-asset-digest (asset-id uint) (digest-to-verify (buff 32)))
  (let
    (
      (asset-data (map-get? asset-registrations { asset-id: asset-id }))
    )
    (if (is-some asset-data)
      (let
        (
          (unwrapped-asset-data (unwrap-panic asset-data))
          (current-block block-height)
        )
        (if (and
              (is-some (get validity unwrapped-asset-data))
              (>= current-block (unwrap-panic (get validity unwrapped-asset-data)))
            )
          ERR-ASSET-EXPIRED
          (ok (is-eq (get digest unwrapped-asset-data) digest-to-verify))
        )
      )
      ERR-ASSET-NOT-FOUND
    )
  )
)

;; Function to transfer asset ownership
(define-public (transfer-asset (asset-id uint) (new-creator principal))
  (let
    (
      (current-asset-counter (var-get asset-counter))
    )
    ;; Perform input validation
    (asserts! (<= asset-id current-asset-counter) ERR-ASSET-ID-OUT-OF-RANGE)
    (asserts! (> asset-id u0) ERR-INVALID-ASSET-ID)
    
    (let
      (
        (asset-data (map-get? asset-registrations { asset-id: asset-id }))
      )
      (asserts! (is-some asset-data) ERR-ASSET-NOT-FOUND)
      (let
        (
          (unwrapped-asset-data (unwrap-panic asset-data))
          (current-block block-height)
        )
        (asserts! (is-eq tx-sender (get creator unwrapped-asset-data)) ERR-NOT-AUTHORIZED)
        (asserts! (or
                    (is-none (get validity unwrapped-asset-data))
                    (< current-block (unwrap-panic (get validity unwrapped-asset-data)))
                  )
                  ERR-ASSET-EXPIRED
        )
        (map-set asset-registrations
          { asset-id: asset-id }
          (merge unwrapped-asset-data { creator: new-creator })
        )
        (ok true)
      )
    )
  )
)

;; Function to check if a digest is already registered
(define-read-only (is-digest-registered (asset-digest (buff 32)))
  (is-some (map-get? registered-digests { digest: asset-digest }))
)

;; Function to extend asset registration validity
(define-public (extend-asset-validity (asset-id uint) (new-validity uint))
  (let
    (
      (current-asset-counter (var-get asset-counter))
      (current-block block-height)
    )
    ;; Perform input validation
    (asserts! (<= asset-id current-asset-counter) ERR-ASSET-ID-OUT-OF-RANGE)
    (asserts! (> asset-id u0) ERR-INVALID-ASSET-ID)
    (asserts! (> new-validity current-block) ERR-INVALID-VALIDITY)

    (let
      (
        (asset-data (map-get? asset-registrations { asset-id: asset-id }))
      )
      (asserts! (is-some asset-data) ERR-ASSET-NOT-FOUND)
      (let
        (
          (unwrapped-asset-data (unwrap-panic asset-data))
        )
        (asserts! (is-eq tx-sender (get creator unwrapped-asset-data)) ERR-NOT-AUTHORIZED)
        (match (get validity unwrapped-asset-data)
          current-validity (if (> new-validity current-validity)
                                (begin
                                  (map-set asset-registrations
                                    { asset-id: asset-id }
                                    (merge unwrapped-asset-data { validity: (some new-validity) })
                                  )
                                  (ok true)
                                )
                                ERR-INVALID-VALIDITY)
          (begin
            (map-set asset-registrations
              { asset-id: asset-id }
              (merge unwrapped-asset-data { validity: (some new-validity) })
            )
            (ok true)
          )
        )
      )
    )
  )
)

