(define-constant CONTRACT_OWNER tx-sender)
(define-constant ERR_UNAUTHORIZED (err u100))
(define-constant ERR_PART_NOT_FOUND (err u101))
(define-constant ERR_PART_ALREADY_EXISTS (err u102))
(define-constant ERR_INVALID_MANUFACTURER (err u103))
(define-constant ERR_PART_NOT_AUTHENTIC (err u104))
(define-constant ERR_INVALID_SERIAL (err u105))
(define-constant ERR_TRANSFER_FAILED (err u106))
(define-constant ERR_ALREADY_VERIFIED (err u107))

(define-data-var next-part-id uint u1)
(define-data-var total-parts uint u0)
(define-data-var total-manufacturers uint u0)

(define-map parts uint {
    serial-number: (string-ascii 50),
    manufacturer: principal,
    part-type: (string-ascii 30),
    manufacturing-date: uint,
    batch-number: (string-ascii 20),
    owner: principal,
    is-authentic: bool,
    verification-count: uint,
    last-verification: uint,
    metadata: (string-ascii 100)
})

(define-map manufacturers principal {
    name: (string-ascii 50),
    certification-level: uint,
    verified: bool,
    registration-date: uint,
    parts-manufactured: uint
})

(define-map serial-to-part-id (string-ascii 50) uint)
(define-map part-ownership uint principal)
(define-map owner-parts principal (list 100 uint))

(define-public (register-manufacturer (name (string-ascii 50)) (certification-level uint))
    (begin
        (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_UNAUTHORIZED)
        (asserts! (is-none (map-get? manufacturers tx-sender)) ERR_PART_ALREADY_EXISTS)
        (map-set manufacturers tx-sender {
            name: name,
            certification-level: certification-level,
            verified: true,
            registration-date: stacks-block-height,
            parts-manufactured: u0
        })
        (var-set total-manufacturers (+ (var-get total-manufacturers) u1))
        (ok true)
    )
)

(define-public (register-part 
    (serial-number (string-ascii 50))
    (part-type (string-ascii 30))
    (batch-number (string-ascii 20))
    (metadata (string-ascii 100))
)
    (let (
        (part-id (var-get next-part-id))
        (manufacturer-data (unwrap! (map-get? manufacturers tx-sender) ERR_INVALID_MANUFACTURER))
    )
        (asserts! (get verified manufacturer-data) ERR_INVALID_MANUFACTURER)
        (asserts! (is-none (map-get? serial-to-part-id serial-number)) ERR_PART_ALREADY_EXISTS)
        (asserts! (> (len serial-number) u0) ERR_INVALID_SERIAL)
        
        (map-set parts part-id {
            serial-number: serial-number,
            manufacturer: tx-sender,
            part-type: part-type,
            manufacturing-date: stacks-block-height,
            batch-number: batch-number,
            owner: tx-sender,
            is-authentic: true,
            verification-count: u1,
            last-verification: stacks-block-height,
            metadata: metadata
        })
        
        (map-set serial-to-part-id serial-number part-id)
        (map-set part-ownership part-id tx-sender)
        
        (map-set manufacturers tx-sender 
            (merge manufacturer-data {
                parts-manufactured: (+ (get parts-manufactured manufacturer-data) u1)
            })
        )
        
        (var-set next-part-id (+ part-id u1))
        (var-set total-parts (+ (var-get total-parts) u1))
        
        (ok part-id)
    )
)

(define-public (transfer-part (part-id uint) (new-owner principal))
    (let (
        (part-data (unwrap! (map-get? parts part-id) ERR_PART_NOT_FOUND))
        (current-owner (get owner part-data))
    )
        (asserts! (is-eq tx-sender current-owner) ERR_UNAUTHORIZED)
        (asserts! (get is-authentic part-data) ERR_PART_NOT_AUTHENTIC)
        
        (map-set parts part-id 
            (merge part-data {
                owner: new-owner
            })
        )
        
        (map-set part-ownership part-id new-owner)
        (ok true)
    )
)

(define-public (verify-part-authenticity (part-id uint))
    (let (
        (part-data (unwrap! (map-get? parts part-id) ERR_PART_NOT_FOUND))
        (manufacturer-data (unwrap! (map-get? manufacturers (get manufacturer part-data)) ERR_INVALID_MANUFACTURER))
    )
        (asserts! (get verified manufacturer-data) ERR_INVALID_MANUFACTURER)
        (asserts! (get is-authentic part-data) ERR_PART_NOT_AUTHENTIC)
        
        (map-set parts part-id 
            (merge part-data {
                verification-count: (+ (get verification-count part-data) u1),
                last-verification: stacks-block-height
            })
        )
        (ok true)
    )
)

(define-public (report-counterfeit (part-id uint))
    (let (
        (part-data (unwrap! (map-get? parts part-id) ERR_PART_NOT_FOUND))
    )
        (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_UNAUTHORIZED)
        
        (map-set parts part-id 
            (merge part-data {
                is-authentic: false,
                last-verification: stacks-block-height
            })
        )
        (ok true)
    )
)

(define-public (update-manufacturer-verification (manufacturer principal) (verified bool))
    (let (
        (manufacturer-data (unwrap! (map-get? manufacturers manufacturer) ERR_INVALID_MANUFACTURER))
    )
        (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_UNAUTHORIZED)
        
        (map-set manufacturers manufacturer 
            (merge manufacturer-data {
                verified: verified
            })
        )
        (ok true)
    )
)

(define-public (batch-verify-parts (part-ids (list 10 uint)))
    (begin
        (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_UNAUTHORIZED)
        (ok (map verify-part-batch part-ids))
    )
)

(define-private (verify-part-batch (part-id uint))
    (match (map-get? parts part-id)
        part-data 
        (begin
            (map-set parts part-id 
                (merge part-data {
                    verification-count: (+ (get verification-count part-data) u1),
                    last-verification: stacks-block-height
                })
            )
            part-id
        )
        u0
    )
)

(define-read-only (get-part-info (part-id uint))
    (map-get? parts part-id)
)

(define-read-only (get-part-by-serial (serial-number (string-ascii 50)))
    (match (map-get? serial-to-part-id serial-number)
        part-id (map-get? parts part-id)
        none
    )
)

(define-read-only (get-manufacturer-info (manufacturer principal))
    (map-get? manufacturers manufacturer)
)

(define-read-only (is-part-authentic (part-id uint))
    (match (map-get? parts part-id)
        part-data (ok (get is-authentic part-data))
        ERR_PART_NOT_FOUND
    )
)

(define-read-only (get-part-owner (part-id uint))
    (match (map-get? parts part-id)
        part-data (ok (get owner part-data))
        ERR_PART_NOT_FOUND
    )
)

(define-read-only (get-part-verification-count (part-id uint))
    (match (map-get? parts part-id)
        part-data (ok (get verification-count part-data))
        ERR_PART_NOT_FOUND
    )
)

(define-read-only (get-manufacturer-parts-count (manufacturer principal))
    (match (map-get? manufacturers manufacturer)
        manufacturer-data (ok (get parts-manufactured manufacturer-data))
        ERR_INVALID_MANUFACTURER
    )
)

(define-read-only (get-contract-stats)
    (ok {
        total-parts: (var-get total-parts),
        total-manufacturers: (var-get total-manufacturers),
        next-part-id: (var-get next-part-id)
    })
)

(define-read-only (get-part-manufacturing-info (part-id uint))
    (match (map-get? parts part-id)
        part-data (ok {
            manufacturer: (get manufacturer part-data),
            manufacturing-date: (get manufacturing-date part-data),
            batch-number: (get batch-number part-data),
            part-type: (get part-type part-data)
        })
        ERR_PART_NOT_FOUND
    )
)

(define-read-only (is-manufacturer-verified (manufacturer principal))
    (match (map-get? manufacturers manufacturer)
        manufacturer-data (ok (get verified manufacturer-data))
        ERR_INVALID_MANUFACTURER
    )
)

(define-read-only (get-part-history (part-id uint))
    (match (map-get? parts part-id)
        part-data (ok {
            serial-number: (get serial-number part-data),
            current-owner: (get owner part-data),
            is-authentic: (get is-authentic part-data),
            verification-count: (get verification-count part-data),
            last-verification: (get last-verification part-data),
            manufacturing-date: (get manufacturing-date part-data)
        })
        ERR_PART_NOT_FOUND
    )
)

(define-read-only (validate-part-chain (part-id uint))
    (match (map-get? parts part-id)
        part-data 
        (let (
            (manufacturer-data (unwrap! (map-get? manufacturers (get manufacturer part-data)) ERR_INVALID_MANUFACTURER))
        )
            (ok {
                part-exists: true,
                manufacturer-verified: (get verified manufacturer-data),
                part-authentic: (get is-authentic part-data),
                chain-valid: (and 
                    (get verified manufacturer-data)
                    (get is-authentic part-data)
                )
            })
        )
        ERR_PART_NOT_FOUND
    )
)
