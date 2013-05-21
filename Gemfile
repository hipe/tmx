source 'https://rubygems.org'

group :development do

  #  for building the gem -
  gem 'rake'
  gem 'jeweler', git: 'https://github.com/emilsoman/jeweler.git',
                 ref: 'be5ddc35db350e2f0180f165a3129e2833a93072'
                 # #todo - watch / contribute to above effort

  #  for testing, universe-wide (necessary for more than one sub-product)
  gem 'rspec'
  gem 'debugger'


  #  auxiliary requirements for auxiliary scripts, by script -

  # script/simplecov

  gem 'simplecov', require: false, group: :test


  #  by subproduct -

  #  `dependency` (for testing only)
  gem 'adsf'

  #  `tan-man`
  gem 'treetop'

  #  `xargs-ish-i`
  gem 'ncurses-ruby'

end
