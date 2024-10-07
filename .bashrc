# Prompt customization
PS1='┌─  \e[33m\w\e(B\e[m \n└─> '
# command alias
alias ls="ls --color=auto --almost-all --human-readable --time-style=long-iso"
# rm command replace
safe-rm() {
    if [[ $1 == /* ]] ; then
        echo "denied operation '/' path"
        return
    fi
    mv $1 $HOME/.local/share/Trash/ && echo "move to tash complete"
}
alias rm="safe-rm"
alias trash-drop="/usr/bin/rm -ivr $HOME/.local/share/Trash/*"
alias real-rm="/usr/bin/rm -ivr"
