Seaside.WAFileLibrary subclass: SeasideFiles [
    stylesheet := ''.

    SeasideFiles class >> stylesheet: aString [
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

Object subclass: BlogStyleStorage [
    BlogStyleStorage class >> using: aFilename [
        <category: 'instance creation'>
        ^self new using: aFilename
    ]

    using: aFilename [
        self shouldNotImplement
    ]
]

BlogStyleStorage subclass: BlogLibraryStyleStorage [
    using: aFileName [
        <category: 'style storage-private'>
        SeasideFiles stylesheet: (File name: aFileName) readStream contents.
    ]

    app: anApp [
        anApp preferenceAt: #libraries put: (Array with: SeasideFiles)
    ]

    writeStyleOn: aHTMLRoot [
        <category: 'style storage'>
        ^self
    ]
]

BlogStyleStorage subclass: BlogFileStyleStorage [
    | url |

    using: aFileName [
        <category: 'style storage-private'>
        url := aFileName
    ]

    app: anApp [
    ]

    writeStyleOn: aHTMLRoot [
        <category: 'style storage'>
        aHTMLRoot stylesheet url: url
    ]
]

Object subclass: WasteConf [
    app            := nil.
    style          := nil.
    sections       := OrderedCollection new.
    defaultSection := nil.
    header         := 'TODO: Write your header here!'.
    subheader      := 'TODO: Write your subheader here!'.
    footer         := 'TODO: Write your footer here!'.

    WasteConf class >> header: aString [
        header := aString
    ]

    WasteConf class >> subheader: aString [
        header := aString
    ]
    
    WasteConf class >> footer: aString [
        footer := aString
    ]

    WasteConf class >> header [
        ^header
    ]

    WasteConf class >> subheader [
        ^subheader
    ]

    WasteConf class >> footer [
        ^footer
    ]

    WasteConf class >> style: aStyleStore [
        <category: 'accessors'>
        style := aStyleStore.
        style app: app
    ]

    WasteConf class >> style [
        <category: 'accessors'>
        ^style
    ]

    WasteConf class >> sections [
        <category: 'accessors'>
        ^sections
    ]

    WasteConf class >> defaultSection [
        <category: 'accessors'>
        ^defaultSection
    ]

    WasteConf class >> defaultSection: aSection [
        <category: 'accessors'>
        defaultSection := aSection
    ]

    WasteConf class >> init [
        app := BlogApplication registerAsApplication: 'waste'.
        app preferenceAt: #sessionClass put: WasteSession.

        Seaside.WADispatcher default
            setName: '';
            defaultName: 'waste'
    ]
    
    WasteConf class >> proto: aSymbol host: aHost port: anInteger [
        ^self proto: aSymbol host: aHost port: anInteger
              svcPath: '/' rcPath: '/'
    ]
    
    WasteConf class >> proto: aSymbol host: aHost port: anInteger
                       svcPath: anSvcPath rcPath: anRCPath [
        app
            preferenceAt: #resourceBaseUrl put: anRCPath;
            preferenceAt: #serverProtocol  put: aSymbol;
            preferenceAt: #serverHostname  put: aHost;
            preferenceAt: #serverPath      put: anSvcPath;
            preferenceAt: #serverPort      put: anInteger
    ]
]
