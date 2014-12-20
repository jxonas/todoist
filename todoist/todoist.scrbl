#lang scribble/manual

@(require scribble/extract
          scribble/basic
          (for-label racket/base
                     todoist/api/response
                     todoist/api/users
                     todoist/api/projects
                     todoist/api/labels
                     todoist/api/items
                     todoist/api/notes
                     todoist/api/search
                     todoist/api/files))

@title[#:style '(toc) #:tag "top"]{Todoist}
@author[(author+email "Jonas Rodrigues" "jxonas@gmail.com")]

@defmodule[todoist]

The module @racketmodname[todoist] will eventually hide the underlying API calls
with higher-level abstractions that make it easy to use @link["http://en.todoist.com"]{Todoist} with Racket. It will be built on top of @racketmodname[todoist/api],
that offers a lower level but not less powerfull interface.

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
@include-extracted[todoist/api/response]

@subsection[#:tag "users"]{Users}
@defmodule[todoist/api/users]
@include-extracted[todoist/api/users]

@subsection[#:tag "projects"]{Projects}
@defmodule[todoist/api/projects]
@include-extracted[todoist/api/projects]

@subsection[#:tag "labels"]{labels}
@defmodule[todoist/api/labels]
@include-extracted[todoist/api/labels]

@subsection[#:tag "items"]{Items}
@defmodule[todoist/api/items]
@include-extracted[todoist/api/items]

@subsection[#:tag "notes"]{Notes}
@defmodule[todoist/api/notes]
@include-extracted[todoist/api/notes]

@subsection[#:tag "search"]{Date query and search}
@defmodule[todoist/api/search]
@include-extracted[todoist/api/search]

@subsection[#:tag "files"]{File Uploads}
@defmodule[todoist/api/files]
@include-extracted[todoist/api/files]
