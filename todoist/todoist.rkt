#lang racket

(require todoist/api)

(define (todoist-error fmt . args)
  (apply error 'todoist fmt args))

(define (todoist-response-error r msg)
  (define-values (http-version code error-message)
    (parse-status-line (response-status-line r)))
  (todoist-error "~a: ~a" msg error-message))

(define (ensure-valid-token token)
  (cond
    [(response-fail? (ping token))
     => (lambda (r) (todoist-response-error r "wrong token"))]
    [else token]))

(define todoist%
  (class object%
    (init [token #f] [email #f] [password #f])

    (define/public (get-token) user-token)
    (define user-token
      (cond
        [token (ensure-valid-token token)]
        [(and email password)
         (cond
           [(response-success? (login email password))
            => (lambda (r)  (hash-ref (->jsexpr r) 'token))]
           [else (todoist-error "login failed")])]
        [else (todoist-error "expected either token or email/password")]))

    (super-new)))

(module+ test
  (require rackunit)

  (provide token todoist)

  (define .todoist (build-path (find-system-path 'home-dir) ".todoist"))
  (define token (call-with-input-file .todoist read))
  (define todoist (new todoist% [token token])))
