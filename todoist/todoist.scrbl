#lang scribble/manual

@(require scribble/extract
          scribble/basic
          todoist/api
          (for-label racket/base todoist/api))

@title[#:style '(toc) #:tag "top"]{Todoist}
@author[(author+email "Jonas Rodrigues" "jxonas@gmail.com")]

@defmodule[todoist]

The module @racketmodname[todoist] hides the underlying API calls with higher-level
abstractions that make it easy to use @link["http://en.todoist.com"]{Todoist}
with Racket. It is built on top of @racketmodname[todoist/api], that offers a
lower level but not less powerfull interface.

@local-table-of-contents[]

@section[#:tag "api"]{Low Level API}

@defmodule[todoist/api]

This package provides a binding for the @link["https://en.todoist.com/"]{Todoist} API.
This documentation does not describe meaning of API calls; it only describes their
Racket calling conventions. For details on API semantics, refer to the documentation
at the @link["http://todoist.com/API"]{Todoist site}.

The bindings documented in this section are provided by the
@racketmodname[todoist/api] but not @racketmodname[todoist].

@subsection[#:tag "response"]{Response}
@defmodule[todoist/api/response]
@include-extracted["api/response.rkt"]

@subsection[#:tag "users"]{Users}
@defmodule[todoist/api/users]
@include-extracted["api/users.rkt"]

@subsection[#:tag "projects"]{Projects}
@defmodule[todoist/api/projects]
@include-extracted["api/projects.rkt"]

@subsection[#:tag "labels"]{labels}
@defmodule[todoist/api/labels]
@include-extracted["api/labels.rkt"]
