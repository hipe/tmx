source 'https://rubygems.org'

group :development do  # (until we are in "production" there is only this group)

  # ~ for building the gem
  #    (#todo: jeweler 2.0.0 -> github_api -> nokogiri 1.6.0 -> borks)

  # gem 'rake'
  # gem 'jeweler'

  #  ~ for testing, universe-wide

  gem 'rspec'  # (until [ts] "quickie" obviates this..)

  #  ~ needed by one or more subsystems

  #  one subsystem may need many gems and one gem may be needed by many
  #  subsystems. since this file is ultimately a list of gems and not
  #  subsystems, those gems needed by one or more particular subsystem are
  #  listed below in alphabetical order and under each such gem is an
  #  annotation with an alphabetical list of the subsystem(s) that need that
  #  gem, along with an explanation of what they intend to do with that gem.

  gem 'adsf'  # [ts] for the static file server used by some tests ([de])

  # gem 'debugger', platform: :mri (sidestep for now)

  gem 'highline'

  gem 'levenshtein'  # [hu] reduces large sets of strings to smaller sets

  gem 'treetop'  # [ta] for parsing graph-viz dot files

  gem 'simplecov', require: false, group: :test
    #  [ts] test-runner, regret, quickie-recursive-runner

end
