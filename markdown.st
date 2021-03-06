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
            with: [aNode subnodes do: [:each | each accept: self]]
    ]

    visitPlainNode: aNode [
        html text: aNode text
    ]

    visitURLNode: aNode [
        html anchor
            url: aNode url;
            with: (aNode text ifNil: [aNode url]);
            class: ''
    ]

    visitListNode: aNode [
        | brush |
        brush := html perform: (aNode numeric ifTrue:  [#orderedList ]
                                              ifFalse: [#unorderedList ]).
        brush
            class: '';
            with: [aNode subnodes do: [:each | each accept: self]]
    ]

    visitItemNode: aNode [
        html html: '<li>'
    ]

    visitHeaderNode: aNode [
        html heading
            class: '';
            level: aNode level;
            with: aNode text
    ]

    visitBoldNode: aNode [
        "I have not found 'bold' message for html :D"
        html html: '<b>'; text: aNode text; html: '</b>'
    ]

    visitItalicNode: aNode [
        "I have not found 'italic' message for html :D"
        html html: '<i>'; text: aNode text; html: '</i>'
    ]

    visitPreformattedNode: aNode [
        html preformatted
            class: '';
            with: aNode text
    ]

    visitCodeNode: aNode [
        html code
            class: '';
            with: aNode text
    ]

    visitImageNode: aNode [
        html image
            class: '';
            url: aNode url
    ]

    visitCaptionNode: aNode [
        html div
            class: '';
            with: aNode text
    ]

    visitRawNode: aNode [
        html html: aNode text
    ]
]
