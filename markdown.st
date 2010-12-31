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

Object subclass: MarkdownParser [
    MarkdownParser class >> paragraphParser [
        | end parser inside |
        end := Character nl asParser.
        parser := PP.PPUnresolvedParser new.
        inside := end not, self contentParser star.
        parser def: (inside, end).
        ^parser
            => [:nodes | self mergeNodes: nodes second]
    ]

    MarkdownParser class >> contentParser [
        ^(self urlParser / self plainParser), Character space asParser star 
            => [:nodes | nodes first]
    ]

    MarkdownParser class >> notSpaceParser [
        ^(Character space asParser / Character nl asParser) negate
    ]

    MarkdownParser class >> urlParser [
        ^('http://' asParser, self notSpaceParser plus) flatten
            => [:p | URLNode text: p]
    ]

    MarkdownParser class >> plainParser [
        ^self notSpaceParser plus flatten
            => [:p | PlainNode text: p]
    ]

    MarkdownParser class >> textParser [
        ^self paragraphParser star
            => [:nodes | nodes collect: [:e | ParagraphNode new addSubnodes: e]]
    ]

    MarkdownParser class >> mergeNodes: aCollection [
        | result lastNode |
        result := OrderedCollection new.
        aCollection do:
            [:each |
            ((lastNode isMemberOf: each class) and: [each canMerge])
                ifTrue:  [lastNode := lastNode merge: each]
                ifFalse: [lastNode ifNotNil: [result add: lastNode].
                          lastNode := each]].
        result add: lastNode.
        ^result asArray
    ]

    MarkdownParser class >> parse: aString [
        ^self textParser parse: aString
    ]
]

Object subclass: MarkdownBuilder [
    | html |

    MarkdownBuilder class >> on: html [
        ^self new html: html
    ]

    html: aCanvas [
        html := aCanvas
    ]

    visitParagraphNode: aNode [
        html paragraph
            class: '';
            with: [aNode subnodes do: [:each | each accept: self. html text: ' ']]
    ]

    visitPlainNode: aNode [
        html text: aNode text
    ]

    visitURLNode: aNode [
        html anchor
            url: aNode text;
            with: aNode text;
            class: ''
    ]
]
