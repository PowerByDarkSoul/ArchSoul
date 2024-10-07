# environment
export LANG="en_US.UTF-8"
export EDITOR="nvim"
export VISUAL="nvim"
export GTK_IM_MODULE=fcitx
export QT_IM_MODULE=fcitx
export XMODIFIERS=@im=fcitx
# include .bashrc
# if [ -f $HOME/.bashrc ]; then 
#    source $HOME/.bashrc
# fi
# auto start sway on tty1
if [ -z "$WAYLAND_DISPLAY" ] && [ -n "$XDG_VTNR" ] && [ "$XDG_VTNR" -eq 1 ]; then
    exec sway
fi
