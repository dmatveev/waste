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
    
    stat := StaticSection
            name: 'TODO: Change Me'
            alias: #staticDemo.
    stat text: 'This is an example of Static page'.

    WasteConf sections empty; addAll: {blog. stat}.
    WasteConf defaultSection: blog.

    WasteConf style: (BlogLibraryStyleStorage
                      using: '/home/dmatveev/devel/waste/style.css').

    " or "
    " WasteConf style: (BlogFileStyleStorage "
    "                   using: 'http://dmitrymatveev.co.uk/styles/blog.css'). "
]
