" In case you've indexed multiple projects in the same tags DB and using $GTAGSLIBPATH is a chore
"let $GTAGSROOT='/'
"let $GTAGSDBPATH=$PROJECT_ROOT
" or
"let $GTAGSLIBPATH="/here:/there:/everywhere"
function! Iglobal(args)
    let searchfor = input("? ")
    let globalcmdline = 'global ' . a:args . ' ' . searchfor
    " run global
    let choices = systemlist(globalcmdline)[0:199]
    " add first prompt to choices
    let choices = ['Results:'] + choices
    let i = 1
    while i < len(choices)
        let choices[i] = printf("%4d ", i) . choices[i]
        let i = i + 1
    endwhile
    if len(choices) == 201
        let choices = choices + ["...truncated..."]
    endif
    " ask user
    let n = inputlist(choices)
    if n > 0 && n < len(choices) && n < 201
        let chosen = choices[n]
        let chunks = split(chosen, '\s\+')
        let lno = chunks[2]
        let fname = chunks[3]
        :execute 'e +' . lno . ' ' . fname
    endif
endfunction

" search for C/C++ function/class
:map <C-L>gg <ESC>:call Iglobal('-qxod')<CR>
" search for C/C++ references to function/class
:map <C-L>gr <ESC>:call Iglobal('-qxor')<CR>
" search for symbols not covered by the above two calls
:map <C-L>gs <ESC>:call Iglobal('-qxos')<CR>
" search for regular expression; not recommended for large projects
:map <C-L>gw <ESC>:call Iglobal('-qxog')<CR>
" search for files using partial match
:map <C-L>gf <ESC>:call Iglobal('-qxP')<CR>
" code completion
:map <C-L>gp <ESC>:call Iglobal('-qodsc')<CR>
