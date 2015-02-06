#lang racket

(require "api/response.rkt"
         (prefix-in api: "api.rkt")
         syntax/parse
         racket/syntax)


(struct exn:fail:todoist exn:fail ())
(define-syntax-rule (todoist-error msg)
  (raise (exn:fail:todoist
          (string-append "todoist ERROR: " msg)
          (current-continuation-marks))))

(define (fail-on-error r)
  (when (response-fail? r)
    (define-values (_ __ msg) (parse-status-line (response-status-line r)))
    (todoist-error msg)))

(define (valid-response/jsexpr r)
  (fail-on-error r)
  (->jsexpr r))

(define (js->racket id)
  (string->symbol
   (regexp-replaces (symbol->string id) '([#rx"_" "-"]))))

(define (todoist-object-mixin %)
  (class % (super-new)
    (init jsexpr)
    (for/list [(k+v (in-hash-pairs jsexpr))]
      (match-define (cons k v) k+v)
      (with-handlers ([exn:fail?
                       (lambda (e)
                         (displayln (format "missing field ~a" k)))])
        (dynamic-set-field! (js->racket k) this v)))))

(define-syntax-rule (todoist-fields name ...)
  (field [name #f] ...))

(define user%
  (todoist-object-mixin
   (class object% (super-new)
     (todoist-fields
      id token email timezone start-page
      full-name next-week start-day time-format
      date-format avatar-small last-used-ip
      api-token tz-offset is-premium sort-order
      auto-reminder shard-id avatar-s640 team-inbox
      join-date avatar-medium is-dummy inbox-project
      image-id beta premium-until business-account-id
      avatar-big mobile-number mobile-host has-push-reminders
      karma-trend seq-no karma is-biz-admin default-reminder)

     (define/public (logged-in?)
       (and token (response-success? (api:ping token)) #t))

     (define/public (delete password [reason #f])
       (fail-on-error
        (api:delete-user token password
                         #:reason-for-delete reason
                         #:in-background 0))))))

(define (login email password)
  (new user% [jsexpr (valid-response/jsexpr
                      (api:login email password))]))

(define (login-with-token token)
  (new user% [jsexpr (valid-response/jsexpr
                      (api:update-user token))]))

(define (login-with-google email oauth2-token)
  (new user% [jsexpr (valid-response/jsexpr
                      (api:login-with-google email oauth2-token))]))

(module+ test
  (require rackunit)

  (provide token user)

  (define .todoist (build-path (find-system-path 'home-dir) ".todoist"))
  (define token (call-with-input-file .todoist read))

  (define user (login-with-token token))

  (check-equal? (get-field token user) token))
