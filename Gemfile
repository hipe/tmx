source 'https://rubygems.org'

group :development do

  #  for building the gem -
  gem 'rake'
  gem 'jeweler', git: 'https://github.com/emilsoman/jeweler.git',
                 ref: 'be5ddc35db350e2f0180f165a3129e2833a93072'
                 # #todo - watch / contribute to above effort

  #  for testing, universe-wide (necessary for many subsystems)
  gem 'rspec'
  gem 'debugger'


  #  needed (possibly non-essentially) by subsystems and common libraries:

  gem 'simplecov', require: false, group: :test
    #  [ts] (test-runner, regret, quickie-recursive-runner)
  gem 'adsf'
    #  [ts] (the static file server)

  gem 'ncurses-ruby'
    #  [fa] (in turn used by `xargs-ish-i`, 'sub-tree cov')

  gem 'levenshtein'
    #  [hl]


  #  needed by subproducts:

  gem 'treetop'
    #  [ta]

end
