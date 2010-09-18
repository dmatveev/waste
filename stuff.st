Seaside.WAFileLibrary subclass: BlogData [
    styleCss [
       <category: 'styles'>
        ^'
body {
    font-family: serif;
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
    font-family: arial, sans;
    font-size: 180%;
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


.post-title {
    font-size: 120%;
    font-weight: bold;
}

.post-timestamp {
    font-size: 80%;
    margin-bottom: 10px;
}

.post {
    background-color: lightyellow;
    margin-top: 2px;
    padding-left: 2px;
    margin-bottom: 12px;
    border-style: solid;
    border-width: 1px;
    border-color: orange;
    width: 420px;
}

.post-action {
    margin-left: 2px;
    margin-right: 2px;
}

.post-actions {
    margin-top: 5px;
    font-size: 80%;
}

.post-content {
    margin: 10px;
}

.post-tags {
    font-size: 80%;
    margin-bottom: 2px;
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
