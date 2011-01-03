Seaside.WASession subclass: WasteSession [
    | blog |

    blog [
        ^blog
    ]

    blog: aBlog [
        blog := aBlog
    ]

    returnResponse: aResponse [
        " (self currentRequest cookieAt: self application handlerCookieName)  "
        "     ifNil: [ aResponse addCookie: self sessionCookie ]. "
        ^super returnResponse: aResponse
    ]

    actionUrlForKey: aString [
        | url |
        url := super actionUrlForKey: aString.
        " (self currentRequest cookieAt: self application handlerCookieName)  "
        "     ifNotNil: [ url parameters removeKey: self application handlerField ]. "
        ^url
    ]
]
