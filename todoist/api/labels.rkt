#lang at-exp racket/base

(require scribble/srcdoc
         (for-doc racket/base scribble/manual)
         "base.rkt")

(define-api GET (get-labels "getLabels") token : [as-list? integer? 0])

(define-api GET (add-label "addLabel") name token : color)

(define-api GET (update-label "updateLabel") old-name new-name token)

(define-api GET (update-label-color "updateLabelColor") name color token)

(define-api GET (delete-label "deleteLabel") name token)
