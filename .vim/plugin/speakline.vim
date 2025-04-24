let s:verbose = 0

function! SpeakVerbosen(intext)
    let l:text = a:intext
    " must be first to sort out . and -
    let l:text = substitute(l:text, "\\.", "", "g")
    let l:text = substitute(l:text, "-", " - DASH. ", "g")
    let l:text = substitute(l:text, "", " - DOT. ", "g")
    " let the floodgates open
    " Use - and . for some emphatic paush
    let l:text = substitute(l:text, "\&", " - AMPERSAND. ", "g")
    let l:text = substitute(l:text, "\\!", " - EXCLAMATION. ", "g")
    let l:text = substitute(l:text, "\\~", " - TILDE. ", "g")
    let l:text = substitute(l:text, "`", " - BACKTICK. ", "g")
    let l:text = substitute(l:text, "#", " - HASH. ", "g")
    let l:text = substitute(l:text, "\\$", " - DOLLAR. ", "g")
    let l:text = substitute(l:text, "%", " - PERCENT. ", "g")
    let l:text = substitute(l:text, "\\^", " - CARRET. ", "g")
    let l:text = substitute(l:text, "\\*", " - STAR. ", "g")
    let l:text = substitute(l:text, "(", " - OPEN PAREN. ", "g")
    let l:text = substitute(l:text, ")", " - CLOSE PAREN. ", "g")
    let l:text = substitute(l:text, "_", " - UNDERSCORE. ", "g")
    let l:text = substitute(l:text, "+", " - PLUS. ", "g")
    let l:text = substitute(l:text, "=", " - EQUALS. ", "g")
    let l:text = substitute(l:text, "\\\\", " - BACKSLASH. ", "g")
    let l:text = substitute(l:text, "|", " - PIPE. ", "g")
    let l:text = substitute(l:text, "\\[", " - OPEN SQUARE. ", "g")
    let l:text = substitute(l:text, "\\]", " - CLOSE SQUARE. ", "g")
    let l:text = substitute(l:text, "{", " - OPEN CURLY. ", "g")
    let l:text = substitute(l:text, "}", " - CLOSE CURLY. ", "g")
    let l:text = substitute(l:text, ";", " - SEMICOLON. ", "g")
    let l:text = substitute(l:text, ":", " - COLON. ", "g")
    let l:text = substitute(l:text, "'", " - APOSTROPHE. ", "g")
    let l:text = substitute(l:text, "\\\"", " - QUOTE. ", "g")
    let l:text = substitute(l:text, "<", " - OPEN ANGLE. ", "g")
    let l:text = substitute(l:text, ">", " - CLOSE ANGLE. ", "g")
    let l:text = substitute(l:text, ",", " - COMMA. ", "g")
    let l:text = substitute(l:text, "/", " - SLASH. ", "g")
    let l:text = substitute(l:text, "?", " - QUESTION. ", "g")
    return l:text
endfunction

if has("win32")
    let s:path = expand('<sfile>:p:h')
    let s:speakserviceeverinitialized = 0
    function! Speak(text)
        if s:speakserviceeverinitialized == 0 || job_status(s:speakservice) != "run"
            let s:speakservice = job_start('PowerShell -File "' .. s:path .. '\speakservice.ps1'  .. '"')
            let s:speakserviceeverinitialized = 1
            echo "Started service; :call TerminateSpeechService() to stop early"
        endif
        let ch = job_getchannel(s:speakservice)
        call ch_sendraw(ch, a:text .. "\n")
    endfunction
    function! TerminateSpeechService()
        if s:speakserviceeverinitialized != 0 && job_status(s:speakservice) == "run"
            echo "Terminating"
            call job_stop(s:speakservice)
        endif
    endfunction
    function! Speak1(text)
        call system('PowerShell -Command "Add-Type –AssemblyName System.Speech; $a = New-Object System.Speech.Synthesis.SpeechSynthesizer; ' .. "$a.SelectVoiceByHints('female');" .. ' $a.Rate = 5; $a.Volume = 70; $text = (@(While($l = Read-Host){$l}) -join(\"`n\")); $a.Speak($text);"', a:text)
    endfunction
else
    function! Speak(text)
        call system("espeak -s 260 -k 1 -p 90", a:text)
    endfunction
    function! TerminateSpeechService()
        echo "Not implemented on Linux; you should be able to ^C"
    endfunction
endif

function! SpeakLine()
    let l:text = getline(".")
    let l:pos = getcurpos()
    let l:lnum = l:pos[1]
    let l:col = l:pos[2]
    if s:verbose
        let l:text = SpeakVerbosen(l:text)
    endif
    let l:toSpeak = l:lnum .. ": " .. l:text
    call Speak(l:toSpeak)
endfunction

function! SpeakVisual()
    let [line_start, column_start] = getpos("'<")[1:2]
    let [line_end, column_end] = getpos("'>")[1:2]
    let lines = getline(line_start, line_end)
    if len(lines) == 0
        return ''
    endif
    let lines[-1] = lines[-1][: column_end - 2]
    let lines[0] = lines[0][column_start - 1:]
    let l:text = join(lines, "\n")
    if s:verbose
        let l:text = SpeakVerbosen(l:text)
    endif
    call Speak(l:text)
endfunction

function! SpeakToggleVerbose()
    if s:verbose
        let s:verbose = 0
        call Speak("Verbose off")
    else
        let s:verbose = 1
        call Speak("Verbose on")
    endif
endfunction

nnoremap <C-L>l :call SpeakLine()<CR>
nnoremap <C-L>n :call Speak(buffer_name())<CR>
nnoremap <C-L>L :call TerminateSpeechService()<CR>
vnoremap <C-L>l <ESC>:call SpeakVisual()<CR>
tnoremap <C-L>l <C-W>N:call SpeakLine()<CR>i
tnoremap <C-L>l <C-W>N:call Speak(buffer_name())<CR>i
nnoremap <C-L>q :call SpeakToggleVerbose()<CR>

" in netrw (:Explore) C-L instantly refreshes and that key does not get treated as a prefix
nnoremap <C-S>l :call SpeakLine()<CR>
nnoremap <C-S>n :call Speak(buffer_name())<CR>
vnoremap <C-S>l <ESC>:call SpeakVisual()<CR>
" but don't map C-S things in terminal mode, that may be needed in the terminal itself
nnoremap <C-S>q :call SpeakToggleVerbose()<CR>
