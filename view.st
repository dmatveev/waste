"-------------------------------------------------------------------------------
    Yes. Domain object knows how to render it on html. Looks ugly? But now
    BlogPost is almost the only class that deals with the post's inner
    representation.

    I could introduce an additional BlogPostRenderer to generate html from
    domain objects, but it requires a set of accessor methods in the BlogPost.

    I do not like accessors (but a BlogPost _has_ it, see 'descriptors.st' -
    they are used only for Magritte).
 ------------------------------------------------------------------------------"

BlogPost extend [
    renderTitleOn: html session: aSession [
        <category: 'rendering-private'>
        html anchor
            callback: [aSession blog view: self];
            class: 'post-title';
            with: [html div
                       class: 'post-title';
                       with: [html text: title]]
    ]

    renderTimeStampOn: html session: aSession [
        <category: 'rendering-private'>
        html div
            class: 'post-timestamp';
            with: [html text: 'Posted on'; space.
                   html anchor
                       callback: [aSession blog viewDate: self dated];
                       with: [html text: self dated printString].
                   html
                       space;
                       text: 'at'; space;
                       text: timestamp asTime printString]        
    ]

    renderTextOn: html session: aSession [
        <category: 'rendering-private'>
        html div
            class: 'post-content';
            with:
                [| txt ast mdb |
                txt := (text last = Character nl)
                       ifTrue:  [text]
                       ifFalse: [text, Character nl asString].
                ast := MarkdownParser parse: txt.
                mdb := MarkdownBuilder on: html.
                ast do: [:each | each accept: mdb]]
    ]

    renderTagsOn: html session: aSession [
        <category: 'rendering-private'>
        html div
            class: 'post-tags';
            with:
                [| firstTag otherTags |
                firstTag := tags first.
                otherTags := tags allButFirst.
                
                html text: 'Tagged:'; space.

                "TODO: introduce a Reusable tag component"
                html anchor
                    callback: [aSession blog viewTag: firstTag];
                    with: [html text: firstTag].

                otherTags do:
                    [:each |
                    html text: ','; space.
                    html anchor
                        callback: [aSession blog viewTag: each];
                        with: [html text: each]]]
    ]

    renderActionsOn: html session: aSession [
        <category: 'rendering-private'>
        html div
            class: 'post-actions';
            with:
                [html anchor
                     callback: [];
                     class: 'post-action';
                     with: [html text: 'Add a comment'].
                 html anchor
                     callback: [aSession blog edit: self];
                     class: 'post-action';
                     with: [html text: 'Edit'].
                 html anchor
                     callback: [aSession blog remove: self];
                     class: 'post-action';
                     with: [html text: 'Remove']].
    ]

    renderContentOn: html session: aSession [
        <category: 'rendering'>
        html div
            class: 'post';
            with: [self renderTitleOn:     html session: aSession.
                   self renderTimeStampOn: html session: aSession.
                   self renderTextOn:      html session: aSession.
                   self renderTagsOn:      html session: aSession.
                   self renderActionsOn:   html session: aSession]
    ]
]

Seaside.WAComponent subclass: BlogPostComponent [
    | post |

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
            callback: [self session blog goHome];
            with: [html text: 'Back to posts'].
        post renderContentOn: html session.
    ]
]

Seaside.WAComponent subclass: BlogTape [
    renderActionsOn: html [
        <category: 'rendering-private'>
        "TODO: introduce a Decorator?"
        html anchor
            callback: [self session blog compose];
            with: [html text: 'Add a post'].
    ]

    renderContentOn: html [
        <category: 'rendering'>
        self renderActionsOn: html.
        html div
            class: 'tape';
            with: [self items do: [:each | each renderContentOn: html
                                                session: self session]]
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
        "TODO: introduce a Decorator?"
        "TODO: Reusable 'Back to posts' component"
        html anchor
            callback: [self session blog goHome];
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
                    callback: [self session blog viewTag: eachKey];
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

        self session blog: self.

        tape := BlogTape new.
        header := BlogHeader new.
        footer := BlogFooter new.
        cloud := BlogCloud new.
    ]

    initialRequest: aRequest [
        Transcript
            << aRequest url; cr;
            << (aRequest fields collect: [:each | each printString]); cr
    ]

    compose [
        <category: 'functionality'>
        | aPost |
        Transcript << 'hello'; cr.
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
                [html tableData with:
                     [html div
                          class: 'content';
                          with: [html render: tape]].
                 html tableData with: [html render: cloud]].
            html tableRow:
                [html tableData
                    colSpan: 2;
                    with: [html render: footer]]]
    ]

    updateRoot: anHtmlRoot [
        <category: 'seaside'>
        super updateRoot: anHtmlRoot.
        WasteConf style writeStyleOn: anHtmlRoot
    ]
]
