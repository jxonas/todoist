#lang at-exp racket/base

(require (for-syntax racket/base
                     racket/syntax
                     syntax/parse)
         json
         net/http-client
         net/uri-codec
         racket/contract
         racket/format
         racket/match
         racket/port
         scribble/srcdoc
         (for-doc racket/base scribble/manual))

(provide
 [struct*-doc response
              ([status-line bytes?]
               [headers list?]
               [body string?])
              @{Response object returned by every API call.}]
 [proc-doc/names parse-status-line
                 (-> (or/c bytes? string?) (values string? integer? string?))
                 (status-line)
                 @{Parse @racket[response-status-line] and return
                   the http version, status code and message.}]
 [proc-doc/names response-status-code
                 (-> response? integer?)
                 (response)
                 @{Response code.}]
 [proc-doc/names ->jsexpr
                 (-> (or/c response? string? bytes?) jsexpr?)
                 (x)
                 @{Converts input to @racket[jsexpr?].}]
 [proc-doc/names response-success?
                 (-> response? boolean?)
                 (response)
                 @{@racket[#t] if response is a success. @racket[#f] otherwise.}])

;; Response

(define HTTP_OK 200)

(define ERROR_TEXT_RESPONSES
  '("\"LOGIN_ERROR\"",
    "\"INTERNAL_ERROR\"",
    "\"EMAIL_MISMATCH\"",
    "\"ACCOUNT_NOT_CONNECTED_WITH_GOOGLE\"",
    "\"ALREADY_REGISTRED\"",
    "\"TOO_SHORT_PASSWORD\"",
    "\"INVALID_EMAIL\"",
    "\"INVALID_TIMEZONE\"",
    "\"INVALID_FULL_NAME\"",
    "\"UNKNOWN_ERROR\"",
    "\"ERROR_PASSWORD_TOO_SHORT\"",
    "\"ERROR_EMAIL_FOUND\"",
    "\"UNKNOWN_IMAGE_FORMAT\"",
    "\"AVATAR_NOT_FOUND\"",
    "\"UNABLE_TO_RESIZE_IMAGE\"",
    "\"IMAGE_TOO_BIG\"",
    "\"UNABLE_TO_RESIZE_IMAGE\"",
    "\"ERROR_PROJECT_NOT_FOUND\"",
    "\"ERROR_NAME_IS_EMPTY\"",
    "\"ERROR_WRONG_DATE_SYNTAX\"",
    "\"ERROR_ITEM_NOT_FOUND\""))

(struct response (status-line headers body))

(define (parse-status-line str)
  (match (~a str)
    [(pregexp "^HTTP/(.*)\\s+(\\d+)\\s+(.*)$" (list _ version code message))
     (values version (string->number code) message)]))

(define (->jsexpr x)
  (match x
    [(response status-line header body) (string->jsexpr body)]
    [else (string->jsexpr (~a x))]))

(define (response-status-code r)
  (define-values (version code message)
    (parse-status-line (response-status-line r)))
  code)

(define (response-message r)
  (define-values (version code message)
    (parse-status-line (response-status-line r)))
  message)

(define (response-success? r)
  (and (= (response-status-code r) HTTP_OK)
       (not (member (response-body r) ERROR_TEXT_RESPONSES))))


(define (request op [data '()]
                 #:method [method "POST"]
                 #:host [host "todoist.com"]
                 #:headers [headers '("Content-Type: application/x-www-form-urlencoded")]
                 #:endpoint-fmt [endpoint-fmt "/API/~a"]
                 #:ssl? [ssl? #t])
  (define-values (status-line header body)
    (http-sendrecv host
                   (format endpoint-fmt op)
                   #:method method
                   #:ssl? ssl?
                   #:headers headers
                   #:data (alist->form-urlencoded data)))
  (response status-line header (port->string body)))

(define (normalize-data data)
  (for/list ([d (in-list data)])
    (cons (car d) (~a (cdr d)))))

(define-syntax (define-api/get stx)

  (define (racket->js str)
    (regexp-replaces str '([#rx"-" "_"] [#rx"[!?*]" ""])))

  (define-syntax-class operation
    (pattern racket:id
             #:with js (datum->syntax #'racket (symbol->string (syntax-e #'racket))))
    (pattern [racket:id js:str]))

  (define-syntax-class argument-name
    (pattern racket:id
             #:with js (datum->syntax #'racket
                                      (string->symbol
                                       (racket->js
                                        (symbol->string (syntax-e #'racket)))))
             #:with keyword (datum->syntax #'racket
                                           (string->keyword
                                            (symbol->string (syntax-e #'racket))))))

  (define-syntax-class argument
    (pattern arg:argument-name
             #:with racket #'arg.racket
             #:with js #'arg.js
             #:with keyword #'arg.keyword
             #:with contract #'string?
             #:with default #'"")
    (pattern [arg:argument-name contract:expr
                                (~optional default:expr #:defaults ([default #'""]))]
             #:with racket #'arg.racket
             #:with js #'arg.js
             #:with keyword #'arg.keyword))

  (syntax-parse stx
    #:datum-literals (:)
    [(_ name:operation arg:argument ... : opt:argument ...)
     (with-syntax*
         ([default (gensym)]
          [optionals
           (for/fold ([l '()])
                     ([k (in-list (syntax-e #'(opt.keyword ...)))]
                      [r (in-list (syntax-e #'(opt.racket ...)))])
             (list* k (list r #''default) l))]
          [doc-optionals
           (for/fold ([l '()])
                     ([k (in-list (syntax-e #'(opt.keyword ...)))]
                      [r (in-list (syntax-e #'(opt.contract ...)))])
             (append l (list k r)))])

       #`(begin
           (define (name.racket arg.racket ... #,@#'optionals)
             (define data (list (cons 'arg.js arg.racket) ...))
             (unless (eq? opt.racket 'default)
               (set! data (cons (cons 'opt.js opt.racket) data)))
             ...
             (request name.js (normalize-data data) #:method "GET"))
           (provide
            [proc-doc/names name.racket
                            (->* (arg.contract ...) (#,@#'doc-optionals) response?)
                            ((arg.racket ...) ([opt.racket opt.default] ...))
                            @{See @link[(format "http://todoist.com/API/#/API/~a"
                                                name.js)
                                        (format "/API/~a" name.js)]
                              for details.}])))]
    [(_ name:operation arg:argument ...)
     #'(define-api/get name arg ... :)]))


;; Users

(define-api/get login email password)

(define-api/get (login-with-google "loginWithGoogle") email oauth2-token :
  auto-signup full-name timezone lang)

(define-api/get ping token)

(define-api/get (get-timezones "getTimezones"))

(define-api/get register email full-name password :
  lang timezone)

(define-api/get (delete-user "deleteUser") token current-password :
  reason-for-delete [in-background integer? 1])

(define-api/get (update-user "updateUser") token :
  email full-name password timezone [date-format integer? 0]
  [time-format integer? 0] [start-day integer? 1] next-week
  start-page default-remainder)

(define-api/get (update-avatar "updateAvatar") token :
  image [delete boolean? #f])

(define-api/get (get-redirect-link "getRedirectLink") token :
  [path string? "/app"] hash)

(define-api/get (get-productivity-stats "getProductivityStats") token)


;; Projects

(define-api/get (get-projects "getProjects") token)

(define-api/get (get-project "getProject") token [project-id integer?])

(define-api/get (add-project "addProject") name token :
  [color integer? 0] [indent integer? 1] [order integer? 0])

(define-api/get (update-project "updateProject") [project-id integer?] token :
  name [color integer? 0] [indent integer? 0]
  [order integer? 0] [collapse integer? 0])

(define-api/get (update-project-orders "updateProjectOrders")
  token [item-id-list list?])

(define-api/get (delete-project "deleteProject") [project-id integer?] token)

(define-api/get (get-archived "getArchived") token)

(define-api/get (archive-project "archiveProject") [project-id integer?] token)

(define-api/get (unarchive-project "unarchiveProject") [project-id integer?] token)
