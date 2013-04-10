# started as copy-paste from dm-core
require 'rubygems'
require 'rake'

begin
  gem 'jeweler', '~> 1.4'
  require 'jeweler'

  Jeweler::Tasks.new do |gem|
    gem.name        = 'hipe-assess'
    gem.summary     = 'web1.0 synergy'
    gem.description = 'you should go outside'
    gem.email       = 'chip.malice@gmail.com'
    gem.homepage    = 'http://github.com/hipe/hipe-assess'
    gem.authors     = ['Chip Malice']

    gem.add_dependency 'json', '~> 1.2.3'
    gem.add_dependency 'ruby_parser', '~> 2.0.4'
    gem.add_dependency 'ruby2ruby', '~> 1.2.4'
    gem.add_dependency 'sexp_processor', '~> 3.0.3'
    gem.add_dependency 'haml', '~> 2.2.22'
    gem.add_dependency 'ramaze', '~> 2010.03'
    gem.add_dependency 'ruby-graphviz', '~> 0.9.10'

    gem.add_development_dependency 'minitest', '~> 1.5.0'
  end

  Jeweler::GemcutterTasks.new

  FileList['tasks/**/*.rake'].each { |task| import task }
rescue LoadError
  puts 'Jeweler (or a dependency) not available. Install it with: gem install jeweler'
end
