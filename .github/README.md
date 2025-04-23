# My dotfiles

My dotfiles and explanations/documentation for myself.

## dotfile management

I use [yadm](https://github.com/TheLocehiliosan/yadm) because it is essentially a bare git repo, with some nice additio
nal features.

## getting started

### manual

Clone the repo:

```sh
yadm clone https://github.com/bojanra/dotfiles
```

Or if you have a key on the machine:

```sh
yadm clone git@github.com:bojanra/dotfiles.git
```

### install tools

```sh
# lf 
get https://github.com/gokcehan/lf/releases/download/r34/lf-linux-amd64.tar.gz -O - | tar xvzf - -C ~/bin/

# eza
wget https://github.com/eza-community/eza/releases/download/v0.21.1/eza_x86_64-unknown-linux-gnu.tar.gz -O - | tar xvzf - -C ~/bin/

# rg
wget https://github.com/BurntSushi/ripgrep/releases/download/14.1.1/ripgrep-14.1.1-aarch64-unknown-linux-gnu.tar.gz -O - | tar xvzf - --wildcards "*/rg" -O > ~/bin/rg && chmod a+x ~/bin/rg

# powerline
wget https://github.com/justjanne/powerline-go/releases/download/v1.25/powerline-go-linux-386 -O - > ~/bin/powerline-go && chmod a+x ~/bin/powerline-go
# fzf

```
