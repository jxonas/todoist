#lang at-exp racket/base

(require json
         racket/contract
         racket/format
         racket/match
         scribble/srcdoc
         (for-doc racket/base scribble/manual))


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
