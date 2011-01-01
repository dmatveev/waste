Object subclass: BlogPost [
    | text title timestamp tags comments |

    BlogPost class >> new [
        ^ self basicNew initialize
    ]

    initialize [
        timestamp := DateTime now.
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

    dated [
        <category: 'accessing'>
        ^timestamp asDate
    ]
]

Object subclass: BlogComment [
    | name email text timestamp |
    
    BlogComment class >> new [
        ^self basicNew initialize
    ]

    initialize [
        timestamp := DateTime now.
    ]

    dated [
        <category: 'accessing'>
        ^timestamp asDate
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

Object subclass: Storage [
    posts := OrderedCollection new.

    Storage class >> posts [
        <category: 'accessing'>
        ^posts
    ]

    Storage class >> add: aPost [
        <category: 'accessing'>
        posts addFirst: aPost
    ]

    Storage class >> remove: aPost [
        <category: 'accessing'>
        posts remove: aPost
    ]

    Storage class >> export: aFileName [
        <category: 'serialization'>
        | dumper stream |
        stream := (File name: aFileName) writeStream.
        dumper := ObjectDumper on: stream.
        dumper dump: posts.
        stream close.
    ]

    Storage class >> import: aFileName [
        <category: 'serialization'>
        | dumper stream |
        stream := (File name: aFileName) readStream.
        dumper := ObjectDumper on: stream.
        posts := dumper load.
        stream close.
    ]
]
