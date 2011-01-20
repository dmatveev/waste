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
    ParagraphNode class >> with: subnodes [
        ^self new addSubnodes: subnodes
    ]
    
    accept: aVisitor [
        aVisitor visitParagraphNode: self
    ]
]

ParseNode subclass: ItemListNode [
    | numeric |

    ItemListNode class >> numeric: aBoolean subnodes: anArray [
        ^self new
            numeric: aBoolean;
            addSubnodes: anArray;
            yourself
    ]

    numeric: aBoolean [
        numeric := aBoolean
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

ParseNode subclass: ItemNode [
]

PlainNode subclass: HeaderNode [
    | level |

    HeaderNode class >> text: aString level: anInteger [
        ^(self text: aString)
            level: anInteger;
            yourself
    ]
    
    level [
        ^level
    ]

    level: anInteger [
        level := anInteger
    ]
]
