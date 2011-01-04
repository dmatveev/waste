" ------------------------------------------------------------------------------- "
"     TODO: Replace with your settings "
" ------------------------------------------------------------------------------- "

Eval [
    | owner anon blog stat login |

    WasteConf
        init;
        proto: #http host: '192.168.1.113' port: 8080.

    owner := WasteAccount
             auth: (AuthInfo login: 'root' password: 'waste')
             rights: #(#canPost #canComment #canModerate).

    anon := AnonymousAccount new permissions: #(#canComment).

    WasteConf users add: owner.
    WasteConf defaultUser: anon.

    blog := BlogSection
            name: 'Blog'
            alias: #blog
            storage: (AutoMemoryBlogStorage new on: 'blog.bin').
    
    stat := HTMLSection
            name: 'TODO: Change Me'
            alias: #staticDemo.
    stat text: 'chop'.

    login := LoginSection
             name: 'Maintenance'
             alias: #maintenance.

    WasteConf sections addAll: {blog. stat. login}.
    WasteConf defaultSection: blog.

    WasteConf style: (BlogLibraryStyleStorage
    using: '/home/dmatveev/devel/waste/style.css').

    " or "
    " WasteConf style: (BlogFileStyleStorage "
    " using: 'http://dmitrymatveev.co.uk/styles/blog.css'). "
]
