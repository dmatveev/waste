"-------------------------------------------------------------------------------
    TODO: Replace with your settings
-------------------------------------------------------------------------------"

Eval [
    | app |

    app := BlogApplication registerAsApplication: 'waste'.
    app
        preferenceAt: #resourceBaseUrl put: '/';
        preferenceAt: #serverProtocol  put: #http;
        preferenceAt: #serverHostname  put: '192.168.1.113';
        preferenceAt: #serverPath      put: '/';
	    preferenceAt: #serverPort      put: 8080;
        preferenceAt: #sessionClass    put: WasteSession;
        preferenceAt: #mainClass       put: WasteRenderLoop.

    WasteConf style:
        (BlogLibraryStyleStorage new
            on: app
            use: '/home/dmatveev/devel/waste/style.css').

    "or"
    " WasteConf style: "
    "     (BlogFileStyleStorage new "
    "         on: app "
    "         use: 'http://dmitrymatveev.co.uk/styles/blog.css'). "

    Seaside.WADispatcher default
        setName: '';
        defaultName: 'waste'
]

