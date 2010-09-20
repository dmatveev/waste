"-------------------------------------------------------------------------------
    TODO: Replace with your settings
-------------------------------------------------------------------------------"

Eval [
    | app |
    app := BlogApplication registerAsApplication: 'waste'.
    app
        preferenceAt: #libraries put: (Array with: BlogData);
        preferenceAt: #serverProtocol put: 'http';
        preferenceAt: #serverHostname put: 'localhost';
        preferenceAt: #serverPath put: '/blog'.
]
