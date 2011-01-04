Object subclass: ContentEntity [
    | id timestamp |

    ContentEntity class >> new [
        <category: 'instance creation'>
        ^self basicNew initialize
    ]

    initialize [
        timestamp := DateTime now
    ]

    timestamp [
        ^timestamp
    ]

    dated [
        <category: 'accessing'>
        ^timestamp asDate
    ]
]

ContentEntity subclass: BlogPost [
    | id text title tags comments |

    initialize [
        <category: 'initialization'>
        super initialize.
        comments := OrderedCollection new
    ]

    id: anInteger [
        id := anInteger
    ]

    id [
        ^id
    ]

    tagged [
        <category: 'accessing'>
        ^tags
    ]
   
    comments [
        ^comments
    ]

    comment: aComment [
        comments add: aComment
    ]

    remove: aComment [
        comments remove: aComment
    ]
]

ContentEntity subclass: BlogComment [
    | name email text replyOn |

    replyOn: aComment [
        replyOn := aComment
    ]

    replyOn [
        ^replyOn
    ]
]

Object subclass: Cloud [
    Cloud class >> tags: storage [
        <category: 'accessing'>
        | tags |
        tags := Dictionary new.
        storage posts do:
            [:eachPost |
                eachPost tagged do:
                    [:eachTag || count |
                        count := tags at: eachTag ifAbsentPut: [0].
                        tags at: eachTag put: count + 1]].
        ^tags
    ]
]
