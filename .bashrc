# ===================================================================
# ~/.bashrc - Translated from tcsh
# ===================================================================

# --- Shell Options (Globs) ---
# globstar: Allows ** to match all files and directories recursively
shopt -s globstar
# globdot: Allows * to match hidden files (starting with a dot)
shopt -s dotglob

# --- History ---
# unset savehist: Prevent saving history to a file when the session closes
unset HISTFILE

# --- Completion & Correction ---
# Single Tab completes to ambiguity, Double Tab lists possibilities.
#moved to .inputrc because it caused warnings on stderr when not a tty

# --- Directory Navigation ---
# unset cdtohome: In Bash, 'cd' with no arguments always goes home. 
# To disable this, we override 'cd' with a function.
cd() {
    if [ "$#" -eq 0 ]; then
        echo "cd: Too few arguments." >&2
        return 1
    fi
    builtin cd "$@"
}

# --- Prompt ---
# %c (current directory basename) -> \W
# %# (# for root, % for user) -> \$ (# for root, $ for user)
PS1='\W\$ '

# --- Environment Variables ---
export CLICOLOR=1
export QUOTING_STYLE=literal

# --- Aliases ---
# Bash aliases use an equals sign and do not need \!* to append arguments.
alias ls='ls --color=auto --quoting-style=literal'
alias grep='grep --color=auto'
alias dfreal='df -x squashfs -x tmpfs -x devtmpfs'
alias protontricks='flatpak run com.github.Matoking.protontricks --gui'
