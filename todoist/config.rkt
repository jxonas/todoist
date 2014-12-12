#lang racket/base

;; Adapted from
;; https://github.com/greghendershott/frog/blob/master/frog/config.rkt
;;

(require racket/dict
         racket/file
         racket/match)

(provide get-config)

(define configs (make-hash)) ;; (hash/c path? (hash/c symbol? any/c))
(define (get-config name default cfg-path) ;; (symbol? any/c path? -> any/c)
  (define config
    (cond [(dict-has-key? configs cfg-path) (dict-ref configs cfg-path)]
          [else
           (dict-set! configs cfg-path (read-config cfg-path))
           (dict-ref configs cfg-path)]))
  (cond [(dict-has-key? config name)
         (define v (dict-ref config name))
         (cond [(string? default) v]
               [(boolean? default) v]
               [(number? default)
                (or (string->number v)
                    (begin
                      (eprintf
                       "Expected number for ~a. Got '~a'. Using default: ~a\n"
                       name v default)
                      default))]
               [else (raise-type-error 'get-config
                                       "string, boolean, or number"
                                       v)])]
        [else default]))

(define (read-config p)
  (cond [(file-exists? p)
         (for/hasheq ([s (file->lines p)])
           (match s
             [(pregexp "^(.*)#?.*$" (list _ s))
              (match s
                [(pregexp "^\\s*(\\S+)\\s*=\\s*(.+)$" (list _ k v))
                 (values (string->symbol k) (maybe-bool v))]
                [else (values #f #f)])]
             [_ (values #f #f)]))]
        [else
         (make-hasheq)]))

(define (maybe-bool v) ;; (any/c -> (or/c #t #f any/c))
  (match v
    [(or "true" "#t") #t]
    [(or "false" "#f") #f]
    [else v]))
