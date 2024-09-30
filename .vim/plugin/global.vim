" In case you've indexed multiple projects in the same tags DB and using $GTAGSLIBPATH is a chore
"let $GTAGSROOT='/'
"let $GTAGSDBPATH=$PROJECT_ROOT
" or
"let $GTAGSLIBPATH="/here:/there:/everywhere"
function! Iglobal(args, inbuffer)
    call inputsave()
    let searchfor = input("? ")
    let globalcmdline = 'global ' . a:args . ' ' . searchfor
    " run global
    if a:inbuffer == 0
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
    else
        let choices = systemlist(globalcmdline)
        :execute "normal :new\<CR>"
        :call append('$', choices)
        :execute "normal ggdd"
        :execute "set nomod"
    endif
    call inputrestore()
endfunction

function! IglobalOpen()
    let l:chosen = getline(".")
    let chunks = split(chosen, '\s\+')
    let lno = chunks[1]
    let fname = chunks[2]
    :execute 'new +' . lno . ' ' . fname
endfunction

function! Iglobalcomplete(args)
    call inputsave()
    let searchfor = input("? ")
    let globalcmdline = 'global ' . a:args . ' ' . searchfor
    " run global
    let choices = systemlist(globalcmdline)[0:199]
    " add first prompt to choices
    let choices = ['Results:'] + choices
    let ochoices = choices[0:200]
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
        let chosen = ochoices[n]
        :execute "normal! a\<C-R>\<C-R>=chosen\<CR>\<ESC>"
    endif
    call inputrestore()
endfunction

" interactive list, limited to 200 results
" search for C/C++ function/class
:map <C-L>gd <ESC>:call Iglobal('-qxod', 0)<CR>
" search for C/C++ references to function/class
:map <C-L>gr <ESC>:call Iglobal('-qxor', 0)<CR>
" search for symbols not covered by the above two calls
:map <C-L>gs <ESC>:call Iglobal('-qxos', 0)<CR>
" search for regular expression; not recommended for large projects
:map <C-L>gw <ESC>:call Iglobal('-qxog', 0)<CR>
" search for files using partial match
:map <C-L>gf <ESC>:call Iglobal('-qxP', 0)<CR>

" in buffer
" search for C/C++ function/class
:map <C-L>gD <ESC>:call Iglobal('-qxod', 1)<CR>
" search for C/C++ references to function/class
:map <C-L>gR <ESC>:call Iglobal('-qxor', 1)<CR>
" search for symbols not covered by the above two calls
:map <C-L>gS <ESC>:call Iglobal('-qxos', 1)<CR>
" search for regular expression; not recommended for large projects
:map <C-L>gW <ESC>:call Iglobal('-qxog', 1)<CR>
" search for files using partial match
:map <C-L>gF <ESC>:call Iglobal('-qxP', 1)<CR>
" parse output line
:map <C-L>gg <ESC>:call IglobalOpen()<CR>

" code completion
:map <C-L>gp <ESC>:call Iglobalcomplete('-qodsc')<CR>
:imap <C-L>gp <ESC>:call Iglobalcomplete('-qodsc')<CR>
