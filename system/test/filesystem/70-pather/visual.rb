module Skylab::System

  # try running this from various locations, both inside and outside of
  # your home dir

  o = Home_.services.new_pather

  pwd = ::Dir.getwd

  pn = ::Pathname.new pwd

  foo = pn.join 'foo/bar'

  puts "here is pwd              : #{ pwd }"
  puts "here is foo              : #{ foo }"
  puts "here is pretty foo:      : #{ o.call foo }"
  puts "here is pretty foo again : #{ o.call foo }"

end
