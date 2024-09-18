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
    call Speak(l:text)
endfunction

nnoremap <C-L>l :call SpeakLine()<CR>
nnoremap <C-L>n :call Speak(buffer_name())<CR>
nnoremap <C-L>L :call TerminateSpeechService()<CR>
vnoremap <C-L>l <ESC>:call SpeakVisual()<CR>
