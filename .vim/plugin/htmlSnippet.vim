" Note, on linux you need powershell and xclip in path
" xclip 0.13 from upstream, your distro may have 0.12
function! CopyFormatted(line1, line2)
    execute a:line1 . "," . a:line2 . "TOhtml"
    if has("win64") || has("win32")
        %yank *
        " this only works on older powershell as the -AsHTML flag
        " was removed in powershell 7 or so because IDK
        !start /min powershell -noprofile "gcb | scb -as"
    else
        %yank +
        " TODO xclip -o -selection clipboard | xclip -selection clipboard -t text/html doesn't work very well for some reason
        !pwsh -noprofile -c "Get-Clipboard | xclip -selection clipboard -t text/html"
    endif
    bwipeout!
endfunction

command! -range=% HtmlClip silent call CopyFormatted(<line1>,<line2>)
noremap <C-L>h <Esc>:HtmlClip<CR>
vnoremap <C-L>h <Esc>:'<,'>HtmlClip<CR>

