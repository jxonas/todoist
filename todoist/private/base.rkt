#lang at-exp racket/base

(require (for-syntax racket/base
                     racket/syntax
                     syntax/parse)
         json
         net/http-client
         net/uri-codec
         racket/contract
         racket/format
         racket/match
         racket/port
         scribble/srcdoc
         (for-doc racket/base scribble/manual))

(provide (all-defined-out))

#;
(provide
 define-api
 GET POST
 [struct*-doc response
              ([status-line bytes?]
               [headers list?]
               [body string?])
              @{Response object returned by every API call.}]
 [proc-doc/names parse-status-line
                 (-> (or/c bytes? string?) (values string? integer? string?))
                 (status-line)
                 @{Parse @racket[response-status-line] and return
                   the http version, status code and message.}]
 [proc-doc/names response-status-code
                 (-> response? integer?)
                 (response)
                 @{Response code.}]
 [proc-doc/names ->jsexpr
                 (-> (or/c response? string? bytes?) jsexpr?)
                 (x)
                 @{Converts input to @racket[jsexpr?].}]
 [proc-doc/names response-success?
                 (-> response? boolean?)
                 (response)
                 @{@racket[#t] if response is a success. @racket[#f] otherwise.}])

;; Response

(define (normalize-data data)
  (for/list ([d (in-list data)])
    (cons (car d) (~a (cdr d)))))


(define GET "GET")
(define POST "POST")

(define-for-syntax (racket->js str)
  (regexp-replaces str '([#rx"-" "_"] [#rx"[!?*]" ""])))

(define-syntax (api-call stx)

  (define-splicing-syntax-class method-argument
    (pattern (~optional (~seq #:method method:str)
                        #:defaults ([method #'"GET"]))))

  (define-splicing-syntax-class argument
    (pattern (~seq key:keyword value:expr)
             #:with js (datum->syntax #'key
                                      (string->symbol
                                       (racket->js
                                        (keyword->string
                                         (syntax-e #'key)))))))
  (syntax-parse stx
    [(_ METHOD:method-argument op arg:argument ...)
     #'(request op (normalize-data (list (cons 'arg.js arg.value) ...))
                #:method METHOD.method)]))

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
