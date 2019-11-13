---
title: installing and deploying python
date: 2018-03-08T13:22:09-05:00
---

## rewrite

At .#history-A.2 we rewrote this file, sunsetting TONS of old docs.

This documents's objective is to journal our setup of our own environment.

This becomes relevant when we upgrade python versions, change package managers.

Efforts were make to make this accurate, but it may not be 100%.



## install pyenv (once)

    curl https://pyenv.run | bash
    # (also worked:) brew upgrade pyenv

Add to ~/.zshrc

    export PATH="$HOME/.pyenv/bin:$PATH"
    eval "$(pyenv init -)"

Restart shell:

    exec "$SHELL"



## build target python version

    pyenv install 3.8.0  # might take 5 minutes
    pyenv local 3.8.0  # writes .python-version
    py -V  # confirm this says the right version (uses aliases in README.md)



## install poetry (once)

    curl -sSL https://raw.githubusercontent.com/sdispater/poetry/master/get-poetry.py | py

Add to ~/.zshrc

    export PATH="$HOME/.poetry/bin:$PATH"



## then try this:

    poetry install

See that it fails with something about `cleo`. So have this flag on:

    curl -sSL https://raw.githubusercontent.com/sdispater/poetry/master/get-poetry.py | POETRY_PREVIEW=1 py

Then this should work:

    poetry install



## ALSO ONCE

get this in .zshrc

    PYTHONPATH='.'

(it changed)



## NOW whenever we work, we do:

    poetry shell




## <a name='document-meta'></a>document-meta

  - #history-A.2: upgrade to 3.8.0. poetry not pipenv. sunset lots of configs
  - <a name='history-A.1'></a>#history-A.1: upgrade from python `3.6.4` to `3.6.4_3`
  - #born.
