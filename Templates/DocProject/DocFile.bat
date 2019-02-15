@echo off
:: Pandoc wrapper for calling the conversion of several pandocs
:: files to one master document
set pandoc_cmd=pandoc
set pandoc_cmd=%pandoc_cmd% .\DocFile.md
set pandoc_cmd=%pandoc_cmd% .\DocFile.links.md
set pandoc_cmd=%pandoc_cmd% -o .\DocFile.tmp.md -f markdown -t markdown

:: echo %pandoc_cmd%

%pandoc_cmd%