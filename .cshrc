set addsuffix
unset autocorrect
unset autoexpand
unset autolist
unset cdtohome
#set color
unset complete
unset correct
set prompt="%c%# "
setenv CLICOLOR
alias ls 'ls --color=auto --quoting-style=literal'
alias grep 'grep --color=auto'
alias dfreal 'df -x squashfs -x tmpfs -x devtmpfs \!*'
setenv QUOTING_STYLE literal
