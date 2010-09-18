Object subclass: BlogPost [
    | text title timestamp tags comments |

    BlogPost class >> new [
        ^ self basicNew initialize
    ]

    initialize [
        timestamp := DateTime now.
        comments := OrderedCollection new.
    ]

    comment: aComment [
        <category: 'comments'>
        comments add: aComment
    ]

    remove: aComment [
        <category: 'comments'>
        comments remove: aComment
    ]

    tagged [
        <category: 'accessing'>
        ^tags
    ]
]

Object subclass: BlogComment [
    | text timestamp |

    BlogComment class >> text: aString [
        <category: 'instance creation'>
        ^(self basicNew)
            text: aString;
            yourself
    ]

    text: aString [
        <category: 'private'>
        text := aString.
        timestamp := DateTime today.
    ]
]

BlogComment subclass: AuthorComment [
]

BlogComment subclass: GuestComment [
    | name email www |
    
    GuestComment class >> name: aName email: aMail www: aWebsite text: aString [
        <category: 'instance creation'>
        ^(self text: aString)
            name: aName email: aMail www: aWebsite;
            yourself
    ]

    name: aName email: aMail www: aWebsite [
        <category: 'private'>
        name := aName.
        email := aMail.
        www := aWebsite.
    ]
]

Object subclass: Storage [
    posts := OrderedCollection new.

    Storage class >> posts [
        <category: 'accessing'>
        ^posts
    ]
]

Object subclass: CommandHub [
    commands := Dictionary new.

    CommandHub class >> addCommand: aNameSymbol block: aBlock [
        <category: 'functionality'>
        ^commands at: aNameSymbol put: aBlock
    ]

    CommandHub class >> command: aNameSymbol [
        ^commands at: aNameSymbol
    ]
]

Object subclass: Cloud [
    Cloud class >> tags [
        <category: 'accessing'>
        | tags |
        tags := Dictionary new.
        Storage posts do:
            [:eachPost |
                eachPost tagged do:
                    [:eachTag || count |
                        count := tags at: eachTag ifAbsentPut: [0].
                        tags at: eachTag put: (count + 1)]].
        ^tags
    ]
]
