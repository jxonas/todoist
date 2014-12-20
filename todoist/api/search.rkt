#lang at-exp racket/base

(require scribble/srcdoc
         (for-doc racket/base scribble/manual)
         "base.rkt")


(define-api GET query token [queries list? '()] :
  [as-count integer? 0] [js-date integer? 0])
