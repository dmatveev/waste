Object subclass: Section [
    | name alias storage |

    Section class >> name: aString alias: anotherString [
        <category: 'instance creation'>
        ^self new name: aString alias: anotherString storage: nil; yourself
    ]

    Section class >> name: aString alias: anotherString storage: aStorage  [
        <category: 'instance creation'>
        ^self new name: aString alias: anotherString storage: aStorage; yourself
    ]

    name: aString alias: anotherString storage: aStorage [
        <category: 'private'>
        name  := aString.
        alias := anotherString.
        storage := aStorage
    ]

    name [
        <category: 'accessing'>
        ^name
    ]

    alias [
        <category: 'accessing'>
        ^alias
    ]

    view [
        <category: 'accessing'>
        self shouldNotImplement
    ]
    
    storage [
        <category: 'accessing'>
        ^storage
    ]
]

Section subclass: LoginSection [
    view [
        <category: 'accessing'>
        ^LoginView new section: self
    ]
]

Section subclass: BlogSection [
    view [
        <category: 'accessing'>
        ^BlogView new section: self
    ]
]

Section subclass: StaticSection [
    | text |

    text: aString [
        text := aString
    ]

    text [
        ^text
    ]
    
    view [
        <category: 'accessing'>
        ^self viewClass new section: self
    ]

    viewClass [
        self shouldNotImplement
    ]
]

StaticSection subclass: MarkdownSection [
    viewClass [
        ^MarkdownView
    ]
]

StaticSection subclass: HTMLSection [
    viewClass [
        ^HTMLView
    ]
]
