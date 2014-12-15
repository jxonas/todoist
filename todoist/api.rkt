#lang racket/base

(require (for-syntax racket/base
                     racket/syntax
                     syntax/parse)
         json
         net/http-client
         net/uri-codec
         racket/format
         racket/match
         racket/port)

(struct response (status-line header body))

(define (parse-status-line str)
  (match (~a str)
    [(pregexp "^HTTP/(.*)\\s(\\d+)\\s(\\S*)$" (list _ version code message))
     (values version (string->number code) message)]))

(provide ->jsexpr)
(define (->jsexpr x)
  (match x
    [(response status-line header body) (string->jsexpr body)]
    [else (string->jsexpr (~a x))]))

(define (response-code r)
  (define-values (version code message)
    (parse-status-line (response-status-line r)))
  code)

(define (response-message r)
  (define-values (version code message)
    (parse-status-line (response-status-line r)))
  message)


(define (request op [data '()]
                 #:method [method "POST"]
                 #:host [host "todoist.com"]
                 #:headers [headers '("Content-Type: application/x-www-form-urlencoded")]
                 #:endpoint-fmt [endpoint-fmt "/API/~a"]
                 #:ssl? [ssl? #t])
  (define-values (status-line header body)
    (http-sendrecv host
                   (format endpoint-fmt op)
                   #:method method
                   #:ssl? ssl?
                   #:headers headers
                   #:data (alist->form-urlencoded data)))
  (response status-line header (port->string body)))



(define-syntax (define-api/get stx)

  (define (racket->js str)
    (regexp-replaces str '([#rx"-" "_"] [#rx"[!?*]" ""])))

  (define-syntax-class operation
    (pattern racket:id
             #:with js (datum->syntax #'racket (symbol->string (syntax-e #'racket))))
    (pattern [racket:id js:str]))

  (define-syntax-class argument
    (pattern racket:id
             #:with js (datum->syntax #'racket
                                      (string->symbol
                                       (racket->js
                                        (symbol->string (syntax-e #'racket)))))
             #:with keyword (datum->syntax #'racket
                                           (string->keyword
                                            (symbol->string (syntax-e #'racket))))))

  (syntax-parse stx
    #:datum-literals (:)
    [(_ name:operation arg:argument ... : opt:argument ...)
     (with-syntax*
         ([default (gensym)]
          [optionals
           (for/fold ([l '()])
                     ([k (in-list (syntax-e #'(opt.keyword ...)))]
                      [r (in-list (syntax-e #'(opt.racket ...)))])
             (list* k (list r #''default) l))])

       #`(begin
           (define (name.racket arg.racket ... #,@#'optionals)
             (define data (list (cons 'arg.js arg.racket) ...))
             (unless (eq? opt.racket 'default)
               (set! data (cons (cons 'opt.js opt.racket) data)))
             ...
             (request name.js data #:method "GET"))
           (provide name.racket)))]
    [(_ name:operation arg:argument ...)
     #'(define-api/get name arg ... :)]))


;; Users

(define-api/get login email password)

(define-api/get (login-with-google "loginWithGoogle") email oauth2-token :
  auto-signup full-name timezone lang)

(define-api/get ping token)
(define-api/get (get-timezones "getTimezones"))

(define-api/get register email full-name password :
  lang timezone)

(define-api/get (delete-user "deleteUser") token current-password :
  reason-for-delete in-background)

(define-api/get (update-user "updateUser") token :
  email full-name password timezone date-format time-format
  start-day next-week start-page default-remainder)

(define-api/get (update-avatar "updateAvatar") token :
  image delete)

(define-api/get (get-redirect-link "getRedirectLink") token :
  path hash)

(define-api/get (get-productivity-stats "getProductivityStats") token)
