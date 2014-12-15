#lang scribble/doc

@(require scribble/manual
          scribble/basic
          scribble/extract
          (for-label racket/base
                     "api.rkt"))

@title[#:tag "top"]{Todoist}
@author[(author+email "Jonas Rodrigues" "jxonas@gmail.com")]
@defmodule[todoist]

This package provides a binding for the @link["https://en.todoist.com/"]{Todoist} API.
This documentation does not describe meaning of API calls; it only describes their Racket calling conventions. For details on API semantics, refer to the documentation at the @link["http://todoist.com/API"]{Todoist site}.

@local-table-of-contents[]

@section[#:tag "todoist"]{API}
@defmodule[todoist/api]
@include-extracted["api.rkt"]
