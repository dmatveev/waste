Object subclass: ContentEntity [
    | timestamp |

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
    | text title tags comments |

    initialize [
        super initialize.
        comments := OrderedCollection new.
    ]

    comments [
        ^comments
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

ContentEntity subclass: BlogComment [
    | name email text |
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
                        tags at: eachTag put: (count + 1)]].
        ^tags
    ]
]

Object subclass: BlogStorage [
    | posts |

    posts [
        ^posts ifNil: [posts := OrderedCollection new]
    ]

    add: aPost [
        <category: 'accessing'>
        posts addFirst: aPost
    ]

    remove: aPost [
        <category: 'accessing'>
        posts remove: aPost
    ]

    export: aFileName [
        <category: 'serialization'>
        | dumper stream |
        stream := (File name: aFileName) writeStream.
        dumper := ObjectDumper on: stream.
        dumper dump: posts.
        stream close.
    ]

    import: aFileName [
        <category: 'serialization'>
        | dumper stream |
        stream := (File name: aFileName) readStream.
        dumper := ObjectDumper on: stream.
        posts := dumper load.
        stream close.
    ]
]
