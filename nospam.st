Object subclass: NoSpam [
    | entry typedToken |

    NoSpam class >> descriptionToken [
        <category: 'magritte'>
        ^Magritte.MANumberDescription new
            accessor: #accessToken;
            label: 'Type';
            priority: 100;
            beReadonly;
            yourself
    ]

    NoSpam class >> descriptionUserToken [
        <category: 'magritte'>
        ^Magritte.MANumberDescription new
            accessor: #typedToken;
            label: 'Here';
            priority: 200;
            beRequired;
            yourself
    ]

    NoSpam class >> new: anObject [
        <category: 'instance creation'>
        ^(self basicNew)
            init: anObject;
            yourself
    ]

    init: anObject [
        <category: 'private'>
        entry := anObject.
    ]

    accessToken [
        <category: 'private'>
        ^entry hash
    ]

    typedToken [
        <category: 'private'>
        ^typedToken
    ]

    typedToken: aToken [
        <category: 'private'>
        typedToken := aToken
    ]

    isPassed [
        <category: 'testing'>
        ^self accessToken = self typedToken
    ]
]
