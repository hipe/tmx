source :rubygems

group :development do
  gem 'jeweler'
  gem 'rake'
  # this is a terrible idea that makes no sense at all yet I cannot stop myself from doing it
  if /^ruby-1\.9\./ =~ ENV['RUBY_VERSION']
    gem 'ruby-debug19'
  else
    gem 'ruby-debug'
  end
end
