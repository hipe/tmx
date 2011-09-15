source :rubygems

gem 'highline'

group :development do
  gem 'adsf'
  gem 'jeweler'
  gem 'rack'
  gem 'rake', '~> 0.9.2'
  gem 'rdoc', '~> 3.9.2'
  gem 'rspec', '~> 2.6'
  # this is a terrible idea that makes no sense at all yet I cannot stop myself from doing it
  if /^ruby-1\.9\./ =~ ENV['RUBY_VERSION']
    gem 'ruby-debug19'
  else
    gem 'ruby-debug'
  end
end
