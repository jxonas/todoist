#lang at-exp racket/base

(require (for-syntax racket/base
                     racket/syntax
                     syntax/parse)
         net/http-client
         net/uri-codec
         racket/contract
         racket/format
         racket/port
         scribble/srcdoc
         (for-doc racket/base scribble/manual)
         "response.rkt")

(provide GET POST
         request
         define-api)

(define GET "GET")
(define POST "POST")

(define (request op [data '()]
                 #:method [method POST]
                 #:host [host "todoist.com"]
                 #:headers
                 [headers '("Content-Type: application/x-www-form-urlencoded")]
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


(define (normalize-data data)
  (for/list ([d (in-list data)])
    (cons (car d) (~a (cdr d)))))


(define-for-syntax (racket->js str)
  (regexp-replaces str '([#rx"-" "_"] [#rx"[!?*]" ""])))

(define-syntax (define-api stx)

  (define-syntax-class operation
    (pattern racket:id
             #:with js (datum->syntax #'racket (symbol->string (syntax-e #'racket))))
    (pattern [racket:id js:str]))

  (define-syntax-class argument-name
    (pattern racket:id
             #:with js (datum->syntax #'racket
                                      (string->symbol
                                       (racket->js
                                        (symbol->string (syntax-e #'racket)))))
             #:with keyword (datum->syntax #'racket
                                           (string->keyword
                                            (symbol->string (syntax-e #'racket))))))

  (define-syntax-class argument
    (pattern arg:argument-name
             #:with racket #'arg.racket
             #:with js #'arg.js
             #:with keyword #'arg.keyword
             #:with contract #'string?
             #:with default #'"")
    (pattern [arg:argument-name contract:expr
                                (~optional default:expr #:defaults ([default #'""]))]
             #:with racket #'arg.racket
             #:with js #'arg.js
             #:with keyword #'arg.keyword))

  (syntax-parse stx
    #:datum-literals (:)
    [(_ METHOD name:operation arg:argument ... : opt:argument ...)
     (with-syntax*
         ([default (gensym)]
          [optionals
           (for/fold ([l '()])
                     ([k (in-list (syntax-e #'(opt.keyword ...)))]
                      [r (in-list (syntax-e #'(opt.racket ...)))])
             (list* k (list r #''default) l))]
          [doc-optionals
           (for/fold ([l '()])
                     ([k (in-list (syntax-e #'(opt.keyword ...)))]
                      [r (in-list (syntax-e #'(opt.contract ...)))])
             (append l (list k r)))])

       #`(begin
           (define (name.racket arg.racket ... #,@#'optionals)
             (define data (list (cons 'arg.js arg.racket) ...))
             (unless (eq? opt.racket 'default)
               (set! data (cons (cons 'opt.js opt.racket) data)))
             ...
             (request name.js (normalize-data data) #:method METHOD))
           (provide
            [proc-doc/names name.racket
                            (->* (arg.contract ...) (#,@#'doc-optionals) response?)
                            ((arg.racket ...) ([opt.racket opt.default] ...))
                            @{See @link[(format "http://todoist.com/API/#/API/~a"
                                                name.js)
                                        (format "/API/~a" name.js)]
                              for details.}])))]
    [(_ METHOD name:operation arg:argument ...)
     #'(define-api METHOD name arg ... :)]))