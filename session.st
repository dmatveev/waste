Seaside.WASession subclass: WasteSession [
    | blog user |

    blog [
        ^blog
    ]

    blog: aBlog [
        blog := aBlog
    ]

    user: aUser [
        user := aUser
    ]

    user [
        ^user ifNil: [user := WasteConf defaultUser]
    ]

    loggedIn [
        <category: 'testing'>
        ^(self user == WasteConf defaultUser) not
    ]

    start: aRequest [
        | cookie |
        cookie := aRequest cookies at: 'sessionid' ifAbsent: [nil].
        cookie ifNotNil:
        [| tokens login hash user |
         tokens := cookie tokenize: ':'.
         login  := tokens first.
         hash   := tokens second.
         user   := [WasteConf users detect: [:e | e auth login = login]] ifError: [nil].
         user ifNotNil:
            [(MD5 new: user auth password) hexDigest = hash ifTrue: [self user: user]]].
        ^self mainClass new start: aRequest.
    ]

    returnResponse: aResponse [
        " (self currentRequest cookieAt: self application handlerCookieName) "
        "     ifNil: [ aResponse addCookie: self sessionCookie ]. "
        ^super returnResponse: aResponse
    ]

    actionUrlForKey: aString [
        | url |
        url := super actionUrlForKey: aString.
        " (self currentRequest cookieAt: self application handlerCookieName) "
        "     ifNotNil: [ url parameters removeKey: self application handlerField ]. "
        ^url
    ]
]
