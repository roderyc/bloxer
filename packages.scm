(define-structure bloxer (export (define-bloxer :syntax)
                                 bloxer-state
                                 bloxer-state:rules
                                 bloxer-state:add-rule
                                 lex)
  (open (modify scheme (hide string-copy))
        srfi-8
        srfi-9
        (subset srfi-13 (string-copy))
        (subset srfi-34 (raise))
        (subset conditions (make-message-condition))
        (subset re-exports (rx regexp-search match:substring)))
  (files bloxer))
