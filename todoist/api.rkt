#lang racket/base

(require json
         net/http-client
         net/uri-codec
         racket/format
         racket/port
         "config.rkt")

(define API-VERSION "5.3")

(define .todoist (build-path (find-system-path 'home-dir) ".todoist"))
(define token (make-parameter (get-config 'token "..." .todoist)))

(define (request [data-alist '()] #:method [method "get"] #:seq [seq 0])
  (define-values (return headers body)
    (http-sendrecv "api.todoist.com"
                   (format "/TodoistSync/v~a/~a" API-VERSION method)
                   #:method "POST"
                   #:ssl? #t
                   #:headers '("Content-Type: application/x-www-form-urlencoded")
                   #:data
                   (alist->form-urlencoded
                    (list* (cons 'api_token (~a (token)))
                           (cons 'seq_no (~a seq))
                           (normalize-data data-alist)))))
  (if (bytes=? return #"HTTP/1.1 200 OK")
      (string->jsexpr (port->string body))
      (error (~a return))))

(define (normalize-data data-alist)
  (for/list ([data (in-list data-alist)])
    (cons (car data) (~a (cdr data)))))
