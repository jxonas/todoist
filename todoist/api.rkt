#lang racket/base

(require (for-syntax racket/base
                     racket/syntax
                     syntax/parse)
         json
         net/http-client
         net/uri-codec
         racket/format
         racket/function
         racket/list
         racket/port)

;;; Utilities

(define (hash-refs h ks [default #f])
  (with-handlers
      ([exn:fail? (const (if (procedure? default) (default) default))])
    (for/fold ([h h])
              ([k (in-list ks)])
      (hash-ref h k))))

(define (->json stuff)
  (call-with-output-string
   (lambda (out)
     (write-json stuff out))))

;;; API

(define API-VERSION "5.3")

(define token "...")

(define (request [data-alist '()]
                 #:method [method "get"]
                 #:token [token token]
                 #:seq [seq 0])

  ;; ensure cdr is always text
  (define data
    (for/list ([parm (in-list data-alist)])
      (cons (car parm) (~a (cdr parm)))))

  (define-values (return headers body)
    (http-sendrecv "api.todoist.com"
                   (format "/TodoistSync/v~a/~a" API-VERSION method)
                   #:method "POST"
                   #:ssl? #t
                   #:headers '("Content-Type: application/x-www-form-urlencoded")
                   #:data
                   (alist->form-urlencoded
                    (list* (cons 'api_token (~a token))
                           (cons 'seq_no (~a seq))
                           data))))

  (if (bytes=? return #"HTTP/1.1 200 OK")
      (string->jsexpr (port->string body))
      (error (~a return))))
