" TODO update s:perlPath accordingly
let s:perlPath = 'C:\StrawberryPerl\portableshell-oneoff.bat'

function! MDToHtml()
    let l:currentFile = expand("%:t")
    let l:args = ' -e "my $s = '."''".'; while(<>) { $s .= $_; } use Text::MultiMarkdown qw(markdown); print markdown($s); "'
    let l:cmd = ":%!".s:perlPath.l:args
    execute "normal "
\       .":1,$y\<CR>"
\       .":new\<CR>"
\       ."p\<ESC>"
\       .l:cmd."\<CR>"
\       ."ggO<html><head><title>".l:currentFile."</title>"
\            ."<style>code { font-family: monospace; white-space: pre-wrap; } .footnote { vertical-align: super; font-size: 50%; } </style>"
\            ."</head><body>\<ESC>"
\       ."ggO<!DOCTYPE html>\<ESC>"
\       ."Go</body></html>\<ESC>"
endfunction

function! MDToHtmlSnippet()
    let l:currentFile = expand("%:t")
    let l:args = ' -e "my $s = '."''".'; while(<>) { $s .= $_; } use Text::MultiMarkdown qw(markdown); print markdown($s); "'
    let l:cmd = ":%!".s:perlPath.l:args
    execute "normal "
\       .":1,$y\<CR>"
\       .":new\<CR>"
\       ."p\<ESC>"
\       .l:cmd."\<CR>"
endfunction
