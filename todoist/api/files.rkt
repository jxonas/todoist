#lang at-exp racket/base

(require racket/contract
         racket/port
         scribble/srcdoc
         (for-doc racket/base scribble/manual)
         (only-in racket/path file-name-from-path)
         "base.rkt"
         "response.rkt")


(provide
 [proc-doc/names upload-file
                 (->* (string? (or/c path? string?)) (string?) response?)
                 ((token path) ([file-name (file-name-from-path path)]))
                 @{}])


(define (upload-file token path [file-name (file-name-from-path path)])
  (request "todoist.com"
           (format "/API/uploadFile?token=~a" token)
           #:method "POST"
           #:ssl? #t
           #:headers `(,(format "X-File-Name: ~a" file-name))
           #:data (lambda (proc)
                    (proc
                     (call-with-input-file path
                       port->bytes)))))
