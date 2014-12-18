#lang at-exp racket/base

(require "../base.rkt"
         scribble/srcdoc
         (for-doc racket/base scribble/manual))

;; Users

(define-api GET login email password)

(define-api GET (login-with-google "loginWithGoogle") email oauth2-token :
  auto-signup full-name timezone lang)

(define-api GET ping token)

(define-api GET (get-timezones "getTimezones"))

(define-api GET register email full-name password :
  lang timezone)

(define-api GET (delete-user "deleteUser") token current-password :
  reason-for-delete [in-background integer? 1])

(define-api GET (update-user "updateUser") token :
  email full-name password timezone [date-format integer? 0]
  [time-format integer? 0] [start-day integer? 1] next-week
  start-page default-remainder)

(define-api GET (update-avatar "updateAvatar") token :
  image [delete boolean? #f])

(define-api GET (get-redirect-link "getRedirectLink") token :
  [path string? "/app"] hash)

(define-api GET (get-productivity-stats "getProductivityStats") token)


;; Projects

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


;; Labels

(define-api GET (get-labels "getLabels") token : [as-list? integer? 0])

(define-api GET (add-label "addLabel") name token : color)

(define-api GET (update-label "updateLabel") old-name new-name token)

(define-api GET (update-label-color "updateLabelColor") name color token)

(define-api GET (delete-label "deleteLabel") name token)


(provide
 [form-doc (api-call operation:id
                     [key:keyword value]
                     ...
                     (~optional #:method method:str))
           @{}])
