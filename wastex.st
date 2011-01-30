Object extend [
    isWTCommandToken [
        <category: '*waste-testing'>
        "This is a kludge, I do not like it"
        ^false
    ]
]

Object subclass: WTToken [
]

WTToken subclass: WTNewlineToken [
    WTNewlineToken class >> inline [
        ^false
    ]
]

WTToken subclass: WTCommandToken [
    | command arguments |
    
    WTCommandToken class >> command: aString arguments: anotherString [
        <category: 'instance creation'>
        ^self new command: aString arguments: anotherString
    ]

    isWTCommandToken [
        <category: 'testing'>
        ^true
    ]

    isBegin [
        <category: 'testing'>
        ^command = 'begin'
    ]

    isEnd [
        <category: 'testing'>
        ^command = 'end'
    ]

    ends: aToken [
        <category: 'testing'>
        ^aToken isBegin and: [self isEnd and: [aToken arguments = arguments]]
    ]

    arguments [
        <category: 'accessors'>
        ^arguments
    ]

    inline [
        ^false
    ]

    command: aString arguments: anotherString [
        <category: 'private'>
        command   := aString.
        arguments := anotherString
    ]
]

Object subclass: WTCharacterMerger [
    | accum result |

    WTCharacterMerger class >> on: tokens [
        <category: 'instance creation'>
        ^(self new) init; optimize: tokens
    ]

    init [
        <category: 'initialization'>
        result := OrderedCollection new.
        accum  := OrderedCollection new.
    ]

    checkAccum [
        <category: 'private'>
        accum isEmpty ifFalse: 
            [result add: (PlainNode text: accum asString).
            accum empty]
    ]

    optimize: tokens [
        <category: 'optimizing'>
        tokens do:
            [:e |
            e isCharacter
                ifTrue: [accum add: e]
                ifFalse: [self checkAccum.
                      result add: e]].
        self checkAccum.
        ^result
    ]
]

Object subclass: WTBlockBuilder [
    | stack result |

    WTBlockBuilder class >> on: tokens [
        <category: 'instance creation'>
        ^(self new) init; optimize: tokens
    ]

    init [
        <category: 'initialization'>
        stack  := OrderedCollection new.
        result := OrderedCollection new.
    ]

    addToken: aToken [
        <category: 'private'>
        | r |
        r := stack isEmpty ifTrue: [result] ifFalse: [stack].
        r addLast: aToken
    ]

    rewind: aToken [
        <category: 'private'>
        | subnodes |
        subnodes := OrderedCollection new.
        [stack isEmpty] whileFalse:
            [| e |
            e := stack removeLast.
            e isWTCommandToken
                ifTrue: [(aToken ends: e)
                            ifTrue: [^self addToken:
                                         (WTParser nodeForCommand: e arguments
                                                   arguments: subnodes)]
                            ifFalse: [subnodes addFirst: e]]
                ifFalse: [subnodes addFirst: e]]
    ]
    
    optimize: tokens [
        <category: 'optimizing'>
        tokens do:
            [:e |
            e isWTCommandToken
                ifTrue: [e isBegin ifTrue: [stack addLast: e].
                         e isEnd   ifTrue: [self rewind: e]]
                ifFalse: [self addToken: e]].
        ^result
    ]
]

Object subclass: WTParagraphBuilder [
    | result cache |

    WTParagraphBuilder class >> on: tokens [
        <category: 'instance creation'>
        ^(self new) init; optimize: tokens
    ]

    init [
        <category: 'initialization'>
        result := OrderedCollection new.
        cache := OrderedCollection new.
    ]

    flushCache [
        <category: 'private'>
        cache isEmpty ifFalse: [result add: (ParagraphNode with: cache)]
    ]

    optimize: tokens [
        <category: 'optimizing'>
        tokens do:
            [:e |
            e inline ifTrue:  [cache add: e]
                     ifFalse: [self flushCache.
                               "The following line is BAD PRACTICE!"
                               e = WTNewlineToken ifFalse: [result add: e].
                               cache empty]].
        self flushCache.
        ^result
    ]
]

Object subclass: WTContentOptimizer [
    WTContentOptimizer class >> on: tokens [
        <category: 'instance creation'>
        ^self new optimize: tokens
    ]

    optimize: tokens [
        <category: 'optimizing'>
        ^WTCharacterMerger on: tokens.
    ]
]

Object subclass: WTParser [
    commands := nil.

    WTParser class >> commands [
        commands ifNil: [self setupCommands].
        ^commands
    ]
    
    WTParser class >> sign [
        <category: 'parsers'>
        ^$\ asParser, #letter asParser star flatten
    ]

    WTParser class >> arguments [
        <category: 'parsers'>
        | end inside |
        end := '}' asParser.
        inside := end not, #any asParser.
        ^'{' asParser, inside star flatten, end
            => [:t | t second]
    ]

    WTParser class >> command [
        <category: 'parsers'>
        ^self sign, self arguments optional
            => [:t | self nodeForCommand: t second arguments: t third]
    ]

    WTParser class >> linebreak [
        ^Character nl asParser, Character cr asParser optional
    ]

    WTParser class >> newline [
        <category: 'parsers'>
        ^self linebreak, self linebreak plus
            => [:t | WTNewlineToken]
    ]

    WTParser class >> verbatim [
        | end inside |
        end := '\end{verbatim}' asParser.
        inside := end not, #any asParser.
        ^'\begin{verbatim}' asParser, inside star flatten, end
            => [:t | PreformattedNode text: t second]
    ]

    WTParser class >> content [
        <category: 'parsers'>
        ^(self verbatim / self command / self newline negate / self newline) star
            => [:t || nodes |
                nodes := WTContentOptimizer on: t.
                nodes]
    ]

    WTParser class >> setupCommands [
        <category: 'private'>
        commands := Dictionary new.
        commands
            at: 'section'         put: [:arg | HeaderNode text: arg level: 1];
            at: 'subsection'      put: [:arg | HeaderNode text: arg level: 2];
            at: 'subsubsection'   put: [:arg | HeaderNode text: arg level: 3];
            at: 'enumerate'       put: [:arg | ListNode numeric: true  subnodes: arg];
            at: 'itemize'         put: [:arg | ListNode numeric: false subnodes: arg];
            at: 'item'            put: [:arg | ItemNode new];
            at: 'textbf'          put: [:arg | BoldNode text: arg];
            at: 'textit'          put: [:arg | ItalicNode text: arg];
            at: 'url'             put: [:arg | URLNode text: arg];
            at: 'verb'            put: [:arg | CodeNode text: arg];
            at: 'includegraphics' put: [:arg | ImageNode url: arg];
            at: 'caption'         put: [:arg | CaptionNode text: arg];
            at: 'html'            put: [:arg | RawNode text: arg]
    ]

    WTParser class >> nodeForCommand: aCommand arguments: args [
        <category: 'private'>
        | block |
        block := self commands
                    at: aCommand
                    ifAbsent: [^WTCommandToken command: aCommand arguments: args].
        ^block value: args
    ]

    WTParser class >> parse: aString [
        <category: 'functionality'>
        ^WTParagraphBuilder on: (WTBlockBuilder on: (self content parse: aString))
    ]
]
