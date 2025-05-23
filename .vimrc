syntax on
set ruler
set number
set laststatus=2
set ai
set nohls
set noincsearch
color slate
set bg=dark
set bg=light
"highlight clear " for vim 9.0
:map j gj
:map k gk
set expandtab
set tabstop=4
set sw=4
:map <C-W><C-E> :Explore<CR>
:map <F2> :set hls<CR>/
:map <F3> :set nohls<CR>
":map <C-N> :new " I don't use this anymore; instead, I actually use the normal C-P and C-N
" remap stuff with ctrl-l<cmd> because it's not used anywhere useful
"   also: keep <C-L>g clear in case I need <C-L>g<something else which is already used>
:map <C-L><BS> ^4i<BS><ESC>
:map <C-L><TAB> ^i<TAB><ESC>
:map <C-L>/ ^2i/<ESC>
:map <C-L>? ^2x
:imap <C-L><TAB> <ESC>^i<TAB>
:imap <C-L><BS> <ESC>^4i<BS><ESC>I
:set mouse=a
:set wildmenu
:set wildmode=full

" set list
set lcs+=space:.
set lcs+=tab:>\   " that's '> '


:map <F5> :set mouse=a<CR>:set number<CR>:set ai<CR>
:map <F6> :set mouse=""<CR>:set nonumber<CR>:set noai<CR>a
:imap <F5> <ESC>:set mouse=a<CR>:set number<CR>:set ai<CR>
:imap <F6> <ESC>:set mouse=""<cr>:set nonumber<CR>:set noai<CR>a
:map <C-L>t :%s/\t/    /g<CR>
:map <C-L>T :%s/    /\t/g<CR>
:imap <C-L>t <ESC>:%s/\t/    /g<CR>
:imap <C-L>T <ESC>:%s/    /\t/g<CR>
:map <C-L>x :set ro<CR>:%!xxd<CR>
:map <C-L>X :%!xxd -r<CR>:set noro<CR>

:map <Left> zh
:map <Right> zl

set directory=/home/test/vimSwaps/
"set directory=d:\vimSwaps

autocmd FileType * setlocal formatoptions-=c formatoptions-=r formatoptions-=o
autocmd BufNewFile,BufRead *.m setlocal syntax=objc
autocmd BufNewFile,BufRead *.g3pl setlocal syntax=yacc
autocmd BufNewFile,BufRead *.gxx\|*.lxx setlocal syntax=cpp
autocmd BufNewFile,BufRead *.cxx\|*.c\>\|*.h\>\|*.cpp\|*.hxx\|*.hpp\|*.c++\|*.h++ setlocal cindent
autocmd BufNewFile,BufRead NOTES\|*.notes setlocal syntax=notes
autocmd BufNewFile,BufRead *.ss setlocal lisp

:set clipboard="unnamed,autoselect,exclude:const\|linux"

"set pastetoggle=<F6>

:vnoremap <C-L>( <Esc>`>a)<Esc>`<i(<Esc>
:vnoremap <C-L>[ <Esc>`>a]<Esc>`<i[<Esc>
:vnoremap <C-L>{ <Esc>`>a}<Esc>`<i{<Esc>

" windows, gvim: ^[ as <Esc> doesn't seem to work; 
" also, remapping LCTR doesn't work because it breaks (!) the AltGr key
" ergo, map ^Tab for this
if has("win32")
    inoremap <C-Tab> <Esc>
    xnoremap <C-Tab> <Esc>
    nnoremap <C-Tab> <Esc>
    onoremap <C-Tab> <Esc>
    cnoremap <C-Tab> <C-C> " hehe, cpoptions+=x is always there in c_ mode and that triggers c_<Esc>; FU
endif

set fileencoding=utf8 " win32 defaults to code pages...
set encoding=utf8 " win32 defaults to code pages...

"set tags=tags,moretags,allthetags

set redrawtime=10000
syntax sync minlines=10000

" remove stuff from zipPlugin and keep more normal things
let g:zipPlugin_ext='*.docm,*.docx,*.dotm,*.dotx,*.epub,*.jar,*.odc,*.odf,*.odg,*.odi,*.odm,*.odp,*.ods,*.odt,*.otc,*.otf,*.otg,*.oth,*.oti,*.otp,*.ots,*.ott,*.oxt,*.potm,*.potx,*.ppam,*.ppsm,*.ppsx,*.pptm,*.pptx,*.sldx,*.thmx,*.vdw,*.war,*.wsz,*.xlam,*.xlsb,*.xlsm,*.xlsx,*.xltm,*.xltx,*.zip'

" if vim is starting in replace mode (e.g. on alpine or wsl):
"set t_u7=
"set ambw=double

" enable gdb integration if available
:packadd termdebug
:nmap <C-M-N> :Over<CR>
:nmap <C-M-S> :Step<CR>
:nmap <C-M-F> :Finish<CR>
" run with :Termdebug; see :help :Termdebug
" On OpenBSD, the system gdb is very old, the newer one is installed
" from ports and called egdb
"let g:termdebugger = "egdb"

" I have wireless keyboards that reboot themselves if ESC and K overlap
:noremap <F1> <ESC>
:inoremap <F1> <ESC>
:vnoremap <F1> <ESC>
:cnoremap <F1> <ESC>
:onoremap <F1> <ESC>
:xnoremap <F1> <ESC>
