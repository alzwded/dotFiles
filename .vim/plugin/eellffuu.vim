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

" wrap selection in function
function! WrapInFunction()
    let s:currentLine = line(".")
    let s:currentFile = expand("%:t")
    let s:usrPrompt = input("func: ", "")
    execute "normal `>a)\<ESC>`<i".s:usrPrompt."(\<ESC>"
endfunction
:vnoremap <C-L>f :call WrapInFunction()<CR>

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
