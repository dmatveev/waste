Object subclass: Storage [
    posts := OrderedCollection new.

    Storage class >> posts [
        <category: 'accessing'>
        ^posts
    ]
]

BlogPost extend [
    renderContentOn: html [
        <category: 'rendering'>
        html heading: title.
        html paragraph: timestamp printString.
        html paragraph: text.
    ]
]


Seaside.WAComponent subclass: BlogTape [
    renderContentOn: html [
        Storage posts do: [:each | each renderContentOn: html]
    ]
]

Seaside.WAComponent subclass: BlogHeader [
    renderContentOn: html [
        <category: 'rendering'>
        html heading: 'Please rewrite me!'
    ]
]

Seaside.WAComponent subclass: BlogFooter [
    renderContentOn: html [
        html small: 'Please rewrite me!'
    ]
]

Seaside.WAComponent subclass: BlogCanvas [
    | header footer tape |

    BlogCanvas class >> canBeRoot [
        <category: 'testing'>
        ^true
    ]

    initialize [
        <category: 'initialization'>
        super initialize.
        tape := BlogTape new.
        header := BlogHeader new.
        footer := BlogFooter new.
    ]

    renderContentOn: html [
        <category: 'rendering'>
        html table: [
            html tableRow: [
                html tableData
                    colSpan: 2;
                    with: [html render: header]].
            html tableRow: [
                html tableData with: [html render: tape].
                html tableData with: [html text: 'Rising']].
            html tableRow: [
                html tableData
                    colSpan: 2;
                    with: [html render: footer]].
        ]
    ]
]

BlogCanvas registerAsApplication: 'blog'
