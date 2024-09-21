(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-unknown-feed (err u101))
(define-constant err-btc-price-not-set (err u102))
(define-constant err-feed-already-exists (err u103))
(define-constant err-invalid-feed (err u104))
(define-constant err-feed-frozen (err u105))

(define-data-var feed-index uint u0)
(define-data-var btc-feed-index-set bool false)
(define-data-var btc-feed-index uint u0)
(define-data-var price-tolerance uint u5) ;; Tolerance in percentage (5% default)
(define-data-var owner principal contract-owner)

;; Each feed now stores whether it is frozen
(define-map price-feeds uint {
  current-value: uint,
  block: uint,
  ticker: (string-ascii 15),
  type: (string-ascii 15),
  name: (string-ascii 100),
  implied-volatility: uint,
  pyth-feed-id: (string-ascii 100),
  is-frozen: bool
})

;; A map to store historical prices of each feed
(define-map price-history (tuple (feed-id uint) (block uint)) {
  value: uint
})

;; Helper function to check if the sender is the contract owner
(define-private (is-contract-owner)
  (is-eq tx-sender (var-get owner))
)

;; Function to transfer contract ownership
(define-public (transfer-ownership (new-owner principal))
  (begin
    (asserts! (is-contract-owner) err-owner-only)
    (var-set owner new-owner)
    (ok true)
  )
)

;; Add a new feed with the frozen flag
(define-public (add-feed (feed {
  current-value: uint, 
  ticker: (string-ascii 15),
  type: (string-ascii 15),
  name: (string-ascii 100),
  implied-volatility: uint,
  pyth-feed-id: (string-ascii 100)
}))
  (let ((feed-id (var-get feed-index)))
    (begin
      (asserts! (is-contract-owner) err-owner-only)
      (asserts! (is-none (map-get? price-feeds feed-id)) err-feed-already-exists)
      ;; Insert feed data with 'is-frozen' flag set to false
      (map-set price-feeds feed-id {
        current-value: (get current-value feed),
        block: block-height,
        ticker: (get ticker feed),
        name: (get name feed),
        type: (get type feed),
        implied-volatility: (get implied-volatility feed),
        pyth-feed-id: (get pyth-feed-id feed),
        is-frozen: false
      })
      ;; If BTC feed, set BTC feed index
      (if (is-eq (get ticker feed) "BTC")
        (begin
          (var-set btc-feed-index-set true)
          (var-set btc-feed-index feed-id)
        )
        (is-eq true true))
      (var-set feed-index (+ feed-id u1))
      (ok true)
    )
  )
)

;; Delete a feed
(define-public (delete-feed (feed-id uint))
  (begin
    (asserts! (is-contract-owner) err-owner-only)
    (asserts! (is-some (map-get? price-feeds feed-id)) err-unknown-feed)
    (map-delete price-feeds feed-id)
    (ok true)
  )
)

;; Update value for a feed with tolerance and freeze check
(define-public (update-feed (feed {
  feed-id: uint, 
  current-value: uint
}))
  (let (
    (feed-id (get feed-id feed))
    (new-value (get current-value feed))
    (current-feed (unwrap! (map-get? price-feeds feed-id) err-unknown-feed))
  )
    (begin
      (asserts! (is-contract-owner) err-owner-only)
      ;; Check if the feed is frozen
      (asserts! (is-eq (get is-frozen current-feed) false) err-feed-frozen)
      ;; Check price tolerance
      (let ((old-value (get current-value current-feed)))
        (let ((tolerance (var-get price-tolerance)))
          (asserts! (<= (abs (- new-value old-value)) (/ (* old-value tolerance) u100)) err-invalid-feed)
        )
      )
      ;; Update the feed's value and block
      (map-set price-feeds feed-id (merge current-feed {
        current-value: new-value,
        block: block-height
      }))
      ;; Store the value in price-history
      (map-set price-history (tuple (feed-id feed-id) (block block-height)) {
        value: new-value
      })
      (ok true)
    )
  )
)

;; Freeze a feed (prevents updates)
(define-public (freeze-feed (feed-id uint))
  (begin
    (asserts! (is-contract-owner) err-owner-only)
    (let ((current-feed (unwrap! (map-get? price-feeds feed-id) err-unknown-feed)))
      (map-set price-feeds feed-id (merge current-feed {is-frozen: true}))
      (ok true)
    )
  )
)

;; Unfreeze a feed
(define-public (unfreeze-feed (feed-id uint))
  (begin
    (asserts! (is-contract-owner) err-owner-only)
    (let ((current-feed (unwrap! (map-get? price-feeds feed-id) err-unknown-feed)))
      (map-set price-feeds feed-id (merge current-feed {is-frozen: false}))
      (ok true)
    )
  )
)

;; Set price tolerance for updates
(define-public (set-price-tolerance (tolerance uint))
  (begin
    (asserts! (is-contract-owner) err-owner-only)
    (var-set price-tolerance tolerance)
    (ok true)
  )
)

;; Get the price history for a given feed and block
(define-read-only (get-price-history (feed-id uint) (block uint))
  (map-get? price-history (tuple (feed-id feed-id) (block block)))
)

;; Batch retrieve prices for multiple feeds
(define-read-only (get-prices (feed-ids (list 12 uint)))
  (map (lambda (feed-id)
    (let ((feed (map-get? price-feeds feed-id)))
      (match feed
        feed-data (ok (get current-value feed-data))
        (err err-unknown-feed)
      )
    )
  ) feed-ids)
)

;; Get the current BTC price
(define-read-only (get-btc-price)
  (if (var-get btc-feed-index-set)
    (ok (get current-value (unwrap! (map-get? price-feeds (var-get btc-feed-index)) err-unknown-feed)))
    err-btc-price-not-set
  )
)

;; Get the current feed index
(define-read-only (get-feed-index)
  (ok (var-get feed-index))
)
