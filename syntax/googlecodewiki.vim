" Vim syntax file
" Language:     Google Code Wiki, http://code.google.com/p/support/wiki/WikiSyntax
" Maintainer:   Silas Silva <silasdb@gmail.com>
" Original:     FlexWiki, mantained by George V. Reilly
" Home:         http://code.google.com/p/vimgcwsyntax/
" Other Home:   TODO
" Filenames:    *.wiki
" Version:      TODO

" Customized Format expression:
"
" This syntax file comes with the googlecodewiki#FormatExpr() function that
" implements a function to format Google Code Wiki files.  Sometimes it is
" desirable to use this function instead of default Vim format rules.  To use
" this function, just :set formatexpr=googlecodewiki#FormatExpr().
"
" One of the most useful features of this function is that it doesn't break
" links (all text surrounded by "[" and "]") and in-line code (all text
" surrounded by "`").  To change this behaviour, change the following variables:
"
" g:googlecodewiki_break_inside_brackets: if 1, break text surrounded by "["
" and "]".
"
" g:googlecodewiki_break_inside_graves: if 1, break text surrounded by "`"


" TODO:

" For version 5.x: Clear all syntax items
" For version 6.x: Quit when a syntax file was already loaded
if version < 600
    syntax clear
elseif exists("b:current_syntax")
    finish
endif

syntax region googlecodewikiPragmaRegion  start=/^\%1l.*$/ end=/^[^#]*$/ contains=googlecodewikiPragma
syntax match googlecodewikiPragma         /^#.*$/ contained

syntax keyword googlecodewikiTodo         TODO contained
syntax region googlecodewikiCommentRegion start='<wiki:comment>' end='</wiki:comment>' contains=googlecodewikiTodo

" TODO: check URL syntax against RFC
syntax match googlecodewikiLink           `\("[^"(]\+\((\([^)]\+\))\)\?":\)\?\(https\?\|ftp\|gopher\|telnet\|file\|notes\|ms-help\):\(\(\(//\)\|\(\\\\\)\)\+[A-Za-z0-9:#@%/;$~_?+-=.&\-\\\\]*\)` contains=@NoSpell
syntax region googlecodewikiLinkRegion    start=/\[/ end=/\]/ contains=googlecodewikiLink oneline

" TODO: The use of one of the typefaces bellow prevents the use of other.  How
" to combine them?

" text: *strong* 
syntax match googlecodewikiBold            /\(^\|\W\)\zs\*\([^ ].\{-}\)\*/

" text: _emphasis_
syntax match googlecodewikiItalic          /\(^\|\W\)\zs_\([^ ].\{-}\)_/

" text: `code`
syntax match googlecodewikiCode            /`[^`]*`/ contains=@NoSpell

" text: {{{code}}}
syntax region googlecodewikiCodeRegion     start=/{{{/ end=/}}}/ contains=@NoSpell

"   text: ~~strike out~~
syntax region googlecodewikiStrikeoutText  start=/^\~\~/ end=/\(\~\~\|^$\)/
syntax region googlecodewikiStrikeoutText  start=/\W\~\~/ms=s+1 end=/\(\~\~\|^$\)/

"   text: +inserted text+ 
syntax match googlecodewikiInsText        /\(^\|\W\)\zs+\([^ ].\{-}\)+/

"   text: ^superscript^ 
syntax match googlecodewikiSuperScript    /\(^\|\W\)\zs^\([^ ].\{-}\)^/

"   text: ,,subscript,,
syntax region googlecodewikiSubScript  start=/^,,/ end=/\(,,\|^$\)/
syntax region googlecodewikiSubScript  start=/\W,,/ms=s+1 end=/\(,,\|^$\)/

" Aggregate all the regular text highlighting into googlecodewikiText
syntax cluster googlecodewikiText contains=googlecodewikiItalic,googlecodewikiBold,googlecodewikiCode,googlecodewikiCodeRegion,googlecodewikiStrikeoutText,googlecodewikiInsText,googlecodewikiSuperScript,googlecodewikiSubScript,googlecodewikiCitation,googlecodewikiLink,googlecodewikiWord,googlecodewikiEmoticons,googlecodewikiPragma

" Header levels, 1-6
syntax match googlecodewikiH1             /^=.*=$/
syntax match googlecodewikiH2             /^==.*==$/
syntax match googlecodewikiH3             /^===.*===$/
syntax match googlecodewikiH4             /^====.*====$/
syntax match googlecodewikiH5             /^=====.*=====$/
syntax match googlecodewikiH6             /^======.*======$/

" <hr>, horizontal rule
syntax match googlecodewikiHR             /^----*$/

" Tables. Each line starts and ends with '||'; each cell is separated by '||'
syntax match googlecodewikiTable          /||/

" Bulleted list items start with space or tabs, then '*' or '#'
syntax match googlecodewikiList           /^\s*\(\*\|#\).*$/   contains=@googlecodewikiText


" Link GoogleWiki syntax items to colors
hi def link googlecodewikiH1                    Title
hi def link googlecodewikiH2                    googlecodewikiH1
hi def link googlecodewikiH3                    googlecodewikiH2
hi def link googlecodewikiH4                    googlecodewikiH3
hi def link googlecodewikiH5                    googlecodewikiH4
hi def link googlecodewikiH6                    googlecodewikiH5
hi def link googlecodewikiHR                    googlecodewikiH6

hi def googlecodewikiBold                       term=bold cterm=bold gui=bold
hi def googlecodewikiItalic                     term=italic cterm=italic gui=italic

hi def link googlecodewikiCode                  String
hi def link googlecodewikiCodeRegion            String
hi def link googlecodewikiWord                  Underlined

hi def link googlecodewikiEscape                Todo
hi def link googlecodewikiPragma                PreProc
hi def link googlecodewikiLink                  Underlined
hi def link googlecodewikiLinkRegion            Identifier
hi def link googlecodewikiCommentRegion         Comment
hi def link pragma                              Identifier
hi def link googlecodewikiList                  Type
hi def link googlecodewikiTable                 Type
hi def link googlecodewikiEmoticons             Constant
hi def link googlecodewikiStrikeoutText         Special
hi def link googlecodewikiInsText               Constant
hi def link googlecodewikiSuperScript           Special
hi def link googlecodewikiSubScript             Special
hi def link googlecodewikiCitation              Constant
hi def link googlecodewikiTodo                  Todo

hi def link googlecodewikiSingleLineProperty    Identifier

let b:current_syntax="GoogleCodeWiki"


" {{{1
" Global variables that change FormatExpr() behaviour.

if !exists("g:googlecodewiki_break_inside_brackets")
    let g:googlecodewiki_break_inside_brackets = 0
endif

if !exists("g:googlecodewiki_break_inside_graves")
    let g:googlecodewiki_break_inside_graves = 0
endif

" {{{1
" Format expression function to be set by the user, if he wants.  Just
" :set formatexpr=googlecodewiki#FormatExpr()
function googlecodewiki#FormatExpr()
    if &textwidth == 0
        return
    endif

    if mode() == "i"
        call s:FormatInsertMode(v:lnum)
    else
        call s:FormatNormalMode(v:lnum, v:count)
    endif
endfunction


" Caveats of the functions above (should be fixed in future):
" TODO: Too much duplicated code between two function below.
" TODO: Doesn't format correctly two or more neighboring blank lines.

" {{{1
" Format expression for the insert mode (private function).
function s:FormatInsertMode(lnum)
    let col = col('.')
    if col < &textwidth
        return
    endif

    " We parse the entire line.
    let line = getline('.')
    let i = 0
    let ls = -1
    let in_bracket = 0
    let in_graves = 0
    while i < col
        if line[i] =~ '\s' && !in_bracket && !in_graves
            " Store the last blank space where we want to break the line.
            let ls = i
        endif

        if !g:googlecodewiki_break_inside_brackets && line[i] == '['
            let in_bracket = 1
        endif
        if !g:googlecodewiki_break_inside_brackets && line[i] == ']'
            let in_bracket = 0
        endif

        if !g:googlecodewiki_break_inside_graves && line[i] == '`'
            let in_graves = !in_graves
        endif

        let i += 1
    endwhile

    if ls == -1
        return
    endif

    let length = strlen(line)
    let col = col('.')

    let before = strpart(line, 0, ls)
    let after = strpart(line, ls + 1)
    let lines = [before, after]

    " Append as new lines.
    call append((a:lnum-1), lines)

    " And delete old ones.
    exe ":.d"

    " offset from the end of the line
    let back = length - col

    " Set the cursor to the line below (created after break).
    call cursor(a:lnum+1, strlen(after) - back)
endfunction


" {{{1
" Format expression for insert mode (private function)
function s:FormatNormalMode(lnum, count)
    let lines = getline(a:lnum, a:lnum + a:count - 1)

    " Let's combine all lines we want to format in one.
    let all = join(lines, " ")

    " We the unified line.
    let col = 0
    let ls = -1
    let last = 0
    let i = 0
    let in_bracket = 0
    let in_graves = 0
    while i < strlen(all)
        if all[i] =~ '\s' && !in_bracket && !in_graves
            " Store the last blank space where we want to break the line.
            let ls = i
        endif

        if !g:googlecodewiki_break_inside_brackets && all[i] == '['
            let in_bracket = 1
        endif
        if !g:googlecodewiki_break_inside_brackets && all[i] == ']'
            let in_bracket = 0
        endif

        if !g:googlecodewiki_break_inside_graves && all[i] == '`'
            let in_graves = !in_graves
        endif

        if (col >= &textwidth && ls != last)
            let before = strpart(all, 0, ls)
            let after = strpart(all, ls + 1)
            let all = before . "\n" . after
            let col = 0
            let start = ls
            let i = ls + 1
            let last = ls
        endif
        let col += 1
        let i += 1
    endwhile

    " Get a list of lines, correctly formated.
    let lines = split(all, '\n\|\s$', 1)

    " Delete the lines.
    exe ":.,+" . (str2nr(a:count)-1) . "d"

    " Now append the formated ones.
    call append((a:lnum-1), lines)
endfunction

" vim: set tw=0 et sw=4 sts=4 fdm=marker:
