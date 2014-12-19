1970
((3) 0 () 5 ((q lib "todoist/api/response.rkt") (q lib "todoist/api/projects.rkt") (q lib "todoist/api/users.rkt") (q 0 . 5) (q lib "todoist/api/labels.rkt")) () (h ! (equal) ((c def c (c (? . 1) q add-project)) q (3822 . 11)) ((c def c (c (? . 0) q response-status-code)) q (241 . 3)) ((c def c (c (? . 0) q response?)) c (? . 3)) ((c def c (c (? . 2) q ping)) q (1125 . 3)) ((c def c (c (? . 1) q update-project)) q (4176 . 15)) ((c def c (c (? . 0) q parse-status-line)) q (122 . 3)) ((c def c (c (? . 2) q login)) q (488 . 4)) ((c def c (c (? . 1) q delete-project)) q (4863 . 4)) ((c def c (c (? . 2) q update-avatar)) q (3098 . 7)) ((c def c (c (? . 4) q delete-label)) q (5802 . 4)) ((c def c (c (? . 0) q response-success?)) q (407 . 3)) ((c def c (c (? . 1) q update-project-orders)) q (4744 . 4)) ((c def c (c (? . 2) q delete-user)) q (1597 . 9)) ((c def c (c (? . 2) q register)) q (1227 . 11)) ((c def c (c (? . 0) q struct:response)) c (? . 3)) ((c def c (c (? . 1) q unarchive-project)) q (5155 . 4)) ((c def c (c (? . 4) q add-label)) q (5392 . 5)) ((c def c (c (? . 2) q get-productivity-stats)) q (3566 . 3)) ((c def c (c (? . 1) q archive-project)) q (5043 . 4)) ((c def c (c (? . 4) q update-label)) q (5532 . 5)) ((c def c (c (? . 1) q get-archived)) q (4974 . 3)) ((c def c (c (? . 2) q login-with-google)) q (585 . 13)) ((c def c (c (? . 2) q update-user)) q (1999 . 23)) ((c def c (c (? . 0) q response-headers)) c (? . 3)) ((c def c (c (? . 0) q response)) c (? . 3)) ((c def c (c (? . 2) q get-timezones)) q (1186 . 2)) ((c def c (c (? . 2) q get-redirect-link)) q (3332 . 7)) ((c def c (c (? . 1) q get-project)) q (3714 . 4)) ((c def c (c (? . 0) q response-body)) c (? . 3)) ((c def c (c (? . 1) q get-projects)) q (3645 . 3)) ((c def c (c (? . 4) q get-labels)) q (5269 . 4)) ((c def c (c (? . 4) q update-label-color)) q (5671 . 5)) ((c def c (c (? . 0) q ->jsexpr)) q (325 . 3)) ((c def c (c (? . 0) q response-status-line)) c (? . 3))))
struct
(struct response (status-line headers body))
  status-line : bytes?
  headers : list?
  body : string?
procedure
(parse-status-line status-line) -> string? integer? string?
  status-line : (or/c bytes? string?)
procedure
(response-status-code response) -> integer?
  response : response?
procedure
(->jsexpr x) -> jsexpr?
  x : (or/c response? string? bytes?)
procedure
(response-success? response) -> boolean?
  response : response?
procedure
(login email password) -> response?
  email : string?
  password : string?
procedure
(login-with-google  email                         
                    oauth2-token                  
                   [#:auto-signup auto-signup     
                    #:full-name full-name         
                    #:timezone timezone           
                    #:lang lang])             -> response?
  email : string?
  oauth2-token : string?
  auto-signup : string? = ""
  full-name : string? = ""
  timezone : string? = ""
  lang : string? = ""
procedure
(ping token) -> response?
  token : string?
procedure
(get-timezones) -> response?
procedure
(register  email                     
           full-name                 
           password                  
          [#:lang lang               
           #:timezone timezone]) -> response?
  email : string?
  full-name : string?
  password : string?
  lang : string? = ""
  timezone : string? = ""
procedure
(delete-user  token                                     
              current-password                          
             [#:reason-for-delete reason-for-delete     
              #:in-background in-background])       -> response?
  token : string?
  current-password : string?
  reason-for-delete : string? = ""
  in-background : integer? = 1
procedure
(update-user  token                                       
             [#:email email                               
              #:full-name full-name                       
              #:password password                         
              #:timezone timezone                         
              #:date-format date-format                   
              #:time-format time-format                   
              #:start-day start-day                       
              #:next-week next-week                       
              #:start-page start-page                     
              #:default-remainder default-remainder]) -> response?
  token : string?
  email : string? = ""
  full-name : string? = ""
  password : string? = ""
  timezone : string? = ""
  date-format : integer? = 0
  time-format : integer? = 0
  start-day : integer? = 1
  next-week : string? = ""
  start-page : string? = ""
  default-remainder : string? = ""
procedure
(update-avatar  token                 
               [#:image image         
                #:delete delete]) -> response?
  token : string?
  image : string? = ""
  delete : boolean? = #f
procedure
(get-redirect-link  token             
                   [#:path path       
                    #:hash hash]) -> response?
  token : string?
  path : string? = "/app"
  hash : string? = ""
procedure
(get-productivity-stats token) -> response?
  token : string?
procedure
(get-projects token) -> response?
  token : string?
procedure
(get-project token project-id) -> response?
  token : string?
  project-id : integer?
procedure
(add-project  name                
              token               
             [#:color color       
              #:indent indent     
              #:order order]) -> response?
  name : string?
  token : string?
  color : integer? = 0
  indent : integer? = 1
  order : integer? = 0
procedure
(update-project  project-id                
                 token                     
                [#:name name               
                 #:color color             
                 #:indent indent           
                 #:order order             
                 #:collapse collapse]) -> response?
  project-id : integer?
  token : string?
  name : string? = ""
  color : integer? = 0
  indent : integer? = 0
  order : integer? = 0
  collapse : integer? = 0
procedure
(update-project-orders token item-id-list) -> response?
  token : string?
  item-id-list : list?
procedure
(delete-project project-id token) -> response?
  project-id : integer?
  token : string?
procedure
(get-archived token) -> response?
  token : string?
procedure
(archive-project project-id token) -> response?
  project-id : integer?
  token : string?
procedure
(unarchive-project project-id token) -> response?
  project-id : integer?
  token : string?
procedure
(get-labels token [#:as-list? as-list?]) -> response?
  token : string?
  as-list? : integer? = 0
procedure
(add-label name token [#:color color]) -> response?
  name : string?
  token : string?
  color : string? = ""
procedure
(update-label old-name new-name token) -> response?
  old-name : string?
  new-name : string?
  token : string?
procedure
(update-label-color name color token) -> response?
  name : string?
  color : string?
  token : string?
procedure
(delete-label name token) -> response?
  name : string?
  token : string?
