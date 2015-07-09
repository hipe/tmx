module Skylab::System

  # try running this from various locations, both inside and outside of
  # your home dir

  o = Home_.services.filesystem.path_tools

  pwd = ::Dir.getwd

  pn = ::Pathname.new pwd

  foo = pn.join 'foo/bar'

  puts "here is pwd              : #{ pwd }"
  puts "here is foo              : #{ foo }"
  puts "here is pretty foo:      : #{ o.pretty_path foo }"
  puts "here is pretty foo again : #{ o.pretty_path foo }"

end
