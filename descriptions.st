"-------------------------------------------------------------------------------
    In this file we do provide some getters and setters for comment classes.
    I know, it violates the encapsulation, but Magritte requres it for work.

    I am too lazy to produce a code for input forms by hand, so let it be.
 ------------------------------------------------------------------------------"

BlogPost class extend [
    descriptionTitle [
        <category: 'magritte'>
        ^Magritte.MAStringDescription new
            accessor: #title;
            label: 'Title';
            priority: 100;
            addCondition: [:value | value isEmpty not];
            beRequired;
            yourself
    ]
    
    descriptionText [
        <category: 'magritte'>
        ^Magritte.MAMemoDescription new
            accessor: #text;
            label: 'Text';
            priority: 200;
            addCondition: [:value | value isEmpty not];
            beRequired;
            yourself
    ]

    descriptionTags [
        <category: 'magritte'>
        ^Magritte.MAStringDescription new
            accessor: #tags;
            label: 'Tags';
            priority: 300;
            yourself
    ]
]

BlogPost extend [
    text: aString [
        <category: 'accessing'>
        text := aString
    ]

    text [
        <category: 'accessing'>
        ^text
    ]

    title: aString [
        <category: 'accessing'>
        title := aString
    ]

    title [
        <category: 'accessing'>
        ^title
    ]

    tags: aString [
        <category: 'accessing'>
        tags := (aString tokenize: ',') collect: [:e | e trimSeparators asLowercase]
    ]

    tags [
        <category: 'accessing'>
        "WARNING: This method returns a String for Magritte. If you want to get
         a Collection of tags for this post, use #tagged message."
        tags isNil
            ifTrue: [^'']
            ifFalse: [^tags inject: nil into:
                [:acc :each | acc ifNil: [each] ifNotNil: [acc, ', ', each]]]
    ]
]



BlogComment class extend [
    descriptionName [
        <category: 'magritte'>
        ^Magritte.MAStringDescription new
            accessor: #name;
            label: 'Name';
            priority: 100;
            addCondition: [:value | value isEmpty not];
            beRequired;
            yourself
    ]

    descriptionEmail [
        <category: 'magritte'>
        ^Magritte.MAStringDescription new
            accessor: #email;
            label: 'E-mail';
            priority: 200;
            yourself
    ]
    
    descriptionText [
        <category: 'magritte'>
        ^Magritte.MAMemoDescription new
            accessor: #text;
            label: 'Text';
            priority: 300;
            addCondition: [:value | value isEmpty not];
            beRequired;
            yourself
    ]
]

BlogComment extend [
    text: aString [
        text := aString
    ]

    text [
        ^text
    ]

    name: aString [
        name := aString
    ]

    name [
        ^name
    ]

    email: aString [
        email := aString
    ]

    email [
        ^email
    ]
]

AuthInfo class extend [
    descriptionLogin [
        <category: 'magritte'>
        ^Magritte.MAStringDescription new
            accessor: #login;
            label: 'Login';
            priority: 100;
            addCondition: [:value | value isEmpty not];
            beRequired;
            yourself
    ]

    descriptionPassword [
        <category: 'magritte'>
        ^Magritte.MAPasswordDescription new
            accessor: #password;
            label: 'Password';
            priority: 200;
            yourself
    ]
]
