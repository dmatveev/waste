Object subclass: BlogPost [
    | text title timestamp tags comments |

    BlogPost class >> title: aTitle text: aString tagged: aCollection [
        <category: 'instance creation'>
        ^(self basicNew)
            title: aTitle text: aString tagged: aCollection;
            yourself
    ]

    title: aTitle text: aString tagged: aCollection [
        <category: 'private'>
        text := aString.
        tags := aCollection.
        title := aTitle. 
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
