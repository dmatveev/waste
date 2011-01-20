Object subclass: ParseNode [
    | subnodes |

    subnodes [
        ^subnodes ifNil: [subnodes := OrderedCollection new]
    ]

    addSubnodes: aCollection [
        self subnodes addAll: aCollection
    ]

    canMerge [
        ^false
    ]

    merge: aNode [
    ]

    accept: aVisitor [
        self shouldNotImplement
    ]
]

ParseNode subclass: ParagraphNode [
    accept: aVisitor [
        aVisitor visitParagraphNode: self
    ]
]

ParseNode subclass: PlainNode [
    | text |
    
    PlainNode class >> text: aString [
        ^self new text: aString
    ]

    text: aString [
        text := aString
    ]

    text [
        ^text
    ]

    canMerge [
        ^true
    ]

    merge: aNode [
        ^PlainNode text: text, ' ', aNode text
    ]

    accept: aVisitor [
        aVisitor visitPlainNode: self
    ]
]

PlainNode subclass: URLNode [
    accept: aVisitor [
        aVisitor visitURLNode: self
    ]
]
