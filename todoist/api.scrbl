#lang scribble/doc

@(require scribble/manual
          scribble/basic
          scribble/extract
          (for-label racket/base
                     "private/response.rkt"
                     "private/api/users.rkt"))

@title[#:tag "top"]{Todoist}
@author[(author+email "Jonas Rodrigues" "jxonas@gmail.com")]
@defmodule[todoist]

This package provides a binding for the @link["https://en.todoist.com/"]{Todoist} API.
This documentation does not describe meaning of API calls; it only describes their Racket calling conventions. For details on API semantics, refer to the documentation at the @link["http://todoist.com/API"]{Todoist site}.

@local-table-of-contents[]

@section[#:tag "todoist"]{Todoist API}
@defmodule[todoist/api]

@subsection[#:tag "response"]{Response}
@;@defmodule[todoist/private/response]

The bindings documented in this section are provided by the
@racketmodname[todoist/api] and @racketmodname[todoist/private/api/users] modules.

@include-extracted["private/response.rkt"]

@subsection[#:tag "user"]{User}
@defmodule[todoist/private/api/users]
@include-extracted["private/api/users.rkt"]
