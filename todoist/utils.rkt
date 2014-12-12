#lang racket/base

(provide (all-defined-out))

(define (hash-refs h ks [default #f])
  (with-handlers
      ([exn:fail? (lambda () (if (procedure? default) (default) default))])
    (for/fold ([h h])
              ([k (in-list ks)])
      (hash-ref h k))))
