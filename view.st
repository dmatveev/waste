Object subclass: MarkdownRenderer [
    | text html |

    MarkdownRenderer class >> text: aString on: aCanvas [
        <category: 'instance creation'>
        ^self new text: aString on: aCanvas
    ]

    text: aString on: aCanvas [
        <category: 'private'>
        text := aString.
        html := aCanvas
    ]

    render [
        | txt ast mdb |
        txt := (text last = Character nl)
                ifTrue:  [text]
                ifFalse: [text, Character nl asString].
        ast := MarkdownParser parse: txt.
        mdb := MarkdownBuilder on: html.
        ast do: [:each | each accept: mdb]
    ]
]

Object subclass: ContentEntityRenderer [
    | entity view html |

    ContentEntityRenderer class >> for: anEntity in: aView on: aCanvas [
        <category: 'instance creation'>
        ^self new for: anEntity in: aView on: aCanvas
    ]

    for: anEntity in: aView on: aCanvas [
        <category: 'private'>
        entity := anEntity.
        view := aView.
        html := aCanvas.
    ]

    render [
        <category: 'rendering'>
        html div
            class: self containerClass;
            with: [self renderMessages do: [:e | self perform: e]]
    ]

    renderMessages [
        <category: 'overriding'>
        self shouldNotImplement
    ]

    containerClass [
        <category: 'overriding'>
        self shouldNotImplement
    ]
]

ContentEntityRenderer subclass: BlogPostRenderer [
    renderMessages [
        <category: 'overriding'>
        ^#(#renderTitle #renderTimeStamp #renderText #renderTags #renderActions)
    ]

    containerClass [
        <category: 'overriding'>
        ^'post'
    ]

    renderTitle [
        <category: 'rendering-private'>
        html anchor
            url: '?section=', view section alias asString, '&id=', entity id asString;
            class: 'post-title';
            with: [html div
                       class: 'post-title';
                       with: [html text: entity title]]
    ]

    renderTimeStamp [
        <category: 'rendering-private'>
        html div
            class: 'post-timestamp';
            with: [html text: 'Posted on'; space.
                   html anchor
                       url: '?section=', view section alias asString,
                            '&date=', entity dated printString;
                       with: [html text: entity dated printString].
                   html
                       space;
                       text: 'at'; space;
                       text: entity timestamp asTime printString]
    ]

    renderText [
        <category: 'rendering-private'>
        html div
            class: 'post-content';
            with: [(MarkdownRenderer text: entity text on: html) render]
    ]

    renderTags [
        <category: 'rendering-private'>
        html div
            class: 'post-tags';
            with:
                [| firstTag otherTags |
                firstTag := entity tagged first.
                otherTags := entity tagged allButFirst.
                
                html text: 'Tagged:'; space.

                "TODO: introduce a Reusable tag component"
                html anchor
                    url: '?section=', view section alias asString, '&tag=', firstTag;
                    with: [html text: firstTag].

                otherTags do:
                    [:each |
                    html text: ','; space.
                    html anchor
                        url: '?section=', view section alias asString, '&tag=', each;
                        with: [html text: each]]]
    ]

    renderActions [
        <category: 'rendering-private'>
        html div
            class: 'post-actions';
            with:
                [html anchor
                     callback: [view composeCommentForPost: entity];
                     class: 'post-action';
                     with: [html text: 'Add a comment'].
                 html anchor
                     callback: [view edit: entity];
                     class: 'post-action';
                     with: [html text: 'Edit'].
                 html anchor
                     callback: [view remove: entity];
                     class: 'post-action';
                     with: [html text: 'Remove']].
    ]
]

ContentEntityRenderer subclass: BlogCommentRenderer [
    | post |

    BlogCommentRenderer class >> for: anEntity post: aPost in: aView on: aCanvas [
        <category: 'instance creation'>
        ^(self for: anEntity in: aView on: aCanvas)
            post: aPost;
            yourself
    ]

    post: aPost [
        <category: 'private'>
        post := aPost
    ]

    renderTitle [
        <category: 'rendering-private'>
        html div
            class: 'comment-header';
            with: [html anchor
                       url: 'mailto:', entity email;
                       with: [html text: entity name].
                   html text: ' commented on ', entity dated printString, ' at ',
                              entity timestamp asTime printString]
    ]

    renderText [
        <category: 'rendering-private'>
        html div
            class: 'comment-content';
            with: [(MarkdownRenderer text: entity text on: html) render]
    ]

    renderActions [
        <category: 'rendering-private'>
        html div
            class: 'comment-actions';
            with: [html anchor
                     callback: [view remove: entity of: post];
                     class: 'comment-action';
                     with: [html text: 'Remove']]
    ]
    renderMessages [
        <category: 'overriding'>
        ^#(#renderTitle #renderText #renderActions)
    ]

    containerClass [
        <category: 'overriding'>
        ^'comment'
    ]
]

Seaside.WAComponent subclass: BlogCommentTape [
    | post view |

    BlogCommentTape class >> for: aPost view: aView [
        <category: 'instance creation'>
        ^self new post: aPost view: aView
    ]

    post: aPost view: aView [
        <category: 'private'>
        post := aPost.
        view := aView
    ]

    renderContentOn: html [
        post comments do:
        [:e | (BlogCommentRenderer for: e post: post in: view on: html) render]
    ]
]

Seaside.WAComponent subclass: BlogPostComponent [
    | view post tape |

    BlogPostComponent class >> for: aPost view: aView [
        <category: 'instance creation'>
        ^self new for: aPost view: aView
    ]

    for: aPost view: aView [
        <category: 'private'>
        post := aPost.
        view := aView.
        tape := BlogCommentTape for: post view: view.
    ]
    
    renderContentOn: html [
        "TODO: Reusable Back to posts"
        html anchor
            url: '?section=', view section alias asString;
            with: [html text: 'Back to posts'].
        (BlogPostRenderer for: post in: view on: html) render.
        html render: tape
    ]

    tape [
        ^tape
    ]

    children [
        <category: 'seaside'>
        ^Array with: tape
    ]
]

Seaside.WAComponent subclass: BlogTape [
    | view |

    view: aView [
        <category: 'private'>
        view := aView
    ]

    renderActionsOn: html [
        <category: 'rendering-private'>
        "TODO: introduce a Decorator?"
        html anchor
            callback: [view compose];
            with: [html text: 'Add a post'].
    ]

    renderContentOn: html [
        <category: 'rendering'>
        self renderActionsOn: html.
        html div
            class: 'tape';
            with: [self items do:
                  [:each | (BlogPostRenderer for: each in: view on: html)
                           render]]
    ]

    items [
        <category: 'private'>
        ^view section storage posts
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
        "TODO: introduce a Decorator?"
        "TODO: Reusable 'Back to posts' component"
        html anchor
            url: '?section=', view section alias asString;
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
    | view |

    view: aView [
        view := aView
    ]

    renderContentOn: html [
        <catogory: 'rendering'>
        html div 
            class: 'cloud';
            with: [(Cloud tags: view section storage) keysAndValuesDo:
                    [:eachKey :eachValue |
                    html anchor
                        url: '?section=', view section alias asString, '&tag=', eachKey;
                        with: [html text: eachKey].
                    html space; text: ('(', (eachValue asString), ')'); break]]
    ]
]

Seaside.WAComponent subclass: BlogSections [
    | selected |

    initialize [
        <category: 'initialization'>
        super initialize.
        selected := WasteConf defaultSection.
    ]

    initialRequest: aRequest [
        <category: 'seaside'>
        super initialRequest: aRequest.
        aRequest at: 'section' ifPresent:
           [:section || sec |
            sec := WasteConf sections detect: [:e | e alias = section asSymbol].
            sec ifNotNil: [selected := sec]].
    ]

    renderSection: aSection on: html [
        <category: 'rendering-private'>
        aSection alias = selected alias
            ifTrue:  [html span
                        class: 'section-active';
                        with: [html text: aSection name]]
            ifFalse: [html anchor
                        url: '?section=', aSection alias asString;
                        class: 'section';
                        with: [html text: aSection name]]
    ]

    renderContentOn: html [
        <category: 'rendering'>
        WasteConf sections do: [:e | self renderSection: e on: html]
    ]
]

Seaside.WAComponent subclass: SectionView [
    | section |
    
    section: aSection [
        section := aSection
    ]

    section [
        ^section
    ]
]

SectionView subclass: BlogView [
    | tape cloud |

    initialize [
        <category: 'initialization'>
        super initialize.

        tape := BlogTape new view: self.
        cloud := BlogCloud new view: self.
    ]

    compose [
        <category: 'functionality'>
        | aPost |
        aPost := tape call: (BlogPost new asComponent addValidatedForm).
        aPost ifNotNil: [section storage add: aPost]
    ]

    composeCommentForPost: aPost [
        | postComponent comment |
        postComponent := BlogPostComponent for: aPost view: self.
        tape show: postComponent.
        comment := postComponent tape call: (BlogComment new asComponent addValidatedForm).
        comment ifNotNil: [aPost comment: comment.
                           section storage commit: aPost]
    ]

    remove: aPost [
        <category: 'functionality'>
        (tape confirm: ('Are you sure you want to delete post "', aPost title, '"?'))
            ifTrue: [section storage remove: aPost]
    ]

    remove: aComment of: aPost [
        <category: 'functionality'>
        (tape confirm: 'Are you sure you want to this comment?')
            ifTrue: [aPost remove: aComment.
                     section storage commit: aPost]
    ]

    view: aPost [
        <category: 'functionality'>
        tape show: (BlogPostComponent for: aPost view: self)
    ]

    viewTag: aTagString [
        <category: 'functionality'>
        tape show: ((FilteredBlogTape using:
                    [:aPost | aPost tagged includes: aTagString])
                        view: self)
    ]

    viewDate: aDate [
        <category: 'functionality'>
        tape show: ((FilteredBlogTape using:
                    [:aPost | aPost dated = aDate])
                        view: self)
    ]

    edit: aPost [
        <category: 'functionality'>
        | post |
        post := tape call: (aPost asComponent addValidatedForm).
        post ifNotNil: [section storage commit: post]
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

    initialRequest: aRequest [
        <category: 'seaside'>
        super initialRequest: aRequest.
        aRequest at: 'id' ifPresent:
            [:id | ^self view: (section storage posts detect: [:e | e id = id asInteger])]. 

        aRequest at: 'tag' ifPresent:
            [:tag | ^self viewTag: tag].

        aRequest at: 'date' ifPresent:
            [:date | ^self viewDate: (Date readFrom: date readStream)]
    ]

    renderContentOn: html [
        <category: 'rendering'>
        html table:
            [html tableRow:
                [html tableData class: 'blog-content';
                                with: [html render: tape].
                 html tableData with: [html render: cloud]]]
    ]
]

SectionView subclass: StaticView [
    renderContentOn: html [
        <category: 'rendering'>
        html div
            class: 'static-text';
            with: [(MarkdownRenderer text: section text on: html) render]
    ]
]

Seaside.WAComponent subclass: BlogApplication [
    | header body footer sections |

    BlogApplication class >> canBeRoot [
        <category: 'testing'>
        ^true
    ]

    initialize [
        <category: 'initialization'>
        super initialize.
        self session blog: self.

        header   := BlogHeader new.
        footer   := BlogFooter new.
        sections := BlogSections new.
        self open: WasteConf defaultSection
    ]

    open: aSection [
        | view |
        view := aSection view.
        body ifNil: [body := view] ifNotNil: [body show: view]
    ]

    updateRoot: anHtmlRoot [
        <category: 'seaside'>
        super updateRoot: anHtmlRoot.
        WasteConf style writeStyleOn: anHtmlRoot
    ]

    initialRequest: aRequest [
        <category: 'seaside'>
        super initialRequest: aRequest.
        aRequest at: 'section' ifPresent:
           [:section || sec |
            sec := WasteConf sections detect: [:e | e alias = section asSymbol].
            sec ifNotNil: [self open: sec]].
        aRequest at: 'section' ifAbsent: [self open: WasteConf defaultSection]
    ]

    renderContentOn: html [
        <category: 'rendering'>
        html table
            class: 'content'; with:
                [html tableRow: [html tableData: [html render: header]].
                 html tableRow: [html tableData
                                     class: 'sections';
                                     with: [html render: sections]].
                 html tableRow: [html tableData: [html render: body]].
                 html tableRow: [html tableData: [html render: footer]]]
    ]

    states [
        <category: 'seaside'>
        ^Array with: sections with: body
    ]

    children [
        <category: 'seaside'>
        ^Array with: sections with: body
    ]
]
