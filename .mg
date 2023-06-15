; /tmp is a bad place
backup-to-home-directory
; c-mode is just as annoying here as emacs; still, this is how you turn it on
;auto-execute "*.c*" c-mode
;auto-execute "*.java" c-mode
; column numbers are cool
column-number-mode
; this should be enabled
;undo-enable

; map some keys
; C-SPACE doesn't work reliably over the combination of ssh+tmux/screen
global-set-key "\^x\^m" set-mark-command
; re-search is cool
global-set-key "\e\^s" re-search-forward
global-set-key "\e\^a" re-search-again
global-set-key "\e\^r" re-search-backward
