HISTFILE=~/.config/zsh/.histfile
HISTSIZE=5000
SAVEHIST=100000
setopt autocd extendedglob
unsetopt beep
bindkey -v

# Initialize Starship prompt
eval "$(starship init zsh)"

