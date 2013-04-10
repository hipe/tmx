# encoding: utf-8

require 'rubygems'
require 'bundler'

-> do
  stderr = $stderr
  enum = nil

  define_method :info do |*msgs, &blk|
    enum ||= ::Enumerator::Yielder.new { |msg| stderr.puts "(#{ msg })" }
    msgs.each { |msg| enum << msg }
    blk and blk[ enum ]
    enum << "from BEEF"
    nil
  end
end.call

begin
  Bundler.setup :default, :development
rescue Bundler::BundlerError => e
  info do |i|
    i << e.message
    i << "Run `bundle install` to install missing gems"
  end
  exit e.status_code
end

require 'rake'
require 'jeweler'

Jeweler::Tasks.new do |gem|

  # `gem` is Gem::Specification - http://docs.rubygems.org/read/chapter/20

  gem.name = "tmx"
  gem.homepage = "http://github.com/hipe/tmx"
  gem.license = "MIT"
  gem.summary = %Q{experiments with project management data visualization & code analytics}
  gem.description = %Q{tmx will change the life of you and everyone around you}
  gem.email = "mark.meves@gmail.com"
  gem.authors = ["Mark Meves"]
  # dependencies defined in Gemfile
end

Jeweler::RubygemsDotOrgTasks.new


# be sure to use jeweler to see all the other goodies we're not using,
# e.g. TestTask, RcovTask

require 'rdoc/task'
require 'pathname'

RDoc::Task.new do |rdoc|

  rdoc.rdoc_dir = 'rdoc'
  rdoc.rdoc_files.include 'README*'
  rdoc.rdoc_files.include 'lib/**/*.rb'

  vpn = ::Pathname.new "#{ __dir__ }/VERSION"
  if vpn.exist?
    rdoc.title = "tmx #{ vpn.read.chomp }"
  else
    info "version unknown because no such path - #{ vpn }"
    rdoc.title = "tmx"
  end
end
