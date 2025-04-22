" functions!
function! JavaPrint(what)
    let s:currentLine = line(".") + 1
    let s:currentFile = expand("%:t")
    let s:usrPrompt = input(a:what.": ", "\"\"")
    execute "normal o \<BS>System.out.println(\"%%%".a:what." ".s:currentFile.":".s:currentLine." \" + ".s:usrPrompt.");\<ESC>"
endfunction

function! JavaPrintAbove(what)
    let s:currentLine = line(".")
    let s:currentFile = expand("%:t")
    let s:usrPrompt = input(a:what.": ", "\"\"")
    execute "normal O \<BS>System.out.println(\"%%%".a:what." ".s:currentFile.":".s:currentLine." \" + ".s:usrPrompt.");\<ESC>"
endfunction

function! CPrint(what)
    let s:currentLine = line(".") + 1
    let s:currentFile = expand("%:t")
    let s:usrPrompt = input(a:what.": ", "\"\"")
    execute "normal o \<BS>cout << \"%%%".a:what." ".s:currentFile.":".s:currentLine." \" << ".s:usrPrompt." << endl;\<ESC>"
endfunction

function! CPrintAbove(what)
    let s:currentLine = line(".")
    let s:currentFile = expand("%:t")
    let s:usrPrompt = input(a:what.": ", "\"\"")
    execute "normal O \<BS>cout << \"%%%".a:what." ".s:currentFile.":".s:currentLine." \" << ".s:usrPrompt." << endl;\<ESC>"
endfunction

" INFO
:map <C-L>jp :call JavaPrint("INFO")<CR>
:map <C-L>cp :call CPrint("INFO")<CR>
:imap <C-L>cp <ESC>:call CPrint("INFO")<CR>
:imap <C-L>jp <ESC>:call JavaPrint("INFO")<CR>
:map <C-L>jP :call JavaPrintAbove("INFO")<CR>
:map <C-L>cP :call CPrintAbove("INFO")<CR>
:imap <C-L>cP <ESC>:call CPrintAbove("INFO")<CR>
:imap <C-L>jP <ESC>:call JavaPrintAbove("INFO")<CR>

" DEBUG
:map <C-L>jd :call JavaPrint("DEBUG")<CR>
:map <C-L>cd :call CPrint("DEBUG")<CR>
:imap <C-L>cd <ESC>:call CPrint("DEBUG")<CR>
:imap <C-L>jd <ESC>:call JavaPrint("DEBUG")<CR>
:map <C-L>jD :call JavaPrintAbove("DEBUG")<CR>
:map <C-L>cD :call CPrintAbove("DEBUG")<CR>
:imap <C-L>cD <ESC>:call CPrintAbove("DEBUG")<CR>
:imap <C-L>jD <ESC>:call JavaPrintAbove("DEBUG")<CR>

" TODO
:map <C-L>jt :call JavaPrint("TODO")<CR>
:map <C-L>ct :call CPrint("TODO")<CR>
:imap <C-L>ct <ESC>:call CPrint("TODO")<CR>
:imap <C-L>jt <ESC>:call JavaPrint("TODO")<CR>
:map <C-L>jT :call JavaPrintAbove("TODO")<CR>
:map <C-L>cT :call CPrintAbove("TODO")<CR>
:imap <C-L>cT <ESC>:call CPrintAbove("TODO")<CR>
:imap <C-L>jT <ESC>:call JavaPrintAbove("TODO")<CR>

" WARNING
:map <C-L>jw :call JavaPrint("WARNING")<CR>
:map <C-L>cw :call CPrint("WARNING")<CR>
:imap <C-L>cw <ESC>:call CPrint("WARNING")<CR>
:imap <C-L>jw <ESC>:call JavaPrint("WARNING")<CR>
:map <C-L>jW :call JavaPrintAbove("WARNING")<CR>
:map <C-L>cW :call CPrintAbove("WARNING")<CR>
:imap <C-L>cW <ESC>:call CPrintAbove("WARNING")<CR>
:imap <C-L>jW <ESC>:call JavaPrintAbove("WARNING")<CR>

" ERROR
:map <C-L>je :call JavaPrint("ERROR")<CR>
:map <C-L>ce :call CPrint("ERROR")<CR>
:imap <C-L>ce <ESC>:call CPrint("ERROR")<CR>
:imap <C-L>je <ESC>:call JavaPrint("ERROR")<CR>
:map <C-L>jE :call JavaPrintAbove("ERROR")<CR>
:map <C-L>cE :call CPrintAbove("ERROR")<CR>
:imap <C-L>cE <ESC>:call CPrintAbove("ERROR")<CR>
:imap <C-L>jE <ESC>:call JavaPrintAbove("ERROR")<CR>

" this one's here as an example
function! WrapInFunctionL() range
    let s:usrPrompt = input("func: ", "")
    execute "normal ".a:firstline."GI".s:usrPrompt."(\<ESC>".a:lastline."GA)\<ESC>"
endfunction

function! WrapInFunctioNMarks()
    let s:firstMark = input("first mark: ", "q")
    let s:secondMark = input("second mark: ", "w")
    let s:usrPrompt = input("func: ", "")
    execute "normal `".s:secondMark."a)\<ESC>`".s:firstMark."i".s:usrPrompt."(\<ESC>"
endfunction
:noremap <C-L>f :call WrapInFunctioNMarks()<CR>

" wrap selection in function
function! WrapInFunctionV() range
    let s:usrPrompt = input("func: ", "")
    execute "normal `>a)\<ESC>`<i".s:usrPrompt."(\<ESC>"
endfunction
:vnoremap <C-L>f :call WrapInFunctionV()<CR>

" wrap selection in quotes
function! WrapInQuotesMarks()
    let s:firstMark = input("first mark: ", "q")
    let s:secondMark = input("second mark: ", "w")
    echo "Quote character?"
    let s:inp = nr2char(getchar())
    if s:inp == "\<ESC>"
        return
    elseif s:inp == '(' || s:inp == ')'
        let s:start = "("
        let s:end = ")"
    elseif s:inp == '[' || s:inp == ']'
        let s:start = "["
        let s:end = "]"
    elseif s:inp == '{' || s:inp == '}'
        let s:start = "{"
        let s:end = "}"
    else
        let s:start = s:inp
        let s:end = s:inp
    endif
    execute "normal `" . s:secondMark . "a" . s:end . "\<ESC>`" . s:firstMark . "i" . s:start . "\<ESC>"
endfunction
:noremap <C-L>" :call WrapInQuotesMarks()<CR>

" wrap selection in quotes
function! WrapInQuotes()
    echo "Quote character?"
    let s:inp = nr2char(getchar())
    if s:inp == "\<ESC>"
        return
    elseif s:inp == '(' || s:inp == ')'
        let s:start = "("
        let s:end = ")"
    elseif s:inp == '[' || s:inp == ']'
        let s:start = "["
        let s:end = "]"
    elseif s:inp == '{' || s:inp == '}'
        let s:start = "{"
        let s:end = "}"
    else
        let s:start = s:inp
        let s:end = s:inp
    endif
    execute "normal `>a" . s:end . "\<ESC>`<i" . s:start . "\<ESC>"
endfunction
:vnoremap <C-L>" :call WrapInQuotes()<CR>

function! IndentJSon()
    " add line feeds
    execute "%s/\\\([{[,]\\\)/\\1\\r/ge"
    execute "%s/\\\([\\]}]\\\)/\\r\\1/ge"
    " do some weird substitutions to have =G work nicely
    execute "%s/{/{\001/ge"
    execute "%s/}/}\001/ge"
    execute "%s/\\[/{{/ge"
    execute "%s/]/}}/ge"
    execute "%s/;/;\001/ge"
    execute "%s/,/;;/ge"
    " indent
    execute "normal gg=G"
    " reverse weird substitutions
    execute "%s/;;/,/ge"
    execute "%s/;\001/;/ge"
    "execute "%s/\001/,/ge"
    execute "%s/{{/[/ge"
    execute "%s/}}/]/ge"
    execute "%s/{\001/{/ge"
    execute "%s/}\001/}/ge"
endfunction
:noremap <C-L>ij :call IndentJSon()<CR>

let g:fToggleTextWidth = 0
function! ToggleTextWidth()
    let l:nbuf = bufnr('%')
    let l:msg = ''
    if g:fToggleTextWidth == 0
        let g:fToggleTextWidth = 1
        silent bufdo set textwidth=72
        let l:msg = "textwidth=72"
    else
        let g:fToggleTextWidth = 0
        silent bufdo set textwidth=0
        let l:msg = "textwidth off"
    endif
    silent execute 'buffer ' . l:nbuf
    echo l:msg
endfunction
:noremap <C-L>t :call ToggleTextWidth()<CR>

function! ShowMessagesInBuffer()
    execute ":new"
    :put =execute(\"messages\")
    execute ":set nomod"
endfunction
:noremap <C-L>m :call ShowMessagesInBuffer()<CR>
