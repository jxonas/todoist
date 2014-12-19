#lang at-exp racket/base

(require scribble/srcdoc
         (for-doc racket/base scribble/manual)
         "base.rkt")

(define-api GET (get-projects "getProjects") token)

(define-api GET (get-project "getProject") token [project-id integer?])

(define-api GET (add-project "addProject") name token :
  [color integer? 0] [indent integer? 1] [order integer? 0])

(define-api GET (update-project "updateProject") [project-id integer?] token :
  name [color integer? 0] [indent integer? 0]
  [order integer? 0] [collapse integer? 0])

(define-api GET (update-project-orders "updateProjectOrders")
  token [item-id-list list?])

(define-api GET (delete-project "deleteProject") [project-id integer?] token)

(define-api GET (get-archived "getArchived") token)

(define-api GET (archive-project "archiveProject") [project-id integer?] token)

(define-api GET (unarchive-project "unarchiveProject") [project-id integer?] token)
