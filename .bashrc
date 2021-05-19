#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
PS1='[\u@\h \W]\$ '
export _JAVA_AWT_WM_NONREPARENTING=1
export XDG_CONFIG_DIRS=/etc/xdg 
export TERM=xfce4-terminal

alias v="vim"
alias iip="vim /home/lucifer/.config/mypolybar/config_new" 
alias ib="vim /home/lucifer/.config/xmobar/xmobarrc"
alias ic="vim /home/lucifer/.config/i3/config"
alias ix="vim /home/lucifer/.xmonad/xmonad.hs"
alias la="ls -la"
alias ll="ls -l"
