" ------------------------------------------------------------------------------- "
"     TODO: Replace with your settings "
" ------------------------------------------------------------------------------- "

Eval [
    | blog stat |

    WasteConf
        init;
        proto: #http host: 'localhost' port: 8080.

    blog := BlogSection
            name: 'Blog'
            alias: #blog
            storage: (AutoMemoryBlogStorage new on: 'blog.bin').
    
    stat := HTMLSection
            name: 'TODO: Change Me'
            alias: #staticDemo.
    stat text: '<b>Hello!</b> Yep'.

    WasteConf sections empty; addAll: {blog. stat}.
    WasteConf defaultSection: blog.

    WasteConf style: (BlogLibraryStyleStorage
                      using: '/home/dmatveev/devel/waste/style.css').

    " or "
    " WasteConf style: (BlogFileStyleStorage "
    "                   using: 'http://dmitrymatveev.co.uk/styles/blog.css'). "
]
