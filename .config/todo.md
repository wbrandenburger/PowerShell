# ToDo

1. [ToDo](#todo)
   1. [Programming](#programming)
      1. [Programming-Project-Administration](#programming-project-administration)
      2. [Programming-Batch](#programming-batch)
      3. [Programming-Web-Search](#programming-web-search)
      4. [Programming-Snippets](#programming-snippets)
         1. [Programming-Snippets-Knowledge](#programming-snippets-knowledge)
   2. [Administration](#administration)
      1. [Administration-Dictionaries](#administration-dictionaries)
   3. [Graphics](#graphics)
      1. [Graphics-Programming](#graphics-programming)

## Programming

### Programming-Project-Administration

- @Important: Go through all documents of specific type and change variables, such as the references in latex, which exhibits letter with capitals
- Update among projects shared files, f.e. Latex .sty and .bib files, specifically the dictionaries
  - Gather all projects and folders in a `.ini` file
  - Gather all files to update in a `.ini` file
  - If a change is available update all considered files
- Copy portable **documents** to version folder
- Lucene.NET: A full-text search engine for NET application
- Alias for web search: Combining several file in folder and create alias
- Add text from pdf to documents: Check spelling, remove spaces and hyphens
- File-Tools.bat: Generalization

[NirSoft]: http://nircmd.nirsoft.net/clipboard.html
[Download from Command Line]: https://superuser.com/questions/25538/how-to-download-files-from-command-line-in-windows-like-wget-or-curl

### Programming-Batch

- Need of displaying Child-Item: sci-ls.bat.
- sci-web has new interface for interpreting input arguments. Transfer it to other commands.
- sci-web needs to be changed regarding the evaluation of the array with the search engines
- sci-web should display all search engines
- call usage leads to creating file X

### Programming-Web-Search

From [Google - Search parameter][Google-Search-parameter] and [Google Scholar - Search parameter][Google-Scholar-Search-parameter]

| [Search parameter] | Example                    | Description                                                                                      |
|--------------------|----------------------------|--------------------------------------------------------------------------------------------------|
| `as_epq`           | `as_epq=query+goes+here`   | Result must include the query in the word order displayed                                        |
| `as_oq`            | `"query+string"+goes+here` | Result must have the main initially query, and one or more of the sets of terms in these strings |
| `num=xx`           | `num=30`                   | Controls the number of results shown                                                             |

[Google-Search-parameter]:https://moz.com/blog/the-ultimate-guide-to-the-google-search-parameters
[Google-Scholar-Search-parameter]:https://raw.githubusercontent.com/ckreibich/scholar.py/master/scholar.py

### Programming-Snippets

- Nested Regex in snippets
- [VS Code Snippets][Link-VS-Code-Snippets]

[Link-VS-Code-Snippets]:https://code.visualstudio.com/docs/editor/userdefinedsnippets

#### Programming-Snippets-Knowledge

```Json
"Comment": {
    "prefix": "#",
    "body":  [

      "<!-- ${TM_FILEPATH/.*\\\\(.*\\\\.*)$$/$1/} -->",

      "<!-- ${TM_DIRECTORY/.*\\\\(.*)$/$1/}/${TM_FILENAME} -->",
    ]
},
```

Those two lines in the body should be equivalent. That works for the Windows directory style.
Since your path.separators are / try something like:

```Json
"<!-- ${TM_FILEPATH/.*\/(.*\.*)$/$1/} -->",
"<!-- ${TM_FILEPATH/.*\\/(.*\\.*)$/$1/} -->",
"<!-- ${TM_FILEPATH/.*\\\/(.*\\\.*)$/$1/} -->",
"<!-- ${TM_FILEPATH/.*\\\\/(.*\\\\.*)$/$1/} -->",
```

## Administration

### Administration-Dictionaries

- bibtex

## Graphics

### Graphics-Programming

- Using Tikz for vector graphics

[Link-Tikz]:http://www.texample.net/tikz/examples/
