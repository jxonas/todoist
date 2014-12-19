#lang at-exp racket/base

(require "base.rkt"
         scribble/srcdoc
         (for-doc racket/base scribble/manual))

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
