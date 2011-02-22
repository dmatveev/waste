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
    | command options arguments |
    
    WTCommandToken class >> command: aString options: aString2 arguments: aString3 [
        <category: 'instance creation'>
        ^self new command: aString options: aString2 arguments: aString3
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

    command: aString options: aString2 arguments: aString3 [
        <category: 'private'>
        command   := aString.
        options   := aString2.
        arguments := aString3.
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
                               "The following line is a BAD PRACTICE!"
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

    WTParser class >> options [
        | end inside |
        end := ']' asParser.
        inside := end not, #any asParser.
        ^'[' asParser, inside star flatten, end
            => [:t | t second]
    ]

    WTParser class >> command [
        <category: 'parsers'>
        ^self sign, self options optional, self arguments optional
            => [:t | self nodeForCommand: t second
                          options: t third
                          arguments: t fourth]
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

    WTParser class >> verb [
        | end inside |
        end := $! asParser.
        inside := end not, #any asParser.
        ^'\verb!' asParser, inside star flatten, end
            => [:t | CodeNode text: t second]
    ]

    WTParser class >> quote [
        ^('``' asParser / '''''' asParser)
            => [:t | $"]
    ]

    WTParser class >> content [
        <category: 'parsers'>
        ^(self verbatim / self verb / self command / self quote /
          self newline negate / self newline) star
            => [:t || nodes |
                nodes := WTContentOptimizer on: t.
                nodes]
    ]

    WTParser class >> setupCommands [
        <category: 'private'>
        commands := Dictionary new.
        commands
            at: 'section'         put: [:o :a | HeaderNode text: a level: 1];
            at: 'subsection'      put: [:o :a | HeaderNode text: a level: 2];
            at: 'subsubsection'   put: [:o :a | HeaderNode text: a level: 3];
            at: 'enumerate'       put: [:o :a | ListNode numeric: true  subnodes: a];
            at: 'itemize'         put: [:o :a | ListNode numeric: false subnodes: a];
            at: 'item'            put: [:o :a | ItemNode new];
            at: 'textbf'          put: [:o :a | BoldNode text: a];
            at: 'textit'          put: [:o :a | ItalicNode text: a];
            at: 'url'             put: [:o :a | URLNode text: o url: a];
            at: 'verb'            put: [:o :a | CodeNode text: a];
            at: 'includegraphics' put: [:o :a | ImageNode url: a];
            at: 'caption'         put: [:o :a | CaptionNode text: a];
            at: 'html'            put: [:o :a | RawNode text: a]
    ]

    WTParser class >> nodeForCommand: aCommand options: opts arguments: args [
        <category: 'private'>
        | block |
        block := self commands
            at: aCommand
            ifAbsent: [^WTCommandToken command: aCommand
                                       options: opts
                                       arguments: args].
        ^block value: opts value: args
    ]

    WTParser class >> parse: aString [
        <category: 'functionality'>
        ^WTParagraphBuilder on: (WTBlockBuilder on: (self content parse: aString))
    ]
]


Eval [
    WTParser setupCommands
]
