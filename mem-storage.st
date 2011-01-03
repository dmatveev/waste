Object subclass: MemoryBlogStorage [
    | posts |

    posts [
        ^posts ifNil: [posts := OrderedCollection new]
    ]

    add: aPost [
        <category: 'accessing'>
        posts isEmpty
            ifTrue: [aPost id: 0]
            ifFalse: [aPost id: posts first id + 1].
        posts addFirst: aPost.
        self commit: aPost
    ]

    remove: aPost [
        <category: 'accessing'>
        posts remove: aPost.
        self commit: aPost
    ]

    commit: aPost [
        <category: 'functionality'>
    ]
]

MemoryBlogStorage subclass: AutoMemoryBlogStorage [
    | path |

    on: aPath [
        path := aPath.
        self import: path
    ]

    commit: aPost [
        self export: path
    ]

    export: aFileName [
        <category: 'serialization'>
        | dumper stream |
        [stream := (File name: aFileName) writeStream.
         dumper := ObjectDumper on: stream.
         dumper dump: posts.
         stream close] ifError: [Transcript << 'Oops'; nl]
    ]

    import: aFileName [
        <category: 'serialization'>
        | dumper stream |
        [stream := (File name: aFileName) readStream.
         dumper := ObjectDumper on: stream.
         posts := dumper load.
         stream close] ifError: [Transcript << 'Oops'; nl]
    ]
]
