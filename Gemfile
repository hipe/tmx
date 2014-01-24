source 'https://rubygems.org'

group :development do

  #  for building the gem -
  gem 'rake'
  gem 'jeweler'

  #  for testing, universe-wide (necessary for many subsystems)

  gem 'rspec'


  #  needed (possibly non-essentially) by subsystems and common libraries:

  gem 'simplecov', require: false, group: :test
    #  [ts] (test-runner, regret, quickie-recursive-runner)
  gem 'adsf'
    #  [ts] (the static file server)

  # gem 'ncurses-ruby'
    #  [fa] (in turn used by `xargs-ish-i`, 'sub-tree cov')

  gem 'levenshtein'
    #  [hl]


  #  needed by subproducts:

  gem 'ffi-rzmq'
  gem 'listen'
    #  [gv]

  gem 'treetop'
    #  [ta]

end
