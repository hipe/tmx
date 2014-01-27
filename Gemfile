source 'https://rubygems.org'


# ~ the specification of our target ruby version lives in this rbenv file

# version_s = File.read( File.expand_path( '../.ruby-version', __FILE__ ) )
# ruby version_s, engine: 'ruby', engine_version: version_s
# but we can't both specify a platform here and have platform-specific below



group :development do  # (until we are in "production" there is only this group)

  # ~ for building the gem

  gem 'rake'
  gem 'jeweler'


  #  ~ for testing, universe-wide
  #  this is needed by the toplevel test-runner, also most subsystems.
  #  ([ts] "quickie" is coming ever closer to obviating this, but not yet)

  gem 'rspec'


  #  ~ needed by one or more subsystems
  #  one subsystem may need many gems and one gem may be needed by many
  #  subsystems. since this file is ultimately a list of gems and not
  #  subsystems, those gems needed by one or more particular subsystem are
  #  listed below in alphabetical order and under each such gem is an
  #  annotation with an alphabetical list of the subsystem(s) that need that
  #  gem, along with an explanation of what they intend to do with that gem.

  gem 'adsf'
    #  [ts] for the static file server used in specs

  gem 'debugger', platform: :mri
    #  [*] if we ever want this while running under bundler, we need it here

  gem 'fiber'
    #  [gv] for celluloid (for clients & servers)

  gem 'ffi-rzmq'
    #  [gv] for the fixtures client and server (spec dev only)

  gem 'levenshtein'
    #  [hl] for NLP intelligent truncation of "large" sets of names

  gem 'listen'
    #  [gv] (same notes as 'ffi-rzmq')

  # gem 'ncurses-ruby'
    #  [fa] for detecting the width in characters of the terminal
    #  used in turn by `xargs-ish-i`, 'sub-tree cov'
    #  we lost this in the upgrade to MRI 2.1.0 and have worked around it

  gem 'rubinius-compiler', platform: :rbx
  gem 'rubinius-debugger', platform: :rbx
    #  same notes as with 'debugger' above

  gem 'rubysl-readline', platform: :rbx
    #  for debugger support


  gem 'treetop'
    #  [ta] for parsing graph-viz dot files

  gem 'simplecov', require: false, group: :test
    #  [ts] test-runner, regret, quickie-recursive-runner

end
