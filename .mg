; /tmp is a bad place
backup-to-home-directory
;auto-execute "*.c*" c-mode
;auto-execute "*.java" c-mode
; column numbers are cool
column-number-mode
; this should be enabled
;undo-enable
auto-execute "*.kt" no-tab-mode
auto-execute "*.c*" no-tab-mode
auto-execute "*.java" no-tab-mode
auto-execute "*.h*" no-tab-mode
auto-execute "*.py" no-tab-mode
auto-execute "*.pl" no-tab-mode
auto-execute "*.xml" no-tab-mode
auto-execute "*.json" no-tab-mode
auto-execute "*.y*ml" no-tab-mode

; map some keys
; C-SPACE doesn't work reliably over the combination of ssh+tmux/screen
global-set-key "\^x\^m" set-mark-command
; re-search is cool
global-set-key "\e\^s" re-search-forward
global-set-key "\e\^a" re-search-again
global-set-key "\e\^r" re-search-backward
