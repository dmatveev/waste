" ------------------------------------------------------------------------------- "
"     TODO: Replace with your settings "
" ------------------------------------------------------------------------------- "

Eval [
    | app blog stat |

    app := BlogApplication registerAsApplication: 'waste'.
    app
        preferenceAt: #resourceBaseUrl put: '/';
        preferenceAt: #serverProtocol  put: #http;
        preferenceAt: #serverHostname  put: 'localhost';
        preferenceAt: #serverPath      put: '/';
	    preferenceAt: #serverPort      put: 8080;
        preferenceAt: #sessionClass    put: WasteSession.

    blog  := BlogSection name: 'Blog'  alias: #blog  storage: BlogStorage new.
    
    stat := StaticSection name: 'TODO: Change Me' alias: #staticDemo.
    stat text: 'This is an example of Static page'.

    WasteConf sections empty; addAll: {blog. stat}.
    WasteConf defaultSection: blog.

    WasteConf style:
        (BlogLibraryStyleStorage new
            on: app
            use: '/home/dmatveev/devel/waste/style.css').

    " or "
    " WasteConf style: "
    "     (BlogFileStyleStorage new "
    "         on: app "
    "         use: 'http://dmitrymatveev.co.uk/styles/blog.css'). "

    Seaside.WADispatcher default
        setName: '';
        defaultName: 'waste'
]

