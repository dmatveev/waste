Seaside.WAFileLibrary subclass: CustomFileLibrary [
    stylesheet := ''.

    CustomFileLibrary class >> stylesheet: aString [
        <category: 'accessors'>
        stylesheet := aString
    ]

    styleCss [
        <category: 'accessors'>
        ^stylesheet
    ]

    selectorsToInclude [
        <category: 'accessors'>
        ^Array with: #styleCss
    ]
]

Object subclass: BlogLibraryStyleStorage [
    on: anApp use: aFileName [
        <category: 'style storage-private'>
        CustomFileLibrary stylesheet: (File name: aFileName) readStream contents.
        anApp preferenceAt: #libraries put: (Array with: CustomFileLibrary)
    ]

    writeStyleOn: aHTMLRoot [
        <category: 'style storage'>
        ^self
    ]
]

Object subclass: BlogFileStyleStorage [
    | url |

    on: anApp use: aFileName [
        <category: 'style storage-private'>
        url := aFileName
    ]

    writeStyleOn: aHTMLRoot [
        <category: 'style storage'>
        aHTMLRoot stylesheet url: url
    ]
]

Object subclass: WasteConf [
    style := nil.

    WasteConf class >> style: aStyleStore [
        <category: 'accessors'>
        style := aStyleStore
    ]

    WasteConf class >> style [
        <category: 'accessors'>
        ^style
    ]
]
