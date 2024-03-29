let s:path = expand('<sfile>:p:h')

function! Iworddb()
    call inputsave()
    let searchfor = input("? ")
    let cmdline = s:path . '/worddb_query.sh e "' . searchfor . '"'
    " run query
    let choices = systemlist(cmdline)[0:199]
    " add first prompt to choices
    let choices = ['Results:'] + choices
    let i = 1
    while i < len(choices)
        let choices[i] = printf("%4d:", i) . choices[i]
        let i = i + 1
    endwhile
    if len(choices) == 201
        let choices = choices + ["...truncated..."]
    endif
    " ask user
    let n = inputlist(choices)
    if n > 0 && n < len(choices) && n < 201
        let chosen = choices[n]
        let chunks = split(chosen, ':')
        " echo chunks
        let lno = chunks[2]
        let fname = chunks[1]
        :execute 'e +' . lno . ' ' . fname
    endif
    call inputrestore()
endfunction

function! IworddbInBuffer()
    call inputsave()
    let searchfor = input("? ")
    let cmdline = s:path . '/worddb_query.sh e "' . searchfor . '"'
    " run query
    let choices = systemlist(cmdline)
    :execute "normal :new\<CR>"
    :call append('$', choices)
    :execute "normal ggdd"
    :execute "set nomod"
    call inputrestore()
endfunction

function! Iworddbfiles(args)
    call inputsave()
    let searchfor = input("? ")
    let cmdline = s:path . '/worddb_query.sh ' . a:args . ' "' . searchfor . '"'
    " run query
    let choices = systemlist(cmdline)[0:199]
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
        let fname = chunks[1]
        :execute 'e ' . fname
    endif
    call inputrestore()
endfunction

:map <C-L>we <ESC>:call Iworddb()<CR>
:map <C-L>wE <ESC>:call IworddbInBuffer()<CR>
:map <C-L>ww <ESC>:call Iworddbfiles('w')<CR>
:map <C-L>wf <ESC>:call Iworddbfiles('f')<CR>
