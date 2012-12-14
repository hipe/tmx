require_relative '../core'

module Skylab::Face

  # try running this from various locations, both inside and outside of
  # your home dir

  o = ::Object.new

  o.extend Face::PathTools::InstanceMethods

  pwd = ::FileUtils.pwd

  pn = ::Pathname.new pwd

  foo = pn.join 'foo/bar'

  puts "here is pwd              : #{ pwd }"
  puts "here is foo              : #{ foo }"
  puts "here is pretty foo:      : #{ o.pretty_path foo }"
  puts "here is pretty foo again : #{ o.pretty_path other }"

end
