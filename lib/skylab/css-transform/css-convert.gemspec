# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "css-convert/version"

Gem::Specification.new do |s|
  s.name        = "css-convert"
  s.version     = Hipe::CssConvert::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Mark Meves"]
  s.email       = ["mark.meves@gmail.com"]
  s.homepage    = "http://rubygems.org/gems/css-convert"
  s.summary     = %q{ridiculous}
  s.description = %q{ridiculous}

  s.rubyforge_project = "css-convert"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
