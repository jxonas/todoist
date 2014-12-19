#lang at-exp racket/base

(require scribble/srcdoc
         (for-doc racket/base scribble/manual)
         "base.rkt")


(define-api GET (get-uncompleted-items "getUncompletedItems")
  token [project-id integer?] : [js-date integer? 0])

(define-api GET (get-all-completed-items "getAllCompletedItems") token :
  [js-date integer? 0] [project-id integer? 0] [limit integer? 30] from-date)

(define-api GET (get-items-by-id "getItemsById") token [ids list?] :
  [js-date integer? 0])

(define-api POST (add-item! "addItem") token content :
  [project-id integer? 0] date-string [priority integer? 1] [indent integer? 1]
  [js-date integer? 0] [item-order integer? 0] [children list? '()] [labels list? '()]
  [assigned-by-uid integer? 0] [responsible-uid integer? 0] note)

(define-api POST (update-item! "updateItem") token [id integer? 0] :
  content date-string [priority integer? 1] [indent integer? 1]
  [item-order integer? 1] [collapsed integer? 0] [labels list? '()]
  [js-date integer? 0] [assigned-by-uid integer? 0] [responsible-uid integer? 0])

(define-api POST (update-orders! "updateOrders") token [project-id integer? 0]
  [item-id-list list? '()])

(define-api POST (move-items! "moveItems") token
  [project-items list? '()] [to-project integer? 0])

(define-api POST (update-recurring-date! "updateRecurringDate") token
  [ids list? '()] [js-date integer? 0])

(define-api POST (delete-items! "deleteItems") token [ids list? '()])

(define-api POST (complete-items! "completeItems") token [ids list? '()] :
  [in-history integer? 1])

(define-api POST (uncomplete-items! "uncompleteItems") token [ids list? '()])
