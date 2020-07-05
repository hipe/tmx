---
title: installing and deploying python
date: 2018-03-08T13:22:09-05:00
---

# objective

Set up a development (and one day production) environment




# have correct python version (once per version per system)

The requisite python version lives in .python-version



## install pyenv (once per system)

    curl https://pyenv.run | bash
    # (also worked:) brew upgrade pyenv

Add to ~/.zshrc

    export PATH="$HOME/.pyenv/bin:$PATH"
    eval "$(pyenv init -)"

Restart shell:

    exec "$SHELL"



## build target python version (once per version per system)

    pyenv install 3.8.0  # might take 5 minutes
    pyenv local 3.8.0  # writes .python-version
    py -V  # confirm this says the right version (uses aliases in README.md)



# virtual environment stuff

## create your virtualenv (once per project directory)

virtualenv --python=python3 my-venv



## enter your virtualenv (once per work session (terminal))

source my-venv/bin/activate



## one per virtual environment per (set of dependencies)

pip install -r requirements.txt



# general

export PYTHONPATH='.'



[this_page]: https://github.com/googleapis/google-api-python-client



## <a name='document-meta'></a>document-meta

  - #history-A.3: virtualenv & pip, not poetry
  - #history-A.2: upgrade to 3.8.0. poetry not pipenv. sunset lots of configs
  - <a name='history-A.1'></a>#history-A.1: upgrade from python `3.6.4` to `3.6.4_3`
  - #born.
