Seaside.WAFileLibrary subclass: BlogData [
    styleCss [
       <category: 'styles'>
        ^'
body {
    background-color: white;
    margin: 0;
    padding: 0;
}

td {
    vertical-align: top;
}

.header {
    margin: 0;
    padding: 0;
    font-size: 160%;
    background-color: skyblue;
    border-style: solid;
    border-width: 1px;
    border-color: #4682b4;
}

.tape {
    // border-style: solid;
    // border-width: 1px;
    // border-color: pink;
}

.footer {
    margin: 0;
    padding: 0;
    font-size: 70%;
    background-color: lightgray;
    border-style: solid;
    border-width: 1px;
    border-color: gray;
}

.post {
    background-color: lightyellow;
    margin-top: 2px;
    margin-bottom: 2px;
    border-style: solid;
    border-width: 1px;
    border-color: orange;
    width: 420px;
}

.cloud {
    background-color: #98fb98;
    border-style: solid;
    border-width: 1px;
    border-color: #32cd32;
}

textarea {
    width: 400px;
    height: 100px;
}

p {
    margin: 0;
    padding: 0;
} 
'
    ]

    selectorsToInclude [
        <category: 'accessing'>
        ^#(#styleCss)
    ]
]
