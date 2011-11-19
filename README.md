A lexer building language for scheme. It's a little lame, since it can't lex from streams.
Probably will change this a bunch later.

Based on McLexer, by Matt Might <http://matt.might.net/articles/lexing-and-syntax-highlighting-in-javascript/>.

Example usage:

    ;;; Tokens are pairs, the car being either 'NUM or 'ID, and the cdr being a string value.
    (define *tokens* (make-cell (list)))

    (define (add-token type value)
      (cell-set! *tokens* (cons (cons type value) (cell-ref *tokens*))))

    (define-bloxer (INIT)
     (INIT (+ (or (/ "AZaz") "_")) (match state) ((add-token 'ID match)) => INIT)
     (INIT (+ (/ "09")) (match state) ((add-token 'NUM match)) => INIT)
     (INIT (+ whitespace) => INIT)
     (INIT eos ((cell-set! *tokens* (reverse (cell-ref *tokens*))))))

    (lex INIT "foo bar 123 baz")

    ;;; (cell-ref *tokens*) => ((ID . "foo") (ID . "bar") (NUM . "123") (ID . "baz"))
