"------------------------------------------------------------
    Not a very good OO solution, but it is enough for a
    firdt time.
------------------------------------------------------------"

Object subclass: AuthInfo [
    | login password |

    AuthInfo class >> login: aLogin password: aPassword [
        ^self new
            login: aLogin;
            password: aPassword;
            yourself
    ]

    = anAuth [
        ^login = anAuth login and: [password = anAuth password]
    ]

    login: aLogin [
        login := aLogin.
    ]

    login [
        ^login
    ]

    password: aPassword [
        password := aPassword
    ]

    password [
        ^password
    ]
]

Object subclass: WasteAccount [
    | auth permissions |

    WasteAccount class >> auth: auth rights: aRights [
        ^self new
            auth: auth;
            permissions: aRights;
            yourself
    ]

    auth: authInfo [
        auth := authInfo
    ]
    
    auth [
        ^auth
    ]

    permissions: anArray [
        permissions := anArray
    ]

    permissions [
        ^permissions
    ]
]

WasteAccount subclass: AnonymousAccount [
]
