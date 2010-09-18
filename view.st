BlogPost extend [
    renderTitleOn: html [
        <category: 'rendering-private'>
        html anchor
            callback: [(CommandHub command: #view) value: self];
            with: [html div
                       class: 'post-title';
                       with: [html text: title]]
    ]

    renderTimeStampOn: html [
        <category: 'rendering-private'>
        html div
            class: 'post-timestamp';
            with: [html text: 'Posted on'; space.
                   html anchor
                       callback: [(CommandHub command: #viewDate) value: self dated];
                       with: [html text: self dated printString].
                   html
                       space;
                       text: 'at'; space;
                       text: timestamp asTime printString]        
    ]

    renderTextOn: html [
        <category: 'rendering-private'>
        html div
            class: 'post-content';
            with: 
                [text linesDo:
                    [:each | each ifNotNil: [html paragraph
                                        class: 'post-text';
                                        with: each]]]
    ]

    renderTagsOn: html [
        <category: 'rendering-private'>
        html div
            class: 'post-tags';
            with:
                [| firstTag otherTags |
                firstTag := tags first.
                otherTags := tags allButFirst.
                
                html text: 'Tagged:'; space.

                "TODO: a Reusable tag component"
                html anchor
                    callback: [(CommandHub command: #viewTag) value: firstTag];
                    with: [html text: firstTag].

                otherTags do:
                    [:each |
                    html text: ','; space.
                    html anchor
                        callback: [(CommandHub command: #viewTag) value: firstTag];
                        with: [html text: each]]]
    ]

    renderActionsOn: html [
        <category: 'rendering-private'>
        html div
            class: 'post-actions';
            with:
                [html anchor
                     callback: [];
                     class: 'post-action';
                     with: [html text: 'Add a comment'].
                 html anchor
                     callback: [(CommandHub command: #edit) value: self];
                     class: 'post-action';
                     with: [html text: 'Edit'].
                 html anchor
                     callback: [(CommandHub command: #remove) value: self];
                     class: 'post-action';
                     with: [html text: 'Remove']].
    ]

    renderContentOn: html [
        <category: 'rendering'>
        html div
            class: 'post';
            with: [self renderTitleOn: html.
                   self renderTimeStampOn: html.
                   self renderTextOn: html.
                   self renderTagsOn: html.
                   self renderActionsOn: html]
    ]
]

Seaside.WASession subclass: BlogSession [
    | account |

    account [
        <category: 'accessing'>
        ^account
    ]

    account: anAccount [
        <category: 'accessing'>
        account := anAccount
    ]
]

Seaside.WAComponent subclass: BlogCommentPoster [
    | post |

    BlogCommentPoster class >> for: aPost [
        <category: 'instance creation'>
        ^self new for: aPost
    ]

    for: aPost [
        <category: 'private'>
        | commentClass aNewComment |
        commentClass := self session account
                                ifNil: [GuestComment]
                                ifNotNil: [AuthorComment].
        [true] whileTrue:
            [aNewComment := self call: commentClass new asComponent addValidatedForm.
             aNewComment ifNotNil: (post comment: aNewComment)]
        
    ]
]

Seaside.WAComponent subclass: BlogPostComponent [
    | post newCommentComponent |

    BlogPostComponent class >> for: aPost [
        <category: 'instance creation'>
        ^self new for: aPost
    ]

    for: aPost [
        <category: 'private'>
        post := aPost.
    ]
    
    renderContentOn: html [
        html anchor
            callback: (CommandHub command: #home);
            with: [html text: 'Back to posts'].
        post renderContentOn: html.
    ]
]

Seaside.WAComponent subclass: BlogTape [
    renderActionsOn: html [
        <category: 'rendering-private'>
        "TODO: a Decorator?"
        html anchor
            callback: (CommandHub command: #compose);
            with: [html text: 'Add a post'].
    ]

    renderContentOn: html [
        <category: 'rendering'>
        self renderActionsOn: html.
        html div
            class: 'tape';
            with: [self items do: [:each | each renderContentOn: html]]
    ]

    items [
        <category: 'private'>
        ^Storage posts
    ]
]

BlogTape subclass: FilteredBlogTape [
    | filterBlock |
    FilteredBlogTape class >> using: aFilterBlock [
        <category: 'instance creation'>
        ^self new filterBlock: aFilterBlock
    ]

    renderActionsOn: html [
        <category: 'rendering-private'>
        "TODO: a Decorator?"
        "TODO: Reusable 'Back to posts' component"
        html anchor
            callback: (CommandHub command: #home);
            with: [html text: 'Back to posts'].
    ]

    filterBlock: aFilterBlock [
        <category: 'private'>
        filterBlock := aFilterBlock
    ]

    items [
        <category: 'private'>
        ^super items select: filterBlock
    ]
]

Seaside.WAComponent subclass: BlogHeader [
    renderContentOn: html [
        <category: 'rendering'>
        html div
            class: 'header';
            with: [html text: 'TODO: Write your header here!']
    ]
]

Seaside.WAComponent subclass: BlogFooter [
    renderContentOn: html [
        <catogory: 'rendering'>
        html div
            class: 'footer';
            with: [html text: 'TODO: Write your footer here!']
    ]
]

Seaside.WAComponent subclass: BlogCloud [
    renderContentOn: html [
        <catogory: 'rendering'>
        html div 
            class: 'cloud';
            with: [Cloud tags keysAndValuesDo: [:eachKey :eachValue |
                html anchor
                    callback: [(CommandHub command: #viewTag) value: eachKey];
                    with: [html text: eachKey].
                html space; text: ('(', (eachValue asString), ')'); break]]
    ]
]

Seaside.WAComponent subclass: BlogApplication [
    | header footer tape cloud |

    BlogApplication class >> canBeRoot [
        <category: 'testing'>
        ^true
    ]

    initialize [
        <category: 'initialization'>
        super initialize.

        "We need to set up a command hub at first"
        CommandHub
            addCommand: #compose  block: [self compose];
            addCommand: #remove   block: [:aPost | self remove: aPost];
            addCommand: #view     block: [:aPost | self view: aPost];
            addCommand: #edit     block: [:aPost | self edit: aPost];
            addCommand: #home     block: [self goHome];
            addCommand: #viewTag  block: [:aTag | self viewTag: aTag];
            addCommand: #viewDate block: [:aDate | self viewDate: aDate].
        tape := BlogTape new.
        header := BlogHeader new.
        footer := BlogFooter new.
        cloud := BlogCloud new.
    ]

    compose [
        <category: 'functionality'>
        | aPost |
        aPost := tape call: (BlogPost new asComponent addValidatedForm).
        aPost ifNotNil: [Storage add: aPost]
    ]

    remove: aPost [
        <category: 'functionality'>
        (tape confirm: ('Are you sure you want to delete post "', aPost title, '"?'))
            ifTrue: [Storage remove: aPost]
    ]

    view: aPost [
        <category: 'functionality'>
        tape show: (BlogPostComponent for: aPost)
    ]

    viewTag: aTagString [
        <category: 'functionality'>
        tape show: (FilteredBlogTape using: [:aPost | aPost tagged includes: aTagString])
    ]

    viewDate: aDate [
        <category: 'functionality'>
        tape show: (FilteredBlogTape using: [:aPost | aPost dated = aDate])
    ]

    edit: aPost [
        <category: 'functionality'>
        tape show: (aPost asComponent addValidatedForm).
    ]

    goHome [
        <category: 'functionality'>
        tape home
    ]

    states [
        <category: 'seaside'>
        ^Array with: tape with: cloud
    ]

    children [
        <category: 'seaside'>
        ^Array with: tape with: cloud
    ]

    renderContentOn: html [
        <category: 'rendering'>
        html table:
            [html tableRow:
                [html tableData
                    colSpan: 2;
                    with: [html render: header]].
            html tableRow:
                [html tableData with: [html render: tape].
                html tableData with: [html render: cloud]].
            html tableRow:
                [html tableData
                    colSpan: 2;
                    with: [html render: footer]].
        ]
    ]
]
