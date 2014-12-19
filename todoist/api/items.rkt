#lang at-exp racket/base

(require scribble/srcdoc
         (for-doc racket/base scribble/manual)
         "base.rkt")


(define-api GET (get-uncompleted-items "getUncompletedItems") 
  [project-id integer?] token : js-date)

(define-api GET (get-all-completed-items "getAllCompletedItems") token :
  js-date [project-id integer? 0] [limit integer? 30] from-date)

(define-api GET (get-items-by-id "getItemsById") [ids list?] token : js-date)

(define-api POST (add-item! "addItem") content token :
  [project-id integer? 0] date-string [priority integer? 1] [indent integer? 1]
  js-date [item-order integer? 0] [children list? '()] [labels list? '()]
  [assigned-by-uid integer? 0] [responsible-uid integer? 0] note)
