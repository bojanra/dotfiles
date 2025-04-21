# My dotfiles

My dotfiles and explanations/documentation for myself.

## dotfile management

I use [yadm](https://github.com/TheLocehiliosan/yadm) because it is essentially a bare git repo, with some nice additio
nal features.

## getting started

### minimal quickstart

```
bash <(curl -sS https://raw.githubusercontent.com/ferdinandyb/dotfiles/master/.config/yadm/minimalbootstrap)
```

### manual

Install yadm:

```
curl -fLo ~/.local/bin/yadm https://github.com/TheLocehiliosan/yadm/raw/master/yadm && chmod a+x ~/.local/bin/yadm
```

Clone the repo:

```
yadm clone https://github.com/ferdinandyb/dotfiles.git
```

Or if you have a key on the machine:

```
yadm clone git@github.com:ferdinandyb/dotfiles.git
```
