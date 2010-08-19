"-------------------------------------------------------------------------------
    In this file we do provide some getters and setters for comment classes.
    I know, it violates the encapsulation, but Magritte requres it for work.

    I am too lazy to produce a code for input forms by hand, so let it be.
 ------------------------------------------------------------------------------"

BlogComment class extend [
    descriptionText [
        <category: 'magritte'>
        ^Magritte.MAStringDescription new
            accessor: #text;
            label: 'Text';
            priority: 100;
            addCondition: [:value | value isEmpty not];
            beRequired;
            yourself
    ]
]

BlogComment extend [
    text: aString [
        <category: 'accessing'>
        text := aString
    ]

    text [
        <category: 'accessing'>
        ^text
    ]
]

GuestComment class extend [
    descriptionName [
        <category: 'magritte'>
        ^Magritte.MAStringDescription new
            accessor: #name;
            label: 'Your name';
            addCondition: [:value | value isEmpty not];
            beRequired;
            priority: 100;
            yourself
    ]

    descriptionEmail [
        <category: 'magritte'>
        ^Magritte.MAStringDescription new
            accessor: #email;
            label: 'E-mail';
            priority: 100;
            yourself
    ]

    descriptionWebsite [
        <category: 'magritte'>
        ^Magritte.MAStringDescription new
            accessor: #www;
            label: 'Website';
            priority: 100;
            yourself
    ]
]

GuestComment extend [
    name: aString [
        <category: 'accessing'>
        name := aString
    ]
    
    name [
        <category: 'accessing'>
        ^name
    ]

    email: aString [
        <category: 'accessing'>
        email := aString
    ]
    
    email [
        <category: 'accessing'>
        ^email
    ]

    www: aString [
        <category: 'accessing'>
        www := aString
    ]
    
    www [
        <category: 'accessing'>
        ^www
    ]
]
