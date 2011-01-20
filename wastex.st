Object subclass: WTParser [
    WTParser class >> signParser [
        <category: 'parsers'>
        ^$\ asParser, #letter asParser star flatten
    ]

    WTParser class >> argumentsParser [
        <category: 'parsers'>
        | end inside |
        end := '}' asParser.
        inside := end not, #any asParser.
        ^'{' asParser, inside star flatten, end.
    ]

    WTParser class >> commandParser [
        <category: 'parsers'>
        ^self signParser, self argumentsParser optional
    ]

    WTParser class >> newlineParser [
        <category: 'parsers'>
        ^Character nl asParser, Character nl asParser plus
    ]

    WTParser class >> contentParser [
        <category: 'parsers'>
        ^self commandParser / self newlineParser negate
    ]

    WTParser class >> paragraphParser [
        <category: 'parsers'>
        ^self contentParser / self newlineParser
    ]

    WTParser class >> mainParser [
        <category: 'parsers'>
        ^(self commandParser / #any asParser star flatten) star
    ]
]
