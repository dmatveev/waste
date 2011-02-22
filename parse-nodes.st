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

    inline [
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

ParseNode subclass: ListNode [
    | numeric |

    ListNode class >> numeric: aBoolean subnodes: anArray [
        ^self new
            numeric: aBoolean;
            addSubnodes: anArray;
            yourself
    ]

    numeric: aBoolean [
        numeric := aBoolean
    ]

    numeric [
        ^numeric
    ]

    accept: aVisitor [
        aVisitor visitListNode: self
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

    inline [
        ^true
    ]
]

PlainNode subclass: URLNode [
    | url |
    
    URLNode class >> text: aString url: anotherString [
        ^(self text: aString)
            url: anotherString;
            yourself
    ]

    url: aString [
        url := aString
    ]

    url [
        ^url
    ]

    accept: aVisitor [
        aVisitor visitURLNode: self
    ]
]

ParseNode subclass: ItemNode [
    accept: aVisitor [
        aVisitor visitItemNode: self
    ]
]

PlainNode subclass: BoldNode [
    accept: aVisitor [
        aVisitor visitBoldNode: self
    ]
]

PlainNode subclass: ItalicNode [
    accept: aVisitor [
        aVisitor visitItalicNode: self
    ]
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

    inline [
        ^false
    ]

    accept: aVisitor [
        aVisitor visitHeaderNode: self
    ]
]

PlainNode subclass: PreformattedNode [
    accept: aVisitor [
        aVisitor visitPreformattedNode: self
    ]
]

PlainNode subclass: CodeNode [
    accept: aVisitor [
        aVisitor visitCodeNode: self
    ]
]

ParseNode subclass: ImageNode [
    | url |

    ImageNode class >> url: aString [
        ^self new url: aString; yourself
    ]

    url: aString [
        url := aString
    ]

    url [
        ^url
    ]

    accept: aVisitor [
        aVisitor visitImageNode: self
    ]
]

PlainNode subclass: CaptionNode [
    accept: aVisitor [
        aVisitor visitCaptionNode: self
    ]

    inline [
        ^false
    ]
]

PlainNode subclass: RawNode [
    accept: aVisitor [
        aVisitor visitRawNode: self
    ]
]
