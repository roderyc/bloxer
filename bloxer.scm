;;; (open (modify scheme (hide string-copy))
;;;        srfi-8
;;;        srfi-9
;;;        (subset srfi-13 (string-copy))
;;;        (subset srfi-34 (raise))
;;;        (subset conditions (make-message-condition))
;;;        (subset re-exports (rx regexp-search match:substring)))

(define-record-type :bloxer-state
  (%bloxer-state rules)
  bloxer-state?
  (rules bloxer-state:rules bloxer-state:rules-set!))

(define (bloxer-state)
  (%bloxer-state (list)))

(define (bloxer-state:add-rule state regex action)
  (let ((prefix-regex (rx (: bos (submatch ,regex)))))
    (bloxer-state:rules-set! state (cons (cons prefix-regex action) (bloxer-state:rules state)))))

(define (lex state input)
  (let loop ((state state)
             (input input))
    (receive (next-state rest) (run-state state input)
      (cond (next-state (loop next-state rest))))))

(define (run-state state input)
  (let loop ((longest-matched #f)
             (longest-match #f)
             (longest-match-len -1)
             (rules (reverse (bloxer-state:rules state))))
    (cond ((pair? rules)
           (let* ((r (car rules))
                  (regexp (car r))
                  (m (regexp-search regexp input))
                  (rules (cdr rules)))
             (cond (m (let* ((match (match:substring m 1))
                             (match-len (string-length match)))
                        (if (>= match-len longest-match-len)
                            (loop r match match-len rules)
                            (loop longest-matched longest-match longest-match-len rules))))
                   (else (loop longest-matched longest-match longest-match-len rules)))))
          (longest-matched
           (let ((action (cdr longest-matched))
                 (rest (string-copy input longest-match-len)))
             (values (action longest-match state) rest)))
          (else (raise (make-message-condition "No matches found."))))))

(define-syntax bloxer-syntax-helper
  (syntax-rules (=>)
    ((_ (state regex spec (action ...) => next-state))
     (bloxer-state:add-rule state (rx regex) (lambda spec action ... next-state)))
    ((_ (state regex (action ...) => next-state))
     (bloxer-state:add-rule state (rx regex) (lambda ignored action ... next-state)))
    ((_ (state regex => next-state))
     (bloxer-state:add-rule state (rx regex) (lambda ignored next-state)))
    ;; Terminating actions
    ((_ (state regex spec (action ...)))
     (bloxer-state:add-rule state (rx regex) (lambda spec action ... #f)))
    ((_ (state regex (action ...)))
     (bloxer-state:add-rule state (rx regex) (lambda ignored action ... #f)))
    ((_ (state regex))
     (bloxer-state:add-rule state (rx regex) (lambda ignored #f)))))

(define-syntax define-bloxer
  (syntax-rules ()
    ((_ (state ...) bloxer-clause ...)
     (begin
       (define state (bloxer-state)) ...
       (bloxer-syntax-helper bloxer-clause) ...))))
