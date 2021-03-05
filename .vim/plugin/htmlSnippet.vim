function! CopyFormatted(line1, line2)
    execute a:line1 . "," . a:line2 . "TOhtml"
    %yank *
    !start /min powershell -noprofile "gcb | scb -as"
    bwipeout!
endfunction

command! -range=% HtmlClip silent call CopyFormatted(<line1>,<line2>)
noremap <C-L>h <Esc>:HtmlClip<CR>
vnoremap <C-L>h <Esc>:'<,'>HtmlClip<CR>
