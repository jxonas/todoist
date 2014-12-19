#lang at-exp racket/base

(require scribble/srcdoc
         (for-doc racket/base scribble/manual)
         "base.rkt")


(define-api POST (add-note! "addNote") token [item-id integer? 0] content)

(define-api POST (update-note! "updateNote") token [note-id integer? 0] content)

(define-api POST (delete-note! "deleteNote") token
  [item-id integer? 0] [note-id integer? 0])

(define-api GET (get-notes "getNotes") token [item-id integer? 0])

(define-api GET (get-notes-data "getNotesData") token [item-id integer? 0])
